class ConfigBuilder {
  int _chunkSize;
  int _putThreshhold;
  int _connectTimeout;
  bool _useHttps;
  int _responseTimeout;
  Zone _zone;
  int _retryMax;
  bool _enableRecord;
  String _recordDirPath;

  /// 分片上传时，每片的大小。 默认256K
  set chunkSize(int chunkSize) => _chunkSize = chunkSize;

  /// 启用分片上传阀值。默认512K
  set putThreshhold(int putThreshhold) => _putThreshhold = putThreshhold;

  /// 链接超时。默认10秒
  set connectTimeout(int connectTimeout) => _connectTimeout = connectTimeout;

  /// 是否使用https上传域名，默认不使用
  set useHttps(bool useHttps) => _useHttps = useHttps;

  /// 服务器响应超时。默认60秒
  set responseTimeout(int responseTimeout) =>
      _responseTimeout = responseTimeout;

  /// 设置区域，指定不同区域的上传域名、备用域名、备用IP。默认 autoZone
  set zone(Zone zone) => _zone = zone;

  /// 上传失败重试次数，默认3次
  set retryMax(int retryMax) => _retryMax = retryMax;

  /// 是否开启断点续传，默认不开启
  set enableRecord(bool enableRecord) => _enableRecord = enableRecord;

  /// 断点记录文件保存的文件夹位置，默认在 ExternalFilesDir
  set recordDirPath(String recordDirPath) => _recordDirPath = recordDirPath;

  Map get build {
    var result = Map();
    if (_chunkSize != null) {
      result["chunkSize"] = _chunkSize;
    }
    if (_putThreshhold != null) {
      result["putThreshhold"] = _putThreshhold;
    }
    if (_connectTimeout != null) {
      result["connectTimeout"] = _connectTimeout;
    }
    if (_useHttps != null) {
      result["useHttps"] = _useHttps;
    }
    if (_responseTimeout != null) {
      result["responseTimeout"] = _responseTimeout;
    }
    if (_zone != null) {
      result["zone"] = _zone.index;
    }
    if (_retryMax != null) {
      result["retryMax"] = _retryMax;
    }
    if (_enableRecord != null) {
      result["enableRecord"] = _enableRecord;
    }
    if (_recordDirPath != null) {
      result["recordDirPath"] = _recordDirPath;
    }
    return result;
  }

  @override
  String toString() {
    return 'ConfigBuilder{_chunkSize: $_chunkSize, _putThreshhold: $_putThreshhold, _connectTimeout: $_connectTimeout, _useHttps: $_useHttps, _responseTimeout: $_responseTimeout, _zone: $_zone, _retryMax: $_retryMax, _recordDirPath: $_recordDirPath}';
  }
}

enum Zone { zone0, zone1, zone2, zoneAs0, zoneNa0, autoZone }

class ResponseInfo {
  /// 回复状态码
  int statusCode;

  /// 请求消耗时间，单位毫秒
  int duration;

  /// 错误信息
  String error;

  /// 服务器域名
  String host;

  /// user agent id
  String id;

  /// 服务器IP
  String ip;

  /// 访问路径
  String path;

  /// 服务器端口
  int port;

  /// 七牛日志扩展头
  String reqId;

  /// 已发送字节数
  int sent;

  /// log 时间戳
  int timeStamp;

  /// 总大小
  int totalSize;

  /// 七牛日志扩展头
  String xlog;

  /// cdn日志扩展头
  String xvia;

  String response;

  ResponseInfo.map(Map map) {
    statusCode = map["statusCode"] ?? 0;
    duration = map["duration"] ?? 0;
    error = map["error"];
    host = map["host"];
    id = map["id"];
    ip = map["ip"];
    path = map["path"];
    port = map["port"] ?? 0;
    reqId = map["reqId"];
    sent = map["sent"] ?? 0;
    timeStamp = map["timeStamp"] ?? 0;
    totalSize = map["totalSize"] ?? 0;
    xlog = map["xlog"];
    xvia = map["xvia"];
    response = map["response"];
  }

  static bool isStatusCodeForBrokenNetwork(int code) {
    return code == NetworkError ||
        code == UnknownHost ||
        code == CannotConnectToHost ||
        code == TimedOut ||
        code == NetworkConnectionLost;
  }

  bool isCancelled() {
    return statusCode == Cancelled;
  }

  bool isOK() {
    return statusCode == 200 &&
        (hasReqId() || response != null);
  }

  bool isNetworkBroken() {
    return statusCode == NetworkError ||
        statusCode == UnknownHost ||
        statusCode == CannotConnectToHost ||
        statusCode == TimedOut ||
        statusCode == NetworkConnectionLost;
  }

  bool isServerError() {
    return (statusCode >= 500 && statusCode < 600 && statusCode != 579) ||
        statusCode == 996;
  }

  bool needSwitchServer() {
    return isNetworkBroken() || isServerError();
  }

  bool needRetry() {
    return !isCancelled() &&
        (needSwitchServer() ||
            statusCode == 406 ||
            (statusCode == 200 && error != null) ||
            isNotQiniu());
  }

  bool isNotQiniu() {
    return statusCode < 500 &&
        statusCode >= 200 &&
        (!hasReqId() && response == null);
  }

  bool hasReqId() {
    return reqId != null;
  }

  @override
  String toString() {
    return 'ResponseInfo{statusCode: $statusCode, duration: $duration, error: $error, host: $host, id: $id, ip: $ip, path: $path, port: $port, reqId: $reqId, sent: $sent, timeStamp: $timeStamp, totalSize: $totalSize, xlog: $xlog, xvia: $xvia, response: $response}';
  }

  static const int ZeroSizeFile = -6;
  static const int InvalidToken = -5;
  static const int InvalidArgument = -4;
  static const int InvalidFile = -3;
  static const int Cancelled = -2;
  static const int NetworkError = -1;
  static const int UnknownError = 0;

  /// <-- error code copy from ios
  static const int TimedOut = -1001;
  static const int UnknownHost = -1003;
  static const int CannotConnectToHost = -1004;
  static const int NetworkConnectionLost = -1005;
}

/// Native平台返回结果
class NativePlatformResult {
  int code;
  String message;
  Map<String, dynamic> options;

  NativePlatformResult({this.code, this.message, this.options});

  bool get isOK => code == 200;

  bool get notOK => code != 200;

  @override
  String toString() {
    return 'NativePlatformResult{code: $code, message: $message, options: $options}';
  }
}
