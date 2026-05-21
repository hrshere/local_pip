import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_pip/local_pip_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelLocalPip platform = MethodChannelLocalPip();
  const MethodChannel channel = MethodChannel('local_pip');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'getPlatformVersion':
              return '42';
            case 'isPipAvailable':
              return true;
            case 'enterPipMode':
              return true;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
  test('isPipAvailable calls correct method', () async {
    expect(await platform.isPipAvailable(), isTrue);
  });
  test('enterPipMode calls correct method', () async {
    expect(await platform.enterPipMode(), isTrue);
  });
}
