package com.nzwx.gcheats

import android.app.usage.UsageStatsManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val GAME_CHANNEL = "nzwx/game_detector"
    private val OVERLAY_CHANNEL = "nzwx/overlay_bridge"
    private val HOOK_CHANNEL = "nzwx/native_hook"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, GAME_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getForegroundPackage" -> result.success(getForegroundPackage())
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OVERLAY_CHANNEL)
            .setMethodCallHandler { _, result -> result.success(true) }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HOOK_CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "getVersion" -> result.success(NativeHook.getVersion())
                        "findPid" -> {
                            val pkg = call.argument<String>("package") ?: ""
                            result.success(NativeHook.findPidByName(pkg))
                        }
                        "findModuleBase" -> {
                            val pid = call.argument<Int>("pid") ?: -1
                            val mod = call.argument<String>("module") ?: ""
                            result.success(NativeHook.findModuleBase(pid, mod))
                        }
                        "attach" -> {
                            val pid = call.argument<Int>("pid") ?: -1
                            result.success(NativeHook.attachProcess(pid))
                        }
                        "writeMemory" -> {
                            val pid = call.argument<Int>("pid") ?: -1
                            val addr = call.argument<Long>("addr") ?: 0L
                            val data = call.argument<ByteArray>("data") ?: ByteArray(0)
                            result.success(NativeHook.writeMemory(pid, addr, data))
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.error("HOOK_ERR", e.message, null)
                }
            }
    }

    private fun getForegroundPackage(): String? {
        return try {
            val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val now = System.currentTimeMillis()
            val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, now - 10000, now)
            stats?.maxByOrNull { it.lastTimeUsed }?.packageName
        } catch (e: Exception) { null }
    }
}
