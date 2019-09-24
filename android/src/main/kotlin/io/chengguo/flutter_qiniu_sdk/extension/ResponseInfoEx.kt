package io.chengguo.flutter_qiniu_sdk.extension

import com.qiniu.android.http.ResponseInfo

fun ResponseInfo?.toMap(): HashMap<String, Any?> {
    val result = HashMap<String, Any?>()
    if (this != null) {
        result["statusCode"] = statusCode
        result["duration"] = duration
        result["error"] = error
        result["host"] = host
        result["id"] = id
        result["ip"] = ip
        result["path"] = path
        result["port"] = port
        result["reqId"] = reqId
        result["sent"] = sent
        result["timeStamp"] = timeStamp
        result["totalSize"] = totalSize
        result["xlog"] = xlog
        result["xvia"] = xvia
        result["response"] = response?.toString()
    }
    return result
}