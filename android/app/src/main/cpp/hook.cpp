#include "include/hook.h"
#include <android/log.h>
#include <sys/mman.h>
#include <cstring>

#define LOG_TAG "GCheats-Hook"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

namespace Hook {

// === Contoh: Patch recoil FF ===
// Offset ini SAMPLE — bukan offset asli
// Lo harus cari sendiri pakai Ghidra
static constexpr uintptr_t SAMPLE_RECOIL_OFFSET = 0x00A12B40;

// ARM64 NOP instruction
static const std::vector<uint8_t> NOP_ARM64 = { 0x1F, 0x20, 0x03, 0xD5 };

Status PatchNoRecoil(int pid, uintptr_t moduleBase) {
    uintptr_t target = moduleBase + SAMPLE_RECOIL_OFFSET;
    LOGI("Patching NoRecoil at 0x%lx", target);
    return ApplyPatch(pid, target, NOP_ARM64);
}

// === Contoh: Patch aim assist ===
static constexpr uintptr_t SAMPLE_AIM_OFFSET = 0x00B34C20;
static const std::vector<uint8_t> AIM_PATCH = { 0x00, 0x00, 0x80, 0xD2 };

Status PatchAimAssist(int pid, uintptr_t moduleBase) {
    uintptr_t target = moduleBase + SAMPLE_AIM_OFFSET;
    LOGI("Patching AimAssist at 0x%lx", target);
    return ApplyPatch(pid, target, AIM_PATCH);
}

// === Contoh: baca health player ===
static constexpr uintptr_t SAMPLE_HEALTH_OFFSET = 0x00C56000;

int ReadLocalHealth(int pid, uintptr_t moduleBase) {
    uintptr_t target = moduleBase + SAMPLE_HEALTH_OFFSET;
    int health = -1;
    if (ReadMemory(pid, target, &health, sizeof(health)) == Status::OK) {
        LOGI("Health: %d", health);
    }
    return health;
}

}
