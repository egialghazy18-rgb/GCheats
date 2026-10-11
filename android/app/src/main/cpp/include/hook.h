#pragma once
#include <cstdint>
#include <string>
#include <vector>

// Result status
enum class Status {
    OK = 0,
    ERR_ATTACH_FAILED,
    ERR_PERMISSION_DENIED,
    ERR_PROCESS_NOT_FOUND,
    ERR_MODULE_NOT_FOUND,
    ERR_OFFSET_NOT_FOUND,
    ERR_WRITE_FAILED,
    ERR_READ_FAILED,
};

// Hook config
struct HookConfig {
    std::string packageName;   // com.dts.freefireth
    std::string moduleName;    // libil2cpp.so
    uintptr_t baseOffset;      // offset dari module base
    std::vector<uint8_t> patch; // bytes yang ditulis
};

// Process info
struct ProcessInfo {
    int pid;
    std::string name;
    uintptr_t baseAddress;
    size_t moduleSize;
};

namespace Hook {
    // Attach ke proses game
    Status AttachProcess(int pid);

    // Detach
    void DetachProcess();

    // Cari PID dari package
    int FindPidByName(const std::string& packageName);

    // Cari base address dari module
    uintptr_t FindModuleBase(int pid, const std::string& moduleName);

    // Baca memori
    Status ReadMemory(int pid, uintptr_t addr, void* buf, size_t size);

    // Tulis memori
    Status WriteMemory(int pid, uintptr_t addr, const void* buf, size_t size);

    // Apply patch
    Status ApplyPatch(int pid, uintptr_t addr, const std::vector<uint8_t>& bytes);

    // Restore original bytes
    Status RestorePatch(int pid, uintptr_t addr);
}
