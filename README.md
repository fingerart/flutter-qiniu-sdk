# Qiniu SDK plugin for Flutter

[![pub package](https://img.shields.io/pub/v/flutter_qiniu_sdk.svg)](https://pub.dartlang.org/packages/flutter_qiniu_sdk)

A flutter plugin for Qiniu object storage sdk. Support the flexible configuration, progress and complete the callback.

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback welcome](https://github.com/FingerArt/flutter-qiniu-sdk/issues) and [Pull Requests](https://github.com/FingerArt/flutter-qiniu-sdk/pulls) are most welcome!

## Support platform

- [x] Android
- [ ] iOS

## Dependency

- Android: `qiniu-android-sdk:7.3.15`
- iOS:

## Installation

First, add `flutter_qiniu_sdk` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Example

1. Configuration

```dart
import 'package:flutter_qiniu_sdk/flutter_qiniu_sdk.dart';

var conf = ConfigBuilder()
  ..enableRecord = true // enable breakpoint resume
  ..zone = Zone.autoZone // select zone service
  ..useHttps = true; // enable https

Qiniu.config(conf.build);
```

2. Async upload file

```dart
var cancelable = Qiniu.put(key, token, filepath, onProgress: (String key, double percent) {
  debugPrint("onProgress: $key, $percent");
}, onComplete: (String key, ResponseInfo info, String response) {
  debugPrint("onComplete: $key, $info, $response");
});

// cancel
cancelable.cancel();
```

3. Sync upload file

```dart
Qiniu.syncPut(key, token, filepath, onProgress: (String key, double percent) {
  debugPrint("onProgress: $key, $percent");
}, onComplete: (String key, ResponseInfo info, String response) {
  debugPrint("onComplete: $key, $info, $response");
});
```

4. Cancel upload task

```dart
Qiniu.cancel(key);
```