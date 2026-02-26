cmake_minimum_required(VERSION 3.22)
project(Bpp LANGUAGES NONE)

option(BPP_BOOTSTRAP_NASM "Automatically download NASM on Windows when not found" ON)
set(BPP_NASM_VERSION "2.16.03" CACHE STRING "NASM version used for Windows bootstrap")
set(BPP_ACTIVE_VERSION "v10" CACHE STRING "Active compiler version directory")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(BppToolchain)

bpp_resolve_nasm(BPP_NASM_EXECUTABLE)
bpp_resolve_linker(BPP_LINKER_EXECUTABLE)

message(STATUS "BPP active version : ${BPP_ACTIVE_VERSION}")
message(STATUS "BPP NASM          : ${BPP_NASM_EXECUTABLE}")
message(STATUS "BPP linker        : ${BPP_LINKER_EXECUTABLE}")

set(BPP_TOOLCHAIN_ENV_FILE "${CMAKE_BINARY_DIR}/bpp_toolchain.env")
file(WRITE "${BPP_TOOLCHAIN_ENV_FILE}" "BPP_NASM_EXECUTABLE=${BPP_NASM_EXECUTABLE}\n")
file(APPEND "${BPP_TOOLCHAIN_ENV_FILE}" "BPP_LINKER_EXECUTABLE=${BPP_LINKER_EXECUTABLE}\n")

add_custom_target(toolchain-check
    COMMAND "${CMAKE_COMMAND}" -E echo "[BPP] NASM   : ${BPP_NASM_EXECUTABLE}"
    COMMAND "${CMAKE_COMMAND}" -E echo "[BPP] Linker : ${BPP_LINKER_EXECUTABLE}"
    COMMAND "${CMAKE_COMMAND}" -E echo "[BPP] Env    : ${BPP_TOOLCHAIN_ENV_FILE}"
)

if(WIN32)
    add_custom_target(windows-smoke
        COMMAND "${CMAKE_COMMAND}"
            "-DBPP_NASM_EXECUTABLE:FILEPATH=${BPP_NASM_EXECUTABLE}"
            "-DBPP_LINKER_EXECUTABLE:FILEPATH=${BPP_LINKER_EXECUTABLE}"
            -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/WindowsSmoke.cmake"
        DEPENDS toolchain-check
        COMMENT "Build and run a minimal Windows executable with NASM + linker"
    )
endif()
