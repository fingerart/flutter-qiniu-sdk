import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_qiniu_sdk/models.dart';

class QiNiu {
  static QiNiu _instance = QiNiu._();
  MethodChannel _channel = MethodChannel('io.chengguo/flutter_qiniu_sdk');
  Map<String, OnProgress> _progresses = Map();
  Map<String, OnComplete> _completes = Map();

  QiNiu._() {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "onProgress":
          _onProgress(call);
          break;
        case "onComplete":
          _onComplete(call);
          break;
      }
    });
  }

  /// 配置七牛SDK
  static Future config(ConfigBuilder configBuilder) async {
    return await _instance._onConfig(configBuilder.build);
  }

  /// 异步上传文件
  ///
  /// [key] key
  ///
  /// [token] token
  ///
  /// [filePath] 文件路径
  ///
  /// [params] 扩展参数，以<code>x:</code>开头的用户自定义参数
  ///
  /// [mimeType] 指定上传文件的MimeType
  ///
  /// [checkCrc] 启用上传内容crc32校验
  ///
  /// [onProgress] 上传进度回调
  ///
  /// [onComplete] 完成上传回调
  static Future<UpCancellation> put(String key, String token, String filePath,
      {Map<String, dynamic> params,
      String mimeType,
      bool checkCrc,
      OnProgress onProgress,
      OnComplete onComplete}) async {
    return await _instance._onPut(key, token, filePath, params, mimeType, checkCrc, onProgress, onComplete);
  }

  /// 同步上传文件
  ///
  /// [key] key
  ///
  /// [token] token
  ///
  /// [filePath] 文件路径
  ///
  /// [params] 扩展参数，以<code>x:</code>开头的用户自定义参数
  ///
  /// [mimeType] 指定上传文件的MimeType
  ///
  /// [checkCrc] 启用上传内容crc32校验
  ///
  /// [onProgress] 上传进度回调
  ///
  /// [onComplete] 完成上传回调
  static Future<ResponseInfo> syncPut(String key, String token, String filePath,
      {Map<String, dynamic> params,
      String mimeType,
      bool checkCrc,
      OnProgress onProgress,
      OnComplete onComplete}) async {
    return await _instance._onSyncPut(key, token, filePath, params, mimeType, checkCrc, onProgress, onComplete);
  }

  Future<dynamic> _onConfig(Map map) async {
    return await _channel.invokeMapMethod("init", map);
  }

  Future<ResponseInfo> _onSyncPut(String key, String token, String filePath, Map<String, dynamic> params, String mimeType,
      bool checkCrc, OnProgress onProgress, OnComplete onComplete) async {
    var args = {
      "key": key,
      "token": token,
      "filePath": filePath,
      "params": params,
      "mimeType": mimeType,
      "checkCrc": checkCrc,
    };
    if (onProgress != null) {
      _progresses[key] = onProgress;
    }
    if (onComplete != null) {
      _completes[key] = onComplete;
    }
    var result = await _channel.invokeMapMethod("put", args);
    var info = result["info"] as Map;
    return ResponseInfo.map(info);
  }

  Future<UpCancellation> _onPut(String key, String token, String filePath, Map<String, dynamic> params,
      String mimeType, bool checkCrc, OnProgress onProgress, OnComplete onComplete) async {
    try {
      await _onSyncPut(key, token, filePath, params, mimeType, checkCrc, onProgress, onComplete);
      return UpCancellation(() async => await _onCancel(key));
    } on PlatformException catch (e) {
      NativePlatformResult.fromException(e);
      _progresses.remove(key);
      _completes.remove(key);
    }
    return UpCancellation();
  }

  Future _onCancel(String key) {
    _destroyKey(key);
    return _channel.invokeMethod("cancel", {"key": key});
  }

  void _onProgress(MethodCall call) {
    Map map = call.arguments;
    var key = map["key"]?.toString();
    var percent = map["percent"] as double;
    var onProgress = _progresses[key];
    if (onProgress != null) {
      onProgress(key, percent);
    }
  }

  void _onComplete(MethodCall call) {
    Map map = call.arguments;
    var key = map["key"]?.toString();
    var info = map["info"] as Map;
    var response = map["response"]?.toString();
    var onComplete = _completes[key];
    if (onComplete != null) {
      onComplete(key, ResponseInfo.map(info), response);
    }
    _destroyKey(key);
  }

  void _destroyKey(String key) {
    _progresses.remove(key);
    _completes.remove(key);
  }
}

/// 上传进度
///
/// [key] key
///
/// [percent] percent
typedef void OnProgress(String key, double percent);

/// 上传完成
typedef void OnComplete(String key, ResponseInfo info, String response);
