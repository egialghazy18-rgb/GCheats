package com.nzwx.gcheats

import android.app.ActivityManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val GAME_CHANNEL = "nzwx/game_detector"
    private val OVERLAY_CHANNEL = "nzwx/overlay_bridge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Game detector
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, GAME_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getForegroundPackage" -> result.success(getForegroundPackage())
                    else -> result.notImplemented()
                }
            }

        // Overlay bridge — placeholder (diimplementasi kalau butuh IPC ke overlay service)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OVERLAY_CHANNEL)
            .setMethodCallHandler { call, result ->
                // Forward via BroadcastReceiver di implementasi lanjutan
                result.success(true)
            }
    }

    private fun getForegroundPackage(): String? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
                val now = System.currentTimeMillis()
                val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, now - 10000, now)
                stats?.maxByOrNull { it.lastTimeUsed }?.packageName
            } else {
                val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                am.runningAppProcesses?.firstOrNull()?.processName
            }
        } catch (e: Exception) {
            null
        }
    }
}
