package io.chengguo.flutter_qiniu_sdk

import android.os.Handler
import android.os.Looper
import com.qiniu.android.common.AutoZone
import com.qiniu.android.common.FixedZone
import com.qiniu.android.common.Zone
import com.qiniu.android.http.ResponseInfo
import com.qiniu.android.http.UrlConverter
import com.qiniu.android.storage.*
import com.qiniu.android.storage.persistent.FileRecorder
import io.chengguo.flutter_qiniu_sdk.extension.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import org.json.JSONObject
import java.io.File
import java.util.*
import java.util.concurrent.atomic.AtomicLong
import kotlin.collections.HashMap

enum class QiniuSDKWrapper : UpProgressHandler, UpCompletionHandler, NetReadyHandler, UrlConverter {

    INSTANCE;

    private lateinit var mRegistrar: PluginRegistry.Registrar
    private lateinit var mChannel: MethodChannel
    private var mHandler: Handler = Handler(Looper.getMainLooper())
    private var mUploadManager: UploadManager? = null
    private var mIdAtomic: AtomicLong = AtomicLong(Date().time)
    private var mPutIds: HashMap<String?, Long> = HashMap()

    fun register(registrar: PluginRegistry.Registrar, channel: MethodChannel) {
        mRegistrar = registrar
        mChannel = channel
    }

    /**
     * 接受flutter调用
     */
    fun onFlutterMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> init(call, result)
            "put" -> put(call, result)
            "cancel" -> cancel(call, result)
            else -> result.notImplemented()
        }
    }

    /**
     * 初始化配置
     */
    private fun init(call: MethodCall, result: MethodChannel.Result?) {
        val builder = Configuration.Builder()
//        builder.urlConverter(this)
        call.argument<Int>("chunkSize")?.let { builder.chunkSize(it) } // 分片上传时，每片的大小。 默认256K
        call.argument<Int>("putThreshhold")?.let { builder.putThreshhold(it) } // 启用分片上传阀值。默认512K
        call.argument<Int>("connectTimeout")?.let { builder.connectTimeout(it) } // 链接超时。默认10秒
        call.argument<Boolean>("useHttps")?.let { builder.useHttps(it) } // 是否使用https上传域名
        call.argument<Int>("responseTimeout")?.let { builder.responseTimeout(it) } // 服务器响应超时。默认60秒
        call.argument<Int>("zone")?.let { builder.zone(pickZone(it)) } // 设置区域，指定不同区域的上传域名、备用域名、备用IP。
        call.argument<Int>("retryMax")?.let { builder.retryMax(it) } // 上传失败重试次数
        call.argument<Boolean>("enableRecord").pass {
            try {
                val recordDirPath = call.argument<String>("recordDirPath") ?: getExternalFilesDir()
                val keyGen = KeyGenerator { key, file -> key + "_._" + file?.absolutePath?.reversed() }
                val fileRecorder = FileRecorder(recordDirPath)
                builder.recorder(fileRecorder, keyGen)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        mUploadManager = UploadManager(builder.build())
        result.successDefault()
    }

    /**
     * 上传文件
     */
    private fun put(call: MethodCall, result: MethodChannel.Result) {
        if (mUploadManager == null) {
            init(call, null)
        }

        val key = call.argument<String>("key") ?: return result.errorParam("key not be null")
        val token = call.argument<String>("token") ?: return result.errorParam("token not be null")
        val filePath = call.argument<String>("filePath")
                ?: return result.errorParam("filePath not be null")
        if (!File(filePath).exists()) {
            return result.errorInternal("file is not found")
        }
        val params = call.argument<Map<String, String>>("params")
        val mimeType = call.argument<String>("mimeType")
        val checkCrc = call.argument<Boolean>("checkCrc") ?: false

        val putId = generatePutId()
        mPutIds[key] = putId
        val uploadOptions = UploadOptions(
                params,
                mimeType,
                checkCrc,
                this,
                UpCancellationSignal { mPutIds[key] != putId }
        )
        mUploadManager?.put(filePath, key, token, this, uploadOptions)
        result.successDefault()
    }

    /**
     * 取消上传
     */
    private fun cancel(call: MethodCall, result: MethodChannel.Result) {
        val key = call.argument<String>("key")
        mPutIds.remove(key)
        result.successDefault()
    }

    override fun progress(key: String?, percent: Double) {
        val args = HashMap<String, Any?>()
        args["key"] = key
        args["percent"] = percent
        mHandler.post { mChannel.invokeMethod("onProgress", args) }
    }

    override fun complete(key: String?, info: ResponseInfo?, response: JSONObject?) {
        mPutIds.remove(key)

        val args = HashMap<String, Any?>()
        args["key"] = key
        args["info"] = info.toMap()
        args["response"] = response.toString()
        mHandler.post { mChannel.invokeMethod("onComplete", args) }
    }

    override fun waitReady() {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun convert(url: String): String {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    /**
     * 生成putId
     */
    private fun generatePutId(): Long {
        return mIdAtomic.incrementAndGet()
    }

    /**
     * 选择区域机房
     */
    private fun pickZone(index: Int): Zone {
        return when (index) {
            0 -> FixedZone.zone0
            1 -> FixedZone.zone1
            2 -> FixedZone.zone2
            3 -> FixedZone.zoneAs0
            4 -> FixedZone.zoneNa0
            else -> AutoZone.autoZone
        }
    }

    /**
     * 默认断点续传目录
     */
    private fun getExternalFilesDir(): String = File(mRegistrar.activity().externalCacheDir, "qiniu").path

}