package com.example.local_pip

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import android.app.Activity
import android.app.PictureInPictureParams
import android.os.Build
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding



/** LocalPipPlugin */
class LocalPipPlugin :
    FlutterPlugin,
    MethodCallHandler, ActivityAware {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "local_pip")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {

        when(call.method){
            "getPlatformVersion" ->{
                result.success("Android ${Build.VERSION.RELEASE}")
            }
            "isPipAvailable" -> {
                // PiP was added in Android 8.0 (Oreo), which is API level 26
                val isAvailable = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
                result.success(isAvailable)
            }
            "enterPipMode" -> {
                if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
                    if(activity != null){
                        val params = PictureInPictureParams.Builder().build()
                        val success = activity?.enterPictureInPictureMode(params) ?: false
                        result.success(success)
                    } else {
                        result.error("NO_ACTIVITY", "Activity is null", null)
                    }
                }
                else{
                    result.success(false) // PiP not supported on this version
                }
            }
            else -> {
                result.notImplemented()
            }
        }
//        if (call.method == "getPlatformVersion") {
//            result.success("Android ${Build.VERSION.RELEASE}")
//        } else {
//            result.notImplemented()
//        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
