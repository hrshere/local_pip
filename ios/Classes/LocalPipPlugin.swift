import Flutter
import UIKit
import AVKit

public class LocalPipPlugin: NSObject, FlutterPlugin, AVPictureInPictureControllerDelegate, AVPictureInPictureSampleBufferPlaybackDelegate {
  private var pipController: AVPictureInPictureController?
  private var displayLayer: AVSampleBufferDisplayLayer?
  private var displayLink: CADisplayLink?
  
  private var flutterView: UIView? {
    return UIApplication.shared.keyWindow?.rootViewController?.view
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "local_pip", binaryMessenger: registrar.messenger())
    let instance = LocalPipPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "isPipAvailable":
      setupPip()
      result(AVPictureInPictureController.isPictureInPictureSupported())
    case "enterPipMode":
      setupPip()
      if let controller = pipController {
        if controller.isPictureInPicturePossible {
          controller.startPictureInPicture()
          result(true)
        } else {
          // If the system hasn't fully updated the transition state yet,
          // wait a brief moment and attempt to start Picture-in-Picture.
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            controller.startPictureInPicture()
          }
          result(true)
        }
      } else {
        result(false)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func setupPip() {
    guard AVPictureInPictureController.isPictureInPictureSupported(), pipController == nil else { return }
    guard let view = flutterView else { return }
    
    // Configure AVAudioSession for playback
    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback, mode: .moviePlayback, options: [])
      try session.setActive(true)
    } catch {
      print("LocalPipPlugin: Failed to configure AVAudioSession: \(error)")
    }
    
    let layer = AVSampleBufferDisplayLayer()
    self.displayLayer = layer
    
    // Add the display layer to the view hierarchy (must be in hierarchy for PiP)
    // Sized to a small 1x1 area offscreen/hidden to not interfere with main UI.
    layer.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    view.layer.addSublayer(layer)
    
    if #available(iOS 15.0, *) {
      let contentSource = AVPictureInPictureController.ContentSource(
        sampleBufferDisplayLayer: layer,
        playbackDelegate: self
      )
      pipController = AVPictureInPictureController(contentSource: contentSource)
      pipController?.delegate = self
      pipController?.canStartPictureInPictureAutomaticallyFromInline = true
    }
    
    // Render and enqueue the first frame immediately so the layer is not empty
    updateFrame()
  }

  // MARK: - AVPictureInPictureControllerDelegate
  public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
    startDisplayLink()
  }

  public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
    stopDisplayLink()
  }

  private func startDisplayLink() {
    displayLink = CADisplayLink(target: self, selector: #selector(updateFrame))
    displayLink?.add(to: .main, forMode: .common)
  }

  private func stopDisplayLink() {
    displayLink?.invalidate()
    displayLink = nil
  }

  @objc private func updateFrame() {
    guard let view = flutterView, let layer = displayLayer, layer.isReadyForMoreMediaData else { return }
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    if let cgImage = image?.cgImage {
      pushFrame(cgImage: cgImage)
    }
  }

  private func pushFrame(cgImage: CGImage) {
    guard let layer = displayLayer else { return }
    
    // Helper to convert CGImage to CMSampleBuffer
    // This is low-level AVFoundation code
    let width = cgImage.width
    let height = cgImage.height
    
    var pixelBuffer: CVPixelBuffer?
    let options = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                   kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
    
    CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, options, &pixelBuffer)
    
    if let buffer = pixelBuffer {
      CVPixelBufferLockBaseAddress(buffer, .init(rawValue: 0))
      let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                              width: width, height: height,
                              bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                              space: CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
      
      context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
      CVPixelBufferUnlockBaseAddress(buffer, .init(rawValue: 0))
      
      var timingInfo = CMSampleTimingInfo(duration: CMTime(value: 1, timescale: 60), presentationTimeStamp: .init(value: Int64(CACurrentMediaTime() * 60), timescale: 60), decodeTimeStamp: .invalid)
      var videoInfo: CMVideoFormatDescription?
      CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: buffer, formatDescriptionOut: &videoInfo)
      
      var sampleBuffer: CMSampleBuffer?
      if let videoInfo = videoInfo {
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: buffer, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: videoInfo, sampleTiming: &timingInfo, sampleBufferOut: &sampleBuffer)
        
        if let sampleBuffer = sampleBuffer {
          layer.enqueue(sampleBuffer)
        }
      }
    }
  }

  // MARK: - AVPictureInPictureSampleBufferPlaybackDelegate
  public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {}
  public func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {
    return CMTimeRange(start: .zero, duration: .indefinite)
  }
  public func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool { return false }
  public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {}
  public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, skipByInterval skipInterval: CMTime, completion: @escaping () -> Void) {}
}
