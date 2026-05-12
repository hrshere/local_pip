import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'local_pip_platform_interface.dart';

/// An implementation of [LocalPipPlatform] that uses method channels.
class MethodChannelLocalPip extends LocalPipPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('local_pip');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> isPipAvailable() async {
    final bool? isAvailable = await methodChannel.invokeMethod<bool>('isPipAvailable');
    return isAvailable ?? false;
  }

  @override
  Future<bool> enterPipMode() async {
    final bool? success = await methodChannel.invokeMethod<bool>('enterPipMode');
    return success ?? false;
  }

}
