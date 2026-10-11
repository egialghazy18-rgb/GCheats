#include <jni.h>
#include <string>
#include <android/log.h>
#include "include/hook.h"

#define LOG_TAG "GCheats-JNI"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

extern "C" {

JNIEXPORT jint JNICALL
Java_com_nzwx_gcheats_NativeHook_findPidByName(
    JNIEnv* env, jclass clazz, jstring packageName) {
    const char* pkg = env->GetStringUTFChars(packageName, nullptr);
    int pid = Hook::FindPidByName(std::string(pkg));
    env->ReleaseStringUTFChars(packageName, pkg);
    return pid;
}

JNIEXPORT jlong JNICALL
Java_com_nzwx_gcheats_NativeHook_findModuleBase(
    JNIEnv* env, jclass clazz, jint pid, jstring moduleName) {
    const char* mod = env->GetStringUTFChars(moduleName, nullptr);
    uintptr_t base = Hook::FindModuleBase(pid, std::string(mod));
    env->ReleaseStringUTFChars(moduleName, mod);
    return (jlong)base;
}

JNIEXPORT jint JNICALL
Java_com_nzwx_gcheats_NativeHook_attachProcess(
    JNIEnv* env, jclass clazz, jint pid) {
    return (jint)Hook::AttachProcess(pid);
}

JNIEXPORT jint JNICALL
Java_com_nzwx_gcheats_NativeHook_writeMemory(
    JNIEnv* env, jclass clazz, jint pid, jlong addr, jbyteArray data) {
    jsize len = env->GetArrayLength(data);
    jbyte* bytes = env->GetByteArrayElements(data, nullptr);

    std::vector<uint8_t> buffer(len);
    memcpy(buffer.data(), bytes, len);
    env->ReleaseByteArrayElements(data, bytes, JNI_ABORT);

    return (jint)Hook::WriteMemory(pid, (uintptr_t)addr, buffer.data(), len);
}

JNIEXPORT jint JNICALL
Java_com_nzwx_gcheats_NativeHook_readMemory(
    JNIEnv* env, jclass clazz, jint pid, jlong addr, jbyteArray out, jint size) {
    std::vector<uint8_t> buffer(size);
    if (Hook::ReadMemory(pid, (uintptr_t)addr, buffer.data(), size) != Status::OK) {
        return -1;
    }
    env->SetByteArrayRegion(out, 0, size, (const jbyte*)buffer.data());
    return 0;
}

JNIEXPORT jstring JNICALL
Java_com_nzwx_gcheats_NativeHook_getVersion(
    JNIEnv* env, jclass clazz) {
    return env->NewStringUTF("GCheats Hook v1.0");
}

}
