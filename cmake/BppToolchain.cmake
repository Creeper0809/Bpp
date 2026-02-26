function(bpp_fail_nasm_not_found)
    message(FATAL_ERROR
        "NASM was not found.\n"
        "- Install NASM manually and ensure it is in PATH, or\n"
        "- Configure with -DBPP_BOOTSTRAP_NASM=ON on Windows.\n"
        "Reference: https://www.nasm.us/pub/nasm/releasebuilds/"
    )
endfunction()

function(bpp_bootstrap_nasm_windows OUT_VAR)
    if(NOT WIN32)
        set(${OUT_VAR} "" PARENT_SCOPE)
        return()
    endif()

    if(NOT BPP_BOOTSTRAP_NASM)
        set(${OUT_VAR} "" PARENT_SCOPE)
        return()
    endif()

    set(_tools_dir "${CMAKE_BINARY_DIR}/_tools")
    set(_zip_file "${_tools_dir}/nasm-${BPP_NASM_VERSION}-win64.zip")
    set(_nasm_root "${_tools_dir}/nasm-${BPP_NASM_VERSION}")
    set(_nasm_exe "${_nasm_root}/nasm.exe")

    if(NOT EXISTS "${_nasm_exe}")
        file(MAKE_DIRECTORY "${_tools_dir}")

        set(_nasm_url "https://www.nasm.us/pub/nasm/releasebuilds/${BPP_NASM_VERSION}/win64/nasm-${BPP_NASM_VERSION}-win64.zip")
        message(STATUS "Downloading NASM from ${_nasm_url}")

        file(DOWNLOAD
            "${_nasm_url}"
            "${_zip_file}"
            SHOW_PROGRESS
            TLS_VERIFY ON
            STATUS _download_status
        )
        list(GET _download_status 0 _download_code)
        list(GET _download_status 1 _download_message)
        if(NOT _download_code EQUAL 0)
            message(FATAL_ERROR "Failed to download NASM: ${_download_message}")
        endif()

        execute_process(
            COMMAND "${CMAKE_COMMAND}" -E tar xvf "${_zip_file}" --format=zip
            WORKING_DIRECTORY "${_tools_dir}"
            RESULT_VARIABLE _extract_code
            ERROR_VARIABLE _extract_error
            OUTPUT_QUIET
        )
        if(NOT _extract_code EQUAL 0)
            message(FATAL_ERROR "Failed to extract NASM archive: ${_extract_error}")
        endif()
    endif()

    if(NOT EXISTS "${_nasm_exe}")
        file(GLOB _nasm_candidates "${_tools_dir}/nasm-*/nasm.exe")
        list(LENGTH _nasm_candidates _candidate_count)
        if(_candidate_count GREATER 0)
            list(GET _nasm_candidates 0 _nasm_exe)
        endif()
    endif()

    if(EXISTS "${_nasm_exe}")
        set(${OUT_VAR} "${_nasm_exe}" PARENT_SCOPE)
        return()
    endif()

    set(${OUT_VAR} "" PARENT_SCOPE)
endfunction()

function(bpp_resolve_nasm OUT_VAR)
    find_program(_nasm_exe NAMES nasm nasm.exe)

    if(NOT _nasm_exe)
        bpp_bootstrap_nasm_windows(_bootstrapped_nasm)
        if(_bootstrapped_nasm)
            set(_nasm_exe "${_bootstrapped_nasm}")
        endif()
    endif()

    if(NOT _nasm_exe)
        bpp_fail_nasm_not_found()
    endif()

    set(${OUT_VAR} "${_nasm_exe}" PARENT_SCOPE)
endfunction()

function(bpp_resolve_linker OUT_VAR)
    if(WIN32)
        find_program(_linker_exe NAMES link.exe)
        if(NOT _linker_exe)
            find_program(_linker_exe NAMES lld-link lld-link.exe)
        endif()

        if(NOT _linker_exe)
            message(FATAL_ERROR
                "No Windows linker was found.\n"
                "Install one of the following:\n"
                "1) Visual Studio Build Tools (link.exe): https://aka.ms/vs/17/release/vs_BuildTools.exe\n"
                "2) LLVM (lld-link): https://releases.llvm.org/\n"
                "After installation, reopen the terminal and run CMake again."
            )
        endif()

        set(${OUT_VAR} "${_linker_exe}" PARENT_SCOPE)
        return()
    endif()

    find_program(_native_linker NAMES ld ld.lld lld)
    if(NOT _native_linker)
        message(FATAL_ERROR "No native linker was found (expected ld/ld.lld/lld).")
    endif()

    set(${OUT_VAR} "${_native_linker}" PARENT_SCOPE)
endfunction()
