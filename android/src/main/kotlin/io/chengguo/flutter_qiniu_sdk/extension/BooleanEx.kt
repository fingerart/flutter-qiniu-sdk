package io.chengguo.flutter_qiniu_sdk.extension

/**
 * 通过
 */
fun Boolean?.pass(predicate: (Boolean) -> Unit): Boolean {
    if (this == true) {
        predicate(this)
    }
    return (this == true)
}

/**
 * 未通过
 */
fun Boolean?.notPass(predicate: (Boolean) -> Unit): Boolean {
    if (this != true) {
        predicate(false)
    }
    return (this != true)
}