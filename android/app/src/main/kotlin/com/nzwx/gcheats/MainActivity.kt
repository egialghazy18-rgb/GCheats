package com.nzwx.gcheats

import android.app.usage.UsageStatsManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SHIZUKU_CHANNEL = "nzwx/shizuku"
    private val GAME_CHANNEL = "nzwx/game_detector"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHIZUKU_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isInstalled" -> result.success(ShizukuHelper.isInstalled())
                    "isRunning" -> result.success(ShizukuHelper.isRunning())
                    "checkPermission" -> result.success(ShizukuHelper.checkPermission())
                    "requestPermission" -> {
                        ShizukuHelper.requestPermission {
                            result.success(ShizukuHelper.checkPermission())
                        }
                    }
                    "getUid" -> result.success(ShizukuHelper.getUid())
                    "execShell" -> {
                        val cmd = call.argument<List<String>>("command") ?: emptyList()
                        result.success(ShizukuHelper.execShell(cmd.toTypedArray()))
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, GAME_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getForegroundPackage" -> result.success(getForegroundPackage())
                    else -> result.notImplemented()
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
