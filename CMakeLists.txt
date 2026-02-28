cmake_minimum_required(VERSION 3.22)
project(Bpp LANGUAGES NONE)

option(BPP_BOOTSTRAP_NASM "Automatically download NASM on Windows when not found" ON)
set(BPP_NASM_VERSION "2.16.03" CACHE STRING "NASM version used for Windows bootstrap")

set(BPP_DEFAULT_VERSION "bpp")
file(GLOB _bpp_stage1_candidates RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/bin" "${CMAKE_CURRENT_SOURCE_DIR}/bin/*_stage1")
if(_bpp_stage1_candidates)
    list(SORT _bpp_stage1_candidates)
    list(GET _bpp_stage1_candidates -1 _bpp_latest_stage1)
    string(REGEX REPLACE "_stage1$" "" BPP_DEFAULT_VERSION "${_bpp_latest_stage1}")
endif()

set(BPP_ACTIVE_VERSION "${BPP_DEFAULT_VERSION}" CACHE STRING "Active compiler version identifier")
set(BPP_INSTALL_BINDIR "bin" CACHE STRING "Install directory for bpp launcher")
set(BPP_INSTALL_LIBEXECDIR "libexec" CACHE STRING "Install directory for bpp compiler binaries")
set(BPP_INSTALL_DATADIR "share" CACHE STRING "Install directory for bpp shared data")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(BppToolchain)

bpp_resolve_nasm(BPP_NASM_EXECUTABLE)
bpp_resolve_linker(BPP_LINKER_EXECUTABLE)

message(STATUS "BPP active version id : ${BPP_ACTIVE_VERSION}")
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

if(UNIX AND NOT WIN32)
    set(BPP_STAGE1_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/bin/${BPP_ACTIVE_VERSION}_stage1")
    if(NOT EXISTS "${BPP_STAGE1_SOURCE}")
        set(_bpp_fallback_stage1 "${CMAKE_CURRENT_SOURCE_DIR}/bin/stage1")
        if(EXISTS "${_bpp_fallback_stage1}")
            set(BPP_STAGE1_SOURCE "${_bpp_fallback_stage1}")
        elseif(_bpp_stage1_candidates)
            list(GET _bpp_stage1_candidates -1 _bpp_latest_stage1)
            set(BPP_STAGE1_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/bin/${_bpp_latest_stage1}")
        endif()
    endif()
    if(NOT EXISTS "${BPP_STAGE1_SOURCE}")
        message(WARNING
            "Linux stage1 compiler binary not found at ${BPP_STAGE1_SOURCE}. "
            "Install step will fail unless you build it first (e.g. run ./build_and_test.sh)."
        )
    endif()

    set(BPP_INSTALL_VERSION "${BPP_ACTIVE_VERSION}")
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/bpp_launcher.sh.in"
        "${CMAKE_CURRENT_BINARY_DIR}/bpp"
        @ONLY
    )

    install(PROGRAMS "${CMAKE_CURRENT_BINARY_DIR}/bpp" DESTINATION "${BPP_INSTALL_BINDIR}")
    install(PROGRAMS "${BPP_STAGE1_SOURCE}" DESTINATION "${BPP_INSTALL_LIBEXECDIR}/bpp")
    install(
        DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/src/std"
        DESTINATION "${BPP_INSTALL_DATADIR}/bpp/src"
    )
endif()

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
