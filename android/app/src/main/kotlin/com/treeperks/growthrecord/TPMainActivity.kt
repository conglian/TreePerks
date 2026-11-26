package com.treeperks.growthrecord

import com.thinkup.core.api.TUSDK
import com.thinkup.core.api.TUSDKInitListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class TPMainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val context = applicationContext
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.treeperks.growthrecord/topon",
        ).setMethodCallHandler { call, result ->
            if (call.method != "initialize" && call.method != "setChannel") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val channel = call.argument<String>("channel")
            if (channel.isNullOrBlank()) {
                result.error("invalid_channel", "TopOn channel is required", null)
                return@setMethodCallHandler
            }

            try {
                TUSDK.initCustomMap(mapOf<String, Any>("channel" to channel))
                if (call.method == "setChannel") {
                    result.success(null)
                    return@setMethodCallHandler
                }

                val appId = call.argument<String>("appId")
                val appKey = call.argument<String>("appKey")
                if (appId.isNullOrBlank() || appKey.isNullOrBlank()) {
                    result.error("invalid_credentials", "TopOn app ID and key are required", null)
                    return@setMethodCallHandler
                }

                TUSDK.init(context, appId, appKey, null, object : TUSDKInitListener {
                    override fun onSuccess() = result.success(null)

                    override fun onFail(error: String?) {
                        result.error("topon_init_failed", error, null)
                    }
                })
            } catch (error: Exception) {
                result.error("topon_error", error.message, null)
            }
        }
    }
}
