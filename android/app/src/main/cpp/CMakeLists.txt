cmake_minimum_required(VERSION 3.18.1)
project("gcheats_hook")

add_library(gcheats_hook SHARED
    hook.cpp
    memory.cpp
    process.cpp
    jni_bridge.cpp
)

target_include_directories(gcheats_hook PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Link library Android
find_library(log-lib log)
find_library(android-lib android)

target_link_libraries(gcheats_hook
    ${log-lib}
    ${android-lib}
)
