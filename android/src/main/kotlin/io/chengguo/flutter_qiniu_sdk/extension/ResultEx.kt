package io.chengguo.flutter_qiniu_sdk.extension

import io.flutter.plugin.common.MethodChannel

fun MethodChannel.Result?.errorParam(errorMessage: String?, vararg options: Pair<String, Any>) {
    val result = HashMap<String, Any?>()
    result["code"] = 400
    result["message"] = errorMessage
    options.forEach {
        result[it.first] = it.second
    }
    this?.success(result)
}

fun MethodChannel.Result?.errorInternal(errorMessage: String?, vararg options: Pair<String, Any>) {
    val result = HashMap<String, Any?>()
    result["code"] = 500
    result["message"] = errorMessage
    options.forEach {
        result[it.first] = it.second
    }
    this?.success(result)
}

fun MethodChannel.Result?.successDefault(vararg options: Pair<String, Any>) {
    val result = HashMap<String, Any?>()
    result["code"] = 200
    result["message"] = "success"
    options.forEach {
        result[it.first] = it.second
    }
    this?.success(result)
}
