import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'local_pip_method_channel.dart';

abstract class LocalPipPlatform extends PlatformInterface {
  /// Constructs a LocalPipPlatform.
  LocalPipPlatform() : super(token: _token);

  static final Object _token = Object();

  static LocalPipPlatform _instance = MethodChannelLocalPip();

  /// The default instance of [LocalPipPlatform] to use.
  ///
  /// Defaults to [MethodChannelLocalPip].
  static LocalPipPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LocalPipPlatform] when
  /// they register themselves.
  static set instance(LocalPipPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> isPipAvailable() {
    throw UnimplementedError('isPipAvailable() has not been implemented.');
  }

  Future<bool> enterPipMode() {
    throw UnimplementedError('enterPipMode() has not been implemented.');
  }
}
