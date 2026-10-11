cmake_minimum_required(VERSION 3.18.1)
project("gcheats_hook")

add_library(gcheats_hook SHARED
    hook.cpp
)

target_include_directories(gcheats_hook PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

find_library(log-lib log)
target_link_libraries(gcheats_hook ${log-lib})
