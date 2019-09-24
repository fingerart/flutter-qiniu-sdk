package io.chengguo.flutter_qiniu_sdk

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterQiniuSdkPlugin : MethodCallHandler {

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "io.chengguo/flutter_qiniu_sdk")
            channel.setMethodCallHandler(FlutterQiniuSdkPlugin())
            QiniuSDKWrapper.INSTANCE.register(registrar, channel)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        QiniuSDKWrapper.INSTANCE.onFlutterMethodCall(call, result)
    }
}
