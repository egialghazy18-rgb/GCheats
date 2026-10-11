#include "include/hook.h"
#include <android/log.h>
#include <dirent.h>
#include <fstream>
#include <sstream>
#include <cstring>
#include <unistd.h>
#include <sys/ptrace.h>
#include <sys/wait.h>

#define LOG_TAG "GCheats-Hook"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

namespace Hook {

int FindPidByName(const std::string& packageName) {
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

uintptr_t FindModuleBase(int pid, const std::string& moduleName) {
    std::string mapsPath = "/proc/" + std::to_string(pid) + "/maps";
    std::ifstream maps(mapsPath);
    if (!maps.is_open()) return 0;

    std::string line;
    while (std::getline(maps, line)) {
        if (line.find(moduleName) != std::string::npos) {
            // Format: "7f8a400000-7f8a500000 r-xp ... /path/libxxx.so"
            size_t dash = line.find('-');
            if (dash == std::string::npos) continue;

            std::string addrStr = line.substr(0, dash);
            return std::stoull(addrStr, nullptr, 16);
        }
    }
    return 0;
}

Status AttachProcess(int pid) {
    if (pid <= 0) return Status::ERR_PROCESS_NOT_FOUND;

    if (ptrace(PTRACE_ATTACH, pid, nullptr, nullptr) == -1) {
        LOGE("ptrace attach failed: %s", strerror(errno));
        return Status::ERR_ATTACH_FAILED;
    }

    int status;
    waitpid(pid, &status, 0);

    if (!WIFSTOPPED(status)) {
        LOGE("Process not stopped after attach");
        return Status::ERR_ATTACH_FAILED;
    }

    LOGI("Attached to PID %d", pid);
    return Status::OK;
}

void DetachProcess() {
    // Detach semua child
    // Implementasi lengkap butuh track PID di global state
}

Status ReadMemory(int pid, uintptr_t addr, void* buf, size_t size) {
    // Untuk implementasi beneran: process_vm_readv
    // Butuh CAP_SYS_PTRACE — didapat via Shizuku (shell UID 2000)
    struct iovec local = { buf, size };
    struct iovec remote = { (void*)addr, size };

    ssize_t n = process_vm_readv(pid, &local, 1, &remote, 1, 0);
    if (n < 0 || (size_t)n != size) {
        LOGE("readv failed at 0x%lx: %s", addr, strerror(errno));
        return Status::ERR_READ_FAILED;
    }
    return Status::OK;
}

Status WriteMemory(int pid, uintptr_t addr, const void* buf, size_t size) {
    struct iovec local = { (void*)buf, size };
    struct iovec remote = { (void*)addr, size };

    ssize_t n = process_vm_writev(pid, &local, 1, &remote, 1, 0);
    if (n < 0 || (size_t)n != size) {
        LOGE("writev failed at 0x%lx: %s", addr, strerror(errno));
        return Status::ERR_WRITE_FAILED;
    }
    return Status::OK;
}

Status ApplyPatch(int pid, uintptr_t addr, const std::vector<uint8_t>& bytes) {
    return WriteMemory(pid, addr, bytes.data(), bytes.size());
}

Status RestorePatch(int pid, uintptr_t addr) {
    // Untuk implementasi: cache original bytes sebelum patch, restore dari cache
    return Status::OK;
}

}
