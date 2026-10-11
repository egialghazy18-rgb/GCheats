package com.nzwx.gcheats

import android.content.pm.PackageManager
import rikka.shizuku.Shizuku

object ShizukuHelper {
    const val PERMISSION_REQUEST_CODE = 1001

    fun isInstalled(): Boolean {
        return try {
            val pm = Shizuku.getBinder() != null
            pm
        } catch (e: Exception) {
            false
        }
    }

    fun isRunning(): Boolean {
        return try {
            Shizuku.pingBinder()
        } catch (e: Exception) {
            false
        }
    }

    fun checkPermission(): Boolean {
        return try {
            if (Shizuku.isPreV11()) return false
            Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED
        } catch (e: Exception) {
            false
        }
    }

    fun requestPermission(listener: () -> Unit) {
        try {
            Shizuku.addRequestPermissionResultListener { requestCode, grantResult ->
                if (requestCode == PERMISSION_REQUEST_CODE) {
                    listener()
                }
            }
            Shizuku.requestPermission(PERMISSION_REQUEST_CODE)
        } catch (e: Exception) {
            // Shizuku not available
        }
    }

    fun getUid(): Int {
        return try {
            Shizuku.getUid()
        } catch (e: Exception) {
            -1
        }
    }

    /** Execute shell command via Shizuku's shell (UID 2000). */
    fun execShell(command: Array<String>): String {
        return try {
            val process = Shizuku.newProcess(command, null, null)
            val output = process.inputStream.bufferedReader().use { it.readText() }
            val error = process.errorStream.bufferedReader().use { it.readText() }
            if (output.isNotEmpty()) output else error
        } catch (e: Exception) {
            "ERROR: ${e.message}"
        }
    }
}
