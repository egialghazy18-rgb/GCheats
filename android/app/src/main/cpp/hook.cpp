#include <jni.h>
#include <android/log.h>
#include <cstring>
#include <cstdint>
#include <string>
#include <fstream>
#include <sstream>
#include <dirent.h>
#include <unistd.h>
#include <sys/uio.h>
#include <sys/ptrace.h>
#include <sys/wait.h>
#include <errno.h>

#define LOG_TAG "GCheats-Native"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// ============================================================
// Find PID by process name via /proc scanning
// ============================================================
static int find_pid_by_name(const char* packageName) {
    DIR* dir = opendir("/proc");
    if (!dir) return -1;

    struct dirent* entry;
    while ((entry = readdir(dir)) != nullptr) {
        if (entry->d_type != DT_DIR) continue;

        std::string pidStr = entry->d_name;
        bool isPid = !pidStr.empty() &&
            pidStr.find_first_not_of("0123456789") == std::string::npos;
        if (!isPid) continue;

        std::string cmdlinePath = "/proc/" + pidStr + "/cmdline";
        std::ifstream cmdline(cmdlinePath);
        if (!cmdline.is_open()) continue;

        std::string line;
        std::getline(cmdline, line);
        if (line.find(packageName) != std::string::npos) {
            closedir(dir);
            return std::stoi(pidStr);
        }
    }
    closedir(dir);
    return -1;
}

// ============================================================
// Find module base address from /proc/pid/maps
// ============================================================
static uintptr_t find_module_base(int pid, const char* moduleName) {
    std::string mapsPath = "/proc/" + std::to_string(pid) + "/maps";
    std::ifstream maps(mapsPath);
    if (!maps.is_open()) return 0;

    std::string line;
    while (std::getline(maps, line)) {
        if (line.find(moduleName) != std::string::npos) {
            size_t dash = line.find('-');
            if (dash == std::string::npos) continue;
            std::string addrStr = line.substr(0, dash);
            return std::stoull(addrStr, nullptr, 16);
        }
    }
    return 0;
}

// ============================================================
// Read memory via process_vm_readv
// NOTE: Butuh CAP_SYS_PTRACE. Di Android, ini HANYA jalan kalau
// proses caller punya privilege yang tepat (root/kernel).
// ============================================================
static bool read_memory(int pid, uintptr_t addr, void* buf, size_t size) {
    struct iovec local = { buf, size };
    struct iovec remote = { (void*)addr, size };
    ssize_t n = process_vm_readv(pid, &local, 1, &remote, 1, 0);
    if (n < 0 || (size_t)n != size) {
        LOGE("read_memory(0x%lx) failed: %s", addr, strerror(errno));
        return false;
    }
    return true;
}

// ============================================================
// Write memory via process_vm_writev
// ============================================================
static bool write_memory(int pid, uintptr_t addr, const void* buf, size_t size) {
    struct iovec local = { (void*)buf, size };
    struct iovec remote = { (void*)addr, size };
    ssize_t n = process_vm_writev(pid, &local, 1, &remote, 1, 0);
    if (n < 0 || (size_t)n != size) {
        LOGE("write_memory(0x%lx) failed: %s", addr, strerror(errno));
        return false;
    }
    return true;
}

// ============================================================
// Apply patch (write bytes to memory)
// ============================================================
static bool apply_patch(int pid, uintptr_t addr, const uint8_t* bytes, size_t len) {
    return write_memory(pid, addr, bytes, len);
}

// ============================================================
// JNI exports
// ============================================================
extern "C" {

JNIEXPORT jint JNICALL
Java_com_nzwx_gcheats_NativeHook_findPidByName(
    JNIEnv* env, jclass clazz, jstring packageName) {
    const char* pkg = env->GetStringUTFChars(packageName, nullptr);
    int pid = find_pid_by_name(pkg);
    env->ReleaseStringUTFChars(packageName, pkg);
    return pid;
}

JNIEXPORT jlong JNICALL
Java_com_nzwx_gcheats_NativeHook_findModuleBase(
    JNIEnv* env, jclass clazz, jint pid, jstring moduleName) {
    const char* mod = env->GetStringUTFChars(moduleName, nullptr);
    uintptr_t base = find_module_base(pid, mod);
    env->ReleaseStringUTFChars(moduleName, mod);
    return (jlong)base;
}

JNIEXPORT jboolean JNICALL
Java_com_nzwx_gcheats_NativeHook_readMemory(
    JNIEnv* env, jclass clazz, jint pid, jlong addr, jbyteArray out, jint size) {
    std::vector<uint8_t> buf(size);
    if (!read_memory(pid, (uintptr_t)addr, buf.data(), size)) return JNI_FALSE;
    env->SetByteArrayRegion(out, 0, size, (const jbyte*)buf.data());
    return JNI_TRUE;
}

JNIEXPORT jboolean JNICALL
Java_com_nzwx_gcheats_NativeHook_writeMemory(
    JNIEnv* env, jclass clazz, jint pid, jlong addr, jbyteArray data) {
    jsize len = env->GetArrayLength(data);
    jbyte* bytes = env->GetByteArrayElements(data, nullptr);
    std::vector<uint8_t> buf(len);
    memcpy(buf.data(), bytes, len);
    env->ReleaseByteArrayElements(data, bytes, JNI_ABORT);
    return write_memory(pid, (uintptr_t)addr, buf.data(), len) ? JNI_TRUE : JNI_FALSE;
}

}
