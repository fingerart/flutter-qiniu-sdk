import 'package:flutter/services.dart';
import 'package:flutter_qiniu_sdk/flutter_qiniu_sdk.dart';
import 'package:flutter_qiniu_sdk/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('io.chengguo/flutter_qiniu_sdk');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return methodCall.arguments;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('passes the config argument correctly', () async {
    var config = ConfigBuilder()
      ..enableRecord = true
      ..recordDirPath = "/storage/emulated/0/Downloads/test"
      ..zone = Zone.zoneAs0
      ..useHttps = true
      ..chunkSize = 256
      ..connectTimeout = 1000
      ..putThreshhold = 1
      ..responseTimeout = 3000
      ..retryMax = 3;
    expect(await QiNiu.config(config), <String, dynamic>{
      "enableRecord": true,
      "recordDirPath": "/storage/emulated/0/Downloads/test",
      "zone": Zone.zoneAs0.index,
      "useHttps": true,
      "chunkSize": 256,
      "connectTimeout": 1000,
      "putThreshhold": 1,
      "responseTimeout": 3000,
      "retryMax": 3,
    });
  });
}
