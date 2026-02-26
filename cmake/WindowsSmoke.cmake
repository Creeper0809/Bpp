if(NOT WIN32)
    message(FATAL_ERROR "WindowsSmoke.cmake can only run on Windows hosts")
endif()

if(NOT DEFINED BPP_NASM_EXECUTABLE OR BPP_NASM_EXECUTABLE STREQUAL "")
    message(FATAL_ERROR "BPP_NASM_EXECUTABLE is not set")
endif()

if(NOT DEFINED BPP_LINKER_EXECUTABLE OR BPP_LINKER_EXECUTABLE STREQUAL "")
    message(FATAL_ERROR "BPP_LINKER_EXECUTABLE is not set")
endif()

set(_smoke_dir "${CMAKE_BINARY_DIR}/windows_smoke")
file(MAKE_DIRECTORY "${_smoke_dir}")

set(_asm_file "${_smoke_dir}/smoke.asm")
set(_obj_file "${_smoke_dir}/smoke.obj")
set(_exe_file "${_smoke_dir}/smoke.exe")

file(WRITE "${_asm_file}" "default rel\n")
file(APPEND "${_asm_file}" "extern ExitProcess\n")
file(APPEND "${_asm_file}" "global mainCRTStartup\n")
file(APPEND "${_asm_file}" "section .text\n")
file(APPEND "${_asm_file}" "mainCRTStartup:\n")
file(APPEND "${_asm_file}" "    sub rsp, 40\n")
file(APPEND "${_asm_file}" "    xor ecx, ecx\n")
file(APPEND "${_asm_file}" "    call ExitProcess\n")

execute_process(
    COMMAND "${BPP_NASM_EXECUTABLE}" -f win64 -O1 "${_asm_file}" -o "${_obj_file}"
    RESULT_VARIABLE _nasm_code
    ERROR_VARIABLE _nasm_error
)
if(NOT _nasm_code EQUAL 0)
    message(FATAL_ERROR "Windows smoke NASM failed: ${_nasm_error}")
endif()

execute_process(
    COMMAND "${BPP_LINKER_EXECUTABLE}" /nologo /subsystem:console /entry:mainCRTStartup /out:"${_exe_file}" "${_obj_file}" kernel32.lib
    RESULT_VARIABLE _link_code
    ERROR_VARIABLE _link_error
)
if(NOT _link_code EQUAL 0)
    message(FATAL_ERROR "Windows smoke link failed: ${_link_error}")
endif()

execute_process(
    COMMAND "${_exe_file}"
    RESULT_VARIABLE _run_code
)
if(NOT _run_code EQUAL 0)
    message(FATAL_ERROR "Windows smoke executable returned non-zero exit code: ${_run_code}")
endif()

message(STATUS "Windows smoke executable ran successfully.")
