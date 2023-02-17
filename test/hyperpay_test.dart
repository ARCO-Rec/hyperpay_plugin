import 'package:flutter_test/flutter_test.dart';
import 'package:hyperpay/hyperpay.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHyperpayPlatform
    with MockPlatformInterfaceMixin
    implements HyperpayPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> payTransaction(
      CardInfo card, String checkoutID, String brand, String mode) {
    // TODO: implement payTransaction
    throw UnimplementedError();
  }
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
