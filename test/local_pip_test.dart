import 'package:flutter_test/flutter_test.dart';
import 'package:local_pip/local_pip.dart';
import 'package:local_pip/local_pip_platform_interface.dart';
import 'package:local_pip/local_pip_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLocalPipPlatform
    with MockPlatformInterfaceMixin
    implements LocalPipPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
  @override
  Future<bool> isPipAvailable() => Future.value(true);
  @override
  Future<bool> enterPipMode() => Future.value(true);
}

void main() {
  final LocalPipPlatform initialPlatform = LocalPipPlatform.instance;

  test('$MethodChannelLocalPip is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLocalPip>());
  });

  test('getPlatformVersion', () async {
    LocalPip localPipPlugin = LocalPip();
    MockLocalPipPlatform fakePlatform = MockLocalPipPlatform();
    LocalPipPlatform.instance = fakePlatform;

    expect(await localPipPlugin.getPlatformVersion(), '42');
  });

  test('isPipAvailable', () async {
    LocalPip localPipPlugin = LocalPip();
    MockLocalPipPlatform fakePlatform = MockLocalPipPlatform();
    LocalPipPlatform.instance = fakePlatform;
    expect(await localPipPlugin.isPipAvailable(), isTrue);
  });
  test('enterPipMode', () async {
    LocalPip localPipPlugin = LocalPip();
    MockLocalPipPlatform fakePlatform = MockLocalPipPlatform();
    LocalPipPlatform.instance = fakePlatform;
    expect(await localPipPlugin.enterPipMode(), isTrue);
  });
}
