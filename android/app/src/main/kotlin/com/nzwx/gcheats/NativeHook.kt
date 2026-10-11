package com.nzwx.gcheats

object NativeHook {
    init {
        System.loadLibrary("gcheats_hook")
    }

    external fun findPidByName(packageName: String): Int
    external fun findModuleBase(pid: Int, moduleName: String): Long
    external fun readMemory(pid: Int, addr: Long, out: ByteArray, size: Int): Boolean
    external fun writeMemory(pid: Int, addr: Long, data: ByteArray): Boolean
}
