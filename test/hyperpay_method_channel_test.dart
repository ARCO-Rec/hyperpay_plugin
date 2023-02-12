import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyperpay/hyperpay_method_channel.dart';

void main() {
  MethodChannelHyperpay platform = MethodChannelHyperpay();
  const MethodChannel channel = MethodChannel('hyperpay');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
