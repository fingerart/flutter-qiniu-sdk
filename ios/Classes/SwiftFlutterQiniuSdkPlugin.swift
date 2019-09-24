import Flutter
import UIKit

public class SwiftFlutterQiniuSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "io.chengguo/flutter_qiniu_sdk", binaryMessenger:
    registrar.messenger())
    let instance = SwiftFlutterQiniuSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
