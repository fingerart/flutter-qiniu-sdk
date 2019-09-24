import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_qiniu_sdk/flutter_qiniu_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_qiniu_sdk');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
//    expect(await FlutterQiniuSdk.platformVersion, '42');
  });
}
