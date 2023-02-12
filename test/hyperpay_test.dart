import 'package:flutter_test/flutter_test.dart';
import 'package:hyperpay/hyperpay.dart';
import 'package:hyperpay/hyperpay_platform_interface.dart';
import 'package:hyperpay/hyperpay_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHyperpayPlatform
    with MockPlatformInterfaceMixin
    implements HyperpayPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final HyperpayPlatform initialPlatform = HyperpayPlatform.instance;

  test('$MethodChannelHyperpay is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHyperpay>());
  });

  test('getPlatformVersion', () async {
    Hyperpay hyperpayPlugin = Hyperpay();
    MockHyperpayPlatform fakePlatform = MockHyperpayPlatform();
    HyperpayPlatform.instance = fakePlatform;

    expect(await hyperpayPlugin.getPlatformVersion(), '42');
  });
}
