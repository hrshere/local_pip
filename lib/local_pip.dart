
import 'local_pip_platform_interface.dart';

class LocalPip {
  Future<String?> getPlatformVersion() {
    return LocalPipPlatform.instance.getPlatformVersion();
  }

  Future<bool> isPipAvailable() {
    return LocalPipPlatform.instance.isPipAvailable();
  }
  Future<bool> enterPipMode() {
    return LocalPipPlatform.instance.enterPipMode();
  }

}
