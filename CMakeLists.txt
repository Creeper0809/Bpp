cmake_minimum_required(VERSION 3.22)
project(Bpp LANGUAGES NONE)

option(BPP_BOOTSTRAP_NASM "Automatically download NASM on Windows when not found" ON)
set(BPP_NASM_VERSION "2.16.03" CACHE STRING "NASM version used for Windows bootstrap")

set(BPP_DEFAULT_VERSION "bpp")
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/config.ini")
    file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/config.ini" _bpp_config_version_line REGEX "^VERSION=" LIMIT_COUNT 1)
    if(_bpp_config_version_line)
        string(REGEX REPLACE "^VERSION=([^\\r\\n]+)$" "\\1" BPP_DEFAULT_VERSION "${_bpp_config_version_line}")
    endif()
endif()
file(GLOB _bpp_stage1_candidates RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/bin" "${CMAKE_CURRENT_SOURCE_DIR}/bin/*_stage1")
if(_bpp_stage1_candidates)
    set(_bpp_best_numeric_ver "-1")
    set(_bpp_best_numeric_tag "")
    foreach(_bpp_candidate IN LISTS _bpp_stage1_candidates)
        if(_bpp_candidate MATCHES "^v([0-9]+)_stage1$")
            set(_bpp_candidate_ver "${CMAKE_MATCH_1}")
            if(_bpp_candidate_ver GREATER _bpp_best_numeric_ver)
                set(_bpp_best_numeric_ver "${_bpp_candidate_ver}")
                set(_bpp_best_numeric_tag "${_bpp_candidate}")
            endif()
        endif()
    endforeach()

    if(_bpp_best_numeric_tag)
        string(REGEX REPLACE "_stage1$" "" BPP_DEFAULT_VERSION "${_bpp_best_numeric_tag}")
    else()
        # Fallback for non-vN stage tags: keep previous lexical-last behavior.
        list(SORT _bpp_stage1_candidates)
        list(GET _bpp_stage1_candidates -1 _bpp_latest_stage1)
        string(REGEX REPLACE "_stage1$" "" BPP_DEFAULT_VERSION "${_bpp_latest_stage1}")
    endif()
endif()

set(BPP_ACTIVE_VERSION "${BPP_DEFAULT_VERSION}" CACHE STRING "Active compiler version identifier")
set(BPP_INSTALL_BINDIR "bin" CACHE STRING "Install directory for bpp launcher")
set(BPP_INSTALL_LIBEXECDIR "libexec" CACHE STRING "Install directory for bpp compiler binaries")
set(BPP_INSTALL_DATADIR "share" CACHE STRING "Install directory for bpp shared data")
set(BPP_BOOTSTRAP_BASE_URL "https://github.com" CACHE STRING "Base URL for bootstrap compiler release downloads")
set(BPP_BOOTSTRAP_REPOSITORY "Creeper0809/Bpp" CACHE STRING "GitHub repository that hosts bootstrap compiler assets")
set(BPP_BOOTSTRAP_RELEASE_TAG "bootstrap-${BPP_DEFAULT_VERSION}" CACHE STRING "Release tag used for bootstrap compiler downloads")
option(BPP_BOOTSTRAP_COMPILER "Automatically download a bootstrap compiler when local stage1 is missing" ON)
set(BPP_BOOTSTRAP_ASSET_LINUX "bpp-bootstrap-${BPP_DEFAULT_VERSION}-linux-x86_64" CACHE STRING "Linux bootstrap compiler asset name")
set(BPP_BOOTSTRAP_SHA256_LINUX "00c86d700d930eeca73633921886bdec82919c6ef9837d754e9753082b3de827" CACHE STRING "SHA256 for the Linux bootstrap compiler asset")
set(BPP_BOOTSTRAP_ASSET_WINDOWS "" CACHE STRING "Windows bootstrap compiler asset name")
set(BPP_BOOTSTRAP_SHA256_WINDOWS "" CACHE STRING "SHA256 for the Windows bootstrap compiler asset")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(BppToolchain)

bpp_resolve_nasm(BPP_NASM_EXECUTABLE)
bpp_resolve_linker(BPP_LINKER_EXECUTABLE)
bpp_resolve_bootstrap_compiler("${CMAKE_CURRENT_SOURCE_DIR}" "${BPP_ACTIVE_VERSION}" BPP_BASE_COMPILER_EXECUTABLE)

message(STATUS "BPP active version id : ${BPP_ACTIVE_VERSION}")
message(STATUS "BPP NASM          : ${BPP_NASM_EXECUTABLE}")
message(STATUS "BPP linker        : ${BPP_LINKER_EXECUTABLE}")
if(BPP_BASE_COMPILER_EXECUTABLE)
    message(STATUS "BPP bootstrap     : ${BPP_BASE_COMPILER_EXECUTABLE}")
else()
    message(STATUS "BPP bootstrap     : <not found>")
endif()

set(BPP_TOOLCHAIN_ENV_FILE "${CMAKE_BINARY_DIR}/bpp_toolchain.env")
file(WRITE "${BPP_TOOLCHAIN_ENV_FILE}" "BPP_NASM_EXECUTABLE=${BPP_NASM_EXECUTABLE}\n")
file(APPEND "${BPP_TOOLCHAIN_ENV_FILE}" "BPP_LINKER_EXECUTABLE=${BPP_LINKER_EXECUTABLE}\n")
if(BPP_BASE_COMPILER_EXECUTABLE)
    file(APPEND "${BPP_TOOLCHAIN_ENV_FILE}" "BPP_BASE_COMPILER=${BPP_BASE_COMPILER_EXECUTABLE}\n")
endif()

add_custom_target(toolchain-check
    COMMAND "${CMAKE_COMMAND}" -E echo "[BPP] NASM   : ${BPP_NASM_EXECUTABLE}"
    COMMAND "${CMAKE_COMMAND}" -E echo "[BPP] Linker : ${BPP_LINKER_EXECUTABLE}"
    COMMAND "${CMAKE_COMMAND}" -E echo "[BPP] Bootstrap : ${BPP_BASE_COMPILER_EXECUTABLE}"
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
            "Install step will fail unless you build it first (e.g. run ./build_and_test.sh or "
            "cmake --build <build-dir> --target bpp-selfhost-fast)."
        )
    endif()

    if(BPP_BASE_COMPILER_EXECUTABLE)
        add_custom_target(bpp-bootstrap-fetch
            COMMAND "${CMAKE_COMMAND}" -E echo "[BPP] Bootstrap compiler : ${BPP_BASE_COMPILER_EXECUTABLE}"
            DEPENDS toolchain-check
            USES_TERMINAL
        )

        add_custom_target(bpp-selfhost-fast
            COMMAND "${CMAKE_COMMAND}" -E env
                "BPP_BASE_COMPILER=${BPP_BASE_COMPILER_EXECUTABLE}"
                "BPP_NASM_EXECUTABLE=${BPP_NASM_EXECUTABLE}"
                "BPP_LINKER_EXECUTABLE=${BPP_LINKER_EXECUTABLE}"
                "BUILD_AND_TEST_PROFILE=fast"
                bash "${CMAKE_CURRENT_SOURCE_DIR}/build_and_test.sh"
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            DEPENDS bpp-bootstrap-fetch
            USES_TERMINAL
            COMMENT "Bootstrap and self-host the Bpp compiler (fast profile)"
        )

        add_custom_target(bpp-selfhost
            COMMAND "${CMAKE_COMMAND}" -E env
                "BPP_BASE_COMPILER=${BPP_BASE_COMPILER_EXECUTABLE}"
                "BPP_NASM_EXECUTABLE=${BPP_NASM_EXECUTABLE}"
                "BPP_LINKER_EXECUTABLE=${BPP_LINKER_EXECUTABLE}"
                "BUILD_AND_TEST_PROFILE=full"
                bash "${CMAKE_CURRENT_SOURCE_DIR}/build_and_test.sh"
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            DEPENDS bpp-bootstrap-fetch
            USES_TERMINAL
            COMMENT "Bootstrap and self-host the Bpp compiler (full profile)"
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
