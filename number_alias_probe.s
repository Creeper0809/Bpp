section .text
align 16
std_str__str_eq:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L0
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L0:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L2
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L2:
    mov rax, [rbp-16]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov [rbp-40], rax
    mov rax, [rbp-8]
    mov [rbp-48], rax
    mov rax, [rbp-24]
    mov [rbp-56], rax
    mov rax, 0
    mov [rbp-64], rax
.L4:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-40]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L6
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-64]
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L7
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L7:
.L5:
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-64]
    pop rbx
    mov [rax], rbx
    jmp .L4
.L6:
    mov rax, [rbp-40]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov [rbp-72], rax
    mov rax, [rbp-8]
    mov [rbp-80], rax
    mov rax, [rbp-24]
    mov [rbp-88], rax
    mov rax, [rbp-72]
    mov [rbp-96], rax
.L9:
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L11
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-96]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-96]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L12
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L12:
.L10:
    mov rax, [rbp-96]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-96]
    pop rbx
    mov [rax], rbx
    jmp .L9
.L11:
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_str__str_copy:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-8]
    mov [rbp-32], rax
    mov rax, [rbp-16]
    mov [rbp-40], rax
    mov rax, 0
    mov [rbp-48], rax
.L14:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L16
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-48]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L15:
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    jmp .L14
.L16:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_str__str_len:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    mov [rbp-16], rax
    mov rax, 0
    mov [rbp-24], rax
.L17:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L19
.L18:
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    jmp .L17
.L19:
    mov rax, [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_str__str_copy_segment:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_str__str_copy
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_str__str_concat:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-40], rax
    mov rax, [rbp-40]
    mov [rbp-48], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    call std_str__str_copy_segment
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    call std_str__str_copy_segment
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    add rax, rbx
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_str__str_concat3:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov [rbp-40], r8
    mov [rbp-48], r9
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-56], rax
    mov rax, [rbp-56]
    mov [rbp-64], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    push rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    call std_str__str_copy_segment
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    call std_str__str_copy_segment
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    call std_str__str_copy_segment
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    add rax, rbx
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-56]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_os__os_host_is_windows:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_os__os_sys_brk:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg0]
    pop rbx
    mov [rax], rbx
    mov rax , 12
    mov rdi , [ rel _gvar_std_os__g_syscall_arg0 ]
    syscall
    mov [ rel _gvar_std_os__g_syscall_ret ] , rax
    mov rax, [rel _gvar_std_os__g_syscall_ret]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_os__os_sys_write:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-8]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg0]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-16]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg1]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg2]
    pop rbx
    mov [rax], rbx
    mov rax , 1
    mov rdi , [ rel _gvar_std_os__g_syscall_arg0 ]
    mov rsi , [ rel _gvar_std_os__g_syscall_arg1 ]
    mov rdx , [ rel _gvar_std_os__g_syscall_arg2 ]
    syscall
    mov [ rel _gvar_std_os__g_syscall_ret ] , rax
    mov rax, [rel _gvar_std_os__g_syscall_ret]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_os__os_sys_read:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-8]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg0]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-16]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg1]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg2]
    pop rbx
    mov [rax], rbx
    mov rax , 0
    mov rdi , [ rel _gvar_std_os__g_syscall_arg0 ]
    mov rsi , [ rel _gvar_std_os__g_syscall_arg1 ]
    mov rdx , [ rel _gvar_std_os__g_syscall_arg2 ]
    syscall
    mov [ rel _gvar_std_os__g_syscall_ret ] , rax
    mov rax, [rel _gvar_std_os__g_syscall_ret]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_os__os_sys_open:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-8]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg0]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-16]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg1]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg2]
    pop rbx
    mov [rax], rbx
    mov rax , 2
    mov rdi , [ rel _gvar_std_os__g_syscall_arg0 ]
    mov rsi , [ rel _gvar_std_os__g_syscall_arg1 ]
    mov rdx , [ rel _gvar_std_os__g_syscall_arg2 ]
    syscall
    mov [ rel _gvar_std_os__g_syscall_ret ] , rax
    mov rax, [rel _gvar_std_os__g_syscall_ret]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_os__os_sys_close:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg0]
    pop rbx
    mov [rax], rbx
    mov rax , 3
    mov rdi , [ rel _gvar_std_os__g_syscall_arg0 ]
    syscall
    mov [ rel _gvar_std_os__g_syscall_ret ] , rax
    mov rax, [rel _gvar_std_os__g_syscall_ret]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_os__os_sys_fstat:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg0]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-16]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg1]
    pop rbx
    mov [rax], rbx
    mov rax , 5
    mov rdi , [ rel _gvar_std_os__g_syscall_arg0 ]
    mov rsi , [ rel _gvar_std_os__g_syscall_arg1 ]
    syscall
    mov [ rel _gvar_std_os__g_syscall_ret ] , rax
    mov rax, [rel _gvar_std_os__g_syscall_ret]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_os__os_sys_fork:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax , 57
    syscall
    mov [ rel _gvar_std_os__g_syscall_ret ] , rax
    mov rax, [rel _gvar_std_os__g_syscall_ret]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_os__os_sys_execve:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-8]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg0]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-16]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg1]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg2]
    pop rbx
    mov [rax], rbx
    mov rax , 59
    mov rdi , [ rel _gvar_std_os__g_syscall_arg0 ]
    mov rsi , [ rel _gvar_std_os__g_syscall_arg1 ]
    mov rdx , [ rel _gvar_std_os__g_syscall_arg2 ]
    syscall
    mov [ rel _gvar_std_os__g_syscall_ret ] , rax
    mov rax, [rel _gvar_std_os__g_syscall_ret]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_os__os_sys_wait4:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov rax, [rbp-8]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg0]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-16]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg1]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg2]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-32]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg3]
    pop rbx
    mov [rax], rbx
    mov rax , 61
    mov rdi , [ rel _gvar_std_os__g_syscall_arg0 ]
    mov rsi , [ rel _gvar_std_os__g_syscall_arg1 ]
    mov rdx , [ rel _gvar_std_os__g_syscall_arg2 ]
    mov r10 , [ rel _gvar_std_os__g_syscall_arg3 ]
    syscall
    mov [ rel _gvar_std_os__g_syscall_ret ] , rax
    mov rax, [rel _gvar_std_os__g_syscall_ret]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_os__os_sys_exit:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg0]
    pop rbx
    mov [rax], rbx
    mov rax , 60
    mov rdi , [ rel _gvar_std_os__g_syscall_arg0 ]
    syscall
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_os__os_sys_dup2:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg0]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-16]
    push rax
    lea rax, [rel _gvar_std_os__g_syscall_arg1]
    pop rbx
    mov [rax], rbx
    mov rax , 33
    mov rdi , [ rel _gvar_std_os__g_syscall_arg0 ]
    mov rsi , [ rel _gvar_std_os__g_syscall_arg1 ]
    syscall
    mov [ rel _gvar_std_os__g_syscall_ret ] , rax
    mov rax, [rel _gvar_std_os__g_syscall_ret]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_os__os_execute:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    call std_os__os_sys_fork
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L20
    mov rax, 1
    neg rax
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L20:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L22
    mov rax, 0
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_os__os_sys_execve
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L24
    mov rax, 127
    push rax
    pop rdi
    call std_os__os_sys_exit
.L24:
    mov rax, 1
    push rax
    pop rdi
    call std_os__os_sys_exit
    mov rax, [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L22:
    mov rax, 0
    mov [rbp-40], rax
    mov rax, 0
    push rax
    mov rax, 0
    push rax
    lea rax, [rbp-40]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    call std_os__os_sys_wait4
    mov rax, [rbp-40]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__sys_brk:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_os__os_sys_brk
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__sys_write:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_os__os_sys_write
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__sys_read:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_os__os_sys_read
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__sys_open:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_os__os_sys_open
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__sys_close:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_os__os_sys_close
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__sys_fstat:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_os__os_sys_fstat
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__sys_exit:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    call std_io__io_flush_out
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_os__os_sys_exit
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_set_output_fd:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    call std_io__io_flush_out
    mov rax, [rbp-8]
    push rax
    lea rax, [rel _gvar_std_io__g_out_fd]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_get_output_fd:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, [rel _gvar_std_io__g_out_fd]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L26
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L26:
    mov rax, [rel _gvar_std_io__g_out_fd]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_write_out:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    call std_io__io_get_output_fd
    mov [rbp-24], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_os__os_sys_write
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_ensure_out_buffer:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, [rel _gvar_std_io__g_out_buf]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L28
    mov rax, 4096
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    push rax
    lea rax, [rel _gvar_std_io__g_out_buf]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    lea rax, [rel _gvar_std_io__g_out_buf_len]
    pop rbx
    mov [rax], rbx
.L28:
    mov rax, [rel _gvar_std_io__g_out_buf]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_flush_out:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, [rel _gvar_std_io__g_out_buf]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L32
    mov rax, [rel _gvar_std_io__g_out_buf_len]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L33
.L32:
    mov eax, 1
.L33:
    test rax, rax
    jz .L30
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L30:
    mov rax, [rel _gvar_std_io__g_out_buf_len]
    push rax
    mov rax, [rel _gvar_std_io__g_out_buf]
    push rax
    pop rdi
    pop rsi
    call std_io__io_write_out
    mov rax, 0
    push rax
    lea rax, [rel _gvar_std_io__g_out_buf_len]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_write_out_buffered:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L36
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L37
.L36:
    mov eax, 1
.L37:
    test rax, rax
    jz .L34
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L34:
    call std_io__io_ensure_out_buffer
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L38
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__io_write_out
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L38:
    mov rax, [rbp-16]
    push rax
    mov rax, 4096
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setae al
    movzx rax, al
    test rax, rax
    jz .L40
    call std_io__io_flush_out
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__io_write_out
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L40:
    mov rax, [rel _gvar_std_io__g_out_buf_len]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 4096
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    test rax, rax
    jz .L42
    call std_io__io_flush_out
.L42:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rel _gvar_std_io__g_out_buf]
    push rax
    mov rax, [rel _gvar_std_io__g_out_buf_len]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_str__str_copy
    mov rax, [rel _gvar_std_io__g_out_buf_len]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rel _gvar_std_io__g_out_buf_len]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_read:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_io__sys_read
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_read_stdin:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    call std_io__io_flush_out
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_io__io_read
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_read_line:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L44
    mov rax, 0
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
.L44:
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L46
    mov rax, 2
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
.L46:
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L48
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L48:
    mov rax, 0
    mov [rbp-48], rax
    mov rax, [rbp-40]
    mov [rbp-56], rax
.L50:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L51
    mov rax, 1
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_io__io_read
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setle al
    movzx rax, al
    test rax, rax
    jz .L52
    jmp .L51
.L52:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L54
    jmp .L51
.L54:
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    jmp .L50
.L51:
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L58
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 13
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L59
.L58:
    xor eax, eax
.L59:
    test rax, rax
    jz .L56
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
.L56:
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L60
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
.L60:
    mov rax, [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_read_line_stdin:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_io__io_read_line
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__input:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__io_read_line_stdin
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_parse_u64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L64
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L65
.L64:
    mov eax, 1
.L65:
    test rax, rax
    jz .L62
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L62:
    mov rax, [rbp-8]
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 43
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L66
    mov rax, 1
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
.L66:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setae al
    movzx rax, al
    test rax, rax
    jz .L68
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L68:
    mov rax, 0
    mov [rbp-40], rax
.L70:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L71
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    mov [rbp-41], al
    movzx rax, byte [rbp-41]
    push rax
    mov rax, 48
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jnz .L74
    movzx rax, byte [rbp-41]
    push rax
    mov rax, 57
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L75
.L74:
    mov eax, 1
.L75:
    test rax, rax
    jz .L72
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L72:
    mov rax, [rbp-40]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    movzx rax, byte [rbp-41]
    push rax
    mov rax, 48
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    jmp .L70
.L71:
    mov rax, [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_parse_i64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L78
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L79
.L78:
    mov eax, 1
.L79:
    test rax, rax
    jz .L76
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L76:
    mov rax, [rbp-8]
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 45
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L80
    mov rax, 1
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    jmp .L81
.L80:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 43
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L82
    mov rax, 1
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
.L82:
.L81:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setae al
    movzx rax, al
    test rax, rax
    jz .L84
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L84:
    mov rax, 0
    mov [rbp-48], rax
.L86:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L87
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    mov [rbp-49], al
    movzx rax, byte [rbp-49]
    push rax
    mov rax, 48
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jnz .L90
    movzx rax, byte [rbp-49]
    push rax
    mov rax, 57
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L91
.L90:
    mov eax, 1
.L91:
    test rax, rax
    jz .L88
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L88:
    mov rax, [rbp-48]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    movzx rax, byte [rbp-49]
    push rax
    mov rax, 48
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    jmp .L86
.L87:
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L92
    mov rax, [rbp-48]
    push rax
    mov rax, 9223372036854775808
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L94
    mov rax, 0
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L94:
    mov rax, 0
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L92:
    mov rax, [rbp-48]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_parse_bool:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L96
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L96:
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L98
    mov rax, [rbp-8]
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 49
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L100
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L100:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 48
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L102
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L102:
.L98:
    mov rax, 4
    push rax
    lea rax, [rel _str106]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    call std_str__str_eq
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L104
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L104:
    mov rax, 5
    push rax
    lea rax, [rel _str109]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    call std_str__str_eq
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L107
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L107:
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_parse_f64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L112
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L113
.L112:
    mov eax, 1
.L113:
    test rax, rax
    jz .L110
    mov rax, [rel _flt114]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L110:
    mov rax, [rbp-8]
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 45
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L115
    mov rax, 1
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    jmp .L116
.L115:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 43
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L117
    mov rax, 1
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
.L117:
.L116:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setae al
    movzx rax, al
    test rax, rax
    jz .L119
    mov rax, [rel _flt114]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L119:
    mov rax, [rel _flt114]
    mov [rbp-48], rax
    mov rax, 0
    mov [rbp-56], rax
.L121:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L122
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    mov [rbp-57], al
    movzx rax, byte [rbp-57]
    push rax
    mov rax, 46
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L123
    jmp .L122
.L123:
    movzx rax, byte [rbp-57]
    push rax
    mov rax, 48
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jnz .L127
    movzx rax, byte [rbp-57]
    push rax
    mov rax, 57
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L128
.L127:
    mov eax, 1
.L128:
    test rax, rax
    jz .L125
    mov rax, [rel _flt114]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L125:
    mov rax, [rbp-48]
    push rax
    mov rax, [rel _flt129]
    mov rbx, rax
    pop rax
    movq xmm0, rax
    movq xmm1, rbx
    mulsd xmm0, xmm1
    movq rax, xmm0
    push rax
    movzx rax, byte [rbp-57]
    push rax
    mov rax, 48
    mov rbx, rax
    pop rax
    sub rax, rbx
    cvtsi2sd xmm0, rax
    movq rax, xmm0
    mov rbx, rax
    pop rax
    movq xmm0, rax
    movq xmm1, rbx
    addsd xmm0, xmm1
    movq rax, xmm0
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    lea rax, [rbp-56]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    jmp .L121
.L122:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L132
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 46
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L133
.L132:
    xor eax, eax
.L133:
    test rax, rax
    jz .L130
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    mov rax, [rel _flt134]
    mov [rbp-65], rax
.L135:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L136
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    mov [rbp-66], al
    movzx rax, byte [rbp-66]
    push rax
    mov rax, 48
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jnz .L139
    movzx rax, byte [rbp-66]
    push rax
    mov rax, 57
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L140
.L139:
    mov eax, 1
.L140:
    test rax, rax
    jz .L137
    mov rax, [rel _flt114]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L137:
    mov rax, [rbp-48]
    push rax
    movzx rax, byte [rbp-66]
    push rax
    mov rax, 48
    mov rbx, rax
    pop rax
    sub rax, rbx
    cvtsi2sd xmm0, rax
    movq rax, xmm0
    push rax
    mov rax, [rbp-65]
    mov rbx, rax
    pop rax
    movq xmm0, rax
    movq xmm1, rbx
    mulsd xmm0, xmm1
    movq rax, xmm0
    mov rbx, rax
    pop rax
    movq xmm0, rax
    movq xmm1, rbx
    addsd xmm0, xmm1
    movq rax, xmm0
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-65]
    push rax
    mov rax, [rel _flt129]
    mov rbx, rax
    pop rax
    movq xmm0, rax
    movq xmm1, rbx
    divsd xmm0, xmm1
    movq rax, xmm0
    push rax
    lea rax, [rbp-65]
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    lea rax, [rbp-56]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    jmp .L135
.L136:
.L130:
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L141
    mov rax, [rel _flt114]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L141:
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L143
    mov rax, [rel _flt114]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    movq xmm0, rax
    movq xmm1, rbx
    subsd xmm0, xmm1
    movq rax, xmm0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L143:
    mov rax, [rbp-48]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__input_slice:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 0
    mov [rbp-24], rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__input
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L145
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
.L145:
    mov rax, [rbp-32]
    mov rbx, rax
    mov rax, [rbp-24]
    mov rdx, rax
    mov rax, rbx
    push rax
    push rdx
    pop rdx
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__input_u64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 0
    mov [rbp-24], rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__input
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L147
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
.L147:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rdi
    pop rsi
    call std_io__io_parse_u64
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__input_i64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 0
    mov [rbp-24], rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__input
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L149
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
.L149:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rdi
    pop rsi
    call std_io__io_parse_i64
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__input_u8:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__input_u64
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__input_u16:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__input_u64
    and rax, 65535
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__input_u32:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__input_u64
    mov eax, eax
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__input_i8:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__input_i64
    movsx rax, al
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__input_i16:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__input_i64
    movsx rax, ax
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__input_i32:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__input_i64
    movsxd rax, eax
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__input_bool:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 0
    mov [rbp-24], rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__input
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L151
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
.L151:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rdi
    pop rsi
    call std_io__io_parse_bool
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__input_f64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 0
    mov [rbp-24], rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__input
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L153
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
.L153:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rdi
    pop rsi
    call std_io__io_parse_f64
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__input_read:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__io_read_stdin
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__heap_align8:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, 0
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    lea rax, [rbp-16]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-8]
    push rax
    mov rax, 8
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    and rax, rbx
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__heap_block_get_size:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__heap_block_set_size:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    mov [rbp-24], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__heap_block_get_next:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__heap_block_set_next:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    mov [rbp-24], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__heap_free_list_contains:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rel _gvar_std_io__heap_free_head]
    mov [rbp-16], rax
.L155:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L156
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L157
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L157:
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_io__heap_block_get_next
    push rax
    lea rax, [rbp-16]
    pop rbx
    mov [rax], rbx
    jmp .L155
.L156:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__heap_free_list_coalesce_adjacent:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, [rel _gvar_std_io__heap_free_head]
    mov [rbp-8], rax
.L159:
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L160
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_io__heap_block_get_next
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L161
    jmp .L160
.L161:
    mov rax, [rbp-8]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_io__heap_block_get_size
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L163
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_io__heap_block_get_size
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_io__heap_block_get_size
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__heap_block_set_size
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_io__heap_block_get_next
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__heap_block_set_next
    jmp .L159
.L163:
    mov rax, [rbp-16]
    push rax
    lea rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    jmp .L159
.L160:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__heap_free_list_insert:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L165
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L165:
    mov rax, [rel _gvar_std_io__heap_free_head]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L169
    mov rax, [rbp-8]
    push rax
    mov rax, [rel _gvar_std_io__heap_free_head]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L170
.L169:
    mov eax, 1
.L170:
    test rax, rax
    jz .L167
    mov rax, [rel _gvar_std_io__heap_free_head]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__heap_block_set_next
    mov rax, [rbp-8]
    push rax
    lea rax, [rel _gvar_std_io__heap_free_head]
    pop rbx
    mov [rax], rbx
    call std_io__heap_free_list_coalesce_adjacent
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L167:
    mov rax, [rel _gvar_std_io__heap_free_head]
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_io__heap_block_get_next
    mov [rbp-24], rax
.L171:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L173
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L174
.L173:
    xor eax, eax
.L174:
    test rax, rax
    jz .L172
    mov rax, [rbp-24]
    push rax
    lea rax, [rbp-16]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    pop rdi
    call std_io__heap_block_get_next
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    jmp .L171
.L172:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__heap_block_set_next
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_io__heap_block_set_next
    call std_io__heap_free_list_coalesce_adjacent
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__heap_try_alloc_from_free_list:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, 0
    mov [rbp-16], rax
    mov rax, [rel _gvar_std_io__heap_free_head]
    mov [rbp-24], rax
.L175:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L176
    mov rax, [rbp-24]
    push rax
    pop rdi
    call std_io__heap_block_get_size
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setae al
    movzx rax, al
    test rax, rax
    jz .L177
    mov rax, [rbp-24]
    push rax
    pop rdi
    call std_io__heap_block_get_next
    mov [rbp-40], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 16
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    add rax, rbx
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setae al
    movzx rax, al
    test rax, rax
    jz .L179
    mov rax, [rbp-24]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-56], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    pop rsi
    call std_io__heap_block_set_size
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    pop rsi
    call std_io__heap_block_set_next
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L181
    mov rax, [rbp-56]
    push rax
    lea rax, [rel _gvar_std_io__heap_free_head]
    pop rbx
    mov [rax], rbx
    jmp .L182
.L181:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_io__heap_block_set_next
.L182:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    pop rsi
    call std_io__heap_block_set_size
    jmp .L180
.L179:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L183
    mov rax, [rbp-40]
    push rax
    lea rax, [rel _gvar_std_io__heap_free_head]
    pop rbx
    mov [rax], rbx
    jmp .L184
.L183:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_io__heap_block_set_next
.L184:
.L180:
    mov rax, 0
    push rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    pop rsi
    call std_io__heap_block_set_next
    mov rax, [rbp-24]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L177:
    mov rax, [rbp-24]
    push rax
    lea rax, [rbp-16]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    pop rdi
    call std_io__heap_block_get_next
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    jmp .L175
.L176:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__heap_alloc:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L185
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L185:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_io__heap_align8
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_io__heap_try_alloc_from_free_list
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L187
    mov rax, [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L187:
    mov rax, [rel _gvar_std_io__heap_inited]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L189
    mov rax, 0
    push rax
    pop rdi
    call std_os__os_sys_brk
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    lea rax, [rel _gvar_std_io__heap_base]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-32]
    push rax
    lea rax, [rel _gvar_std_io__heap_brk]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-32]
    push rax
    lea rax, [rel _gvar_std_io__heap_reserved_end]
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    lea rax, [rel _gvar_std_io__heap_inited]
    pop rbx
    mov [rax], rbx
.L189:
    mov rax, [rel _gvar_std_io__heap_brk]
    push rax
    pop rdi
    call std_io__heap_align8
    mov [rbp-40], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-48], rax
    mov rax, [rbp-40]
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rel _gvar_std_io__heap_reserved_end]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L191
    mov rax, [rbp-48]
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rax, 1048576
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L193
    mov rax, 1048576
    push rax
    lea rax, [rbp-72]
    pop rbx
    mov [rax], rbx
.L193:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-72]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-80], rax
    mov rax, [rbp-80]
    push rax
    pop rdi
    call std_os__os_sys_brk
    mov [rbp-88], rax
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-80]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L195
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L195:
    mov rax, [rbp-80]
    push rax
    lea rax, [rel _gvar_std_io__heap_reserved_end]
    pop rbx
    mov [rax], rbx
.L191:
    mov rax, [rbp-64]
    push rax
    lea rax, [rel _gvar_std_io__heap_brk]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    pop rsi
    call std_io__heap_block_set_size
    mov rax, 0
    push rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    pop rsi
    call std_io__heap_block_set_next
    mov rax, [rbp-56]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__heap_free:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L197
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L197:
    mov rax, [rel _gvar_std_io__heap_inited]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L199
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L199:
    mov rax, [rbp-8]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L201
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L201:
    mov rax, [rbp-8]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rel _gvar_std_io__heap_base]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jnz .L205
    mov rax, [rbp-16]
    push rax
    mov rax, [rel _gvar_std_io__heap_brk]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setae al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L206
.L205:
    mov eax, 1
.L206:
    test rax, rax
    jz .L203
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L203:
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_io__heap_free_list_contains
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L207
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L207:
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_io__heap_block_get_size
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L209
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L209:
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_io__heap_free_list_insert
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_panic_invalid_cstr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, 8
    push rax
    lea rax, [rel _str211]
    push rax
    mov rax, 2
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_os__os_sys_write
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_str__str_len
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, 2
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_os__os_sys_write
    mov rax, 1
    push rax
    lea rax, [rel _str212]
    push rax
    mov rax, 2
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_os__os_sys_write
    mov rax, 1
    push rax
    pop rdi
    call std_os__os_sys_exit
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_guard_cstr_ptr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L215
    mov rax, [rbp-8]
    push rax
    mov rax, 4096
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L216
.L215:
    xor eax, eax
.L216:
    test rax, rax
    jz .L213
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_io__io_panic_invalid_cstr
.L213:
    mov rax, [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_guard_required_cstr_ptr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L217
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_io__io_panic_invalid_cstr
.L217:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__io_guard_cstr_ptr
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__emitln:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    lea rax, [rel _str219]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__io_guard_required_cstr_ptr
    push rax
    lea rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    call std_io__io_flush_out
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_str__str_len
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__io_write_out
    mov rax, 1
    push rax
    lea rax, [rel _str212]
    push rax
    pop rdi
    pop rsi
    call std_io__io_write_out
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__emit:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L220
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L220:
    lea rax, [rel _str222]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__io_guard_cstr_ptr
    push rax
    lea rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_str__str_len
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__emit_len
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__emit_len:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L223
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L223:
    lea rax, [rel _str225]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__io_guard_cstr_ptr
    push rax
    lea rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    call std_io__io_flush_out
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__io_write_out
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__print:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L226
    lea rax, [rel _str228]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__io_guard_cstr_ptr
    push rax
    lea rax, [rbp-8]
    pop rbx
    mov [rax], rbx
.L226:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__io_write_out_buffered
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__print_nl:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, 1
    push rax
    lea rax, [rel _str212]
    push rax
    pop rdi
    pop rsi
    call std_io__io_write_out_buffered
    call std_io__io_flush_out
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__println:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L229
    lea rax, [rel _str231]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__io_guard_cstr_ptr
    push rax
    lea rax, [rbp-8]
    pop rbx
    mov [rax], rbx
.L229:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__io_write_out_buffered
    mov rax, 1
    push rax
    lea rax, [rel _str212]
    push rax
    pop rdi
    pop rsi
    call std_io__io_write_out_buffered
    call std_io__io_flush_out
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__print_cstr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    lea rax, [rel _str232]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__io_guard_required_cstr_ptr
    push rax
    lea rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_str__str_len
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__print
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__println_cstr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    lea rax, [rel _str233]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__io_guard_required_cstr_ptr
    push rax
    lea rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_str__str_len
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__println
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_u64_to_ascii:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    mov [rbp-24], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L234
    mov rax, 48
    and rax, 255
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L234:
    mov rax, 0
    mov [rbp-32], rax
    mov rax, [rbp-16]
    mov [rbp-40], rax
.L236:
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L237
    mov rax, [rbp-40]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov rax, rdx
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 48
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-40]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    jmp .L236
.L237:
    mov rax, [rbp-32]
    push rax
    mov rax, 2
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov [rbp-56], rax
    mov rax, 0
    mov [rbp-64], rax
.L238:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-56]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L240
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    mov rax, [rbp-64]
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov [rbp-72], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-64]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    mov [rbp-73], al
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-72]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-64]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    movzx rax, byte [rbp-73]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-72]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L239:
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-64]
    pop rbx
    mov [rax], rbx
    jmp .L238
.L240:
    mov rax, [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__print_u64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    call std_io__io_flush_out
    mov rax, [rel _gvar_std_io__g_print_u64_buf]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L241
    mov rax, 32
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    push rax
    lea rax, [rel _gvar_std_io__g_print_u64_buf]
    pop rbx
    mov [rax], rbx
.L241:
    mov rax, [rel _gvar_std_io__g_print_u64_buf]
    mov [rbp-16], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_io__io_u64_to_ascii
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_io__io_write_out
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__print_i64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    call std_io__io_flush_out
    mov rax, [rbp-8]
    push rax
    mov rax, 9223372036854775808
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L245
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L246
.L245:
    xor eax, eax
.L246:
    test rax, rax
    jz .L243
    mov rax, 20
    push rax
    lea rax, [rel _str247]
    push rax
    pop rdi
    pop rsi
    call std_io__io_write_out
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L243:
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L248
    mov rax, 1
    push rax
    lea rax, [rel _str250]
    push rax
    pop rdi
    pop rsi
    call std_io__io_write_out
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    pop rdi
    call std_io__print_u64
    jmp .L249
.L248:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_io__print_u64
.L249:
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_alloc_cstr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L251
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L251:
    mov rax, [rbp-16]
    mov [rbp-24], rax
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__io_hex_digit:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L253
    mov rax, 48
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L253:
    mov rax, 87
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__to_str_u64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, 32
    push rax
    pop rdi
    call std_io__io_alloc_cstr
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L255
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L255:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_io__io_u64_to_ascii
    mov [rbp-24], rax
    mov rax, [rbp-16]
    mov [rbp-32], rax
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-24]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__to_str_i64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 9223372036854775808
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L259
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L260
.L259:
    xor eax, eax
.L260:
    test rax, rax
    jz .L257
    lea rax, [rel _str247]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L257:
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setge al
    movzx rax, al
    test rax, rax
    jz .L261
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_io__to_str_u64
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L261:
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_io__to_str_u64
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    call std_str__str_len
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    push rax
    lea rax, [rel _str250]
    push rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    call std_str__str_concat
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__to_str_bool:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L263
    lea rax, [rel _str106]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L263:
    lea rax, [rel _str109]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__to_str_bytes:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L265
    mov rax, 0
    push rax
    pop rdi
    call std_io__io_alloc_cstr
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L265:
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_io__io_alloc_cstr
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L267
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L267:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_str__str_copy
    mov rax, [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__to_str_ptr_value:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, 18
    push rax
    pop rdi
    call std_io__io_alloc_cstr
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L269
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L269:
    mov rax, [rbp-16]
    mov [rbp-24], rax
    mov rax, 48
    and rax, 255
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 120
    and rax, 255
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 0
    mov [rbp-32], rax
.L271:
    mov rax, [rbp-32]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L273
    mov rax, 15
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    mov rax, 4
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov [rbp-40], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-40]
    mov rbx, rax
    pop rax
    mov rcx, rbx
    shr rax, cl
    push rax
    mov rax, 15
    mov rbx, rax
    pop rax
    and rax, rbx
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    pop rdi
    call std_io__io_hex_digit
    and rax, 255
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    add rax, rbx
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L272:
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    jmp .L271
.L273:
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 18
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__to_str_f64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    movq xmm0, rax
    movq xmm1, rbx
    ucomisd xmm0, xmm1
    setne al
    movzx rax, al
    test rax, rax
    jz .L274
    lea rax, [rel _str276]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L274:
    mov rax, 0
    mov [rbp-16], rax
    mov rax, [rbp-8]
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rel _flt114]
    mov rbx, rax
    pop rax
    movq xmm0, rax
    movq xmm1, rbx
    ucomisd xmm0, xmm1
    setb al
    movzx rax, al
    test rax, rax
    jz .L277
    mov rax, 1
    push rax
    lea rax, [rbp-16]
    pop rbx
    mov [rax], rbx
    mov rax, [rel _flt114]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    movq xmm0, rax
    movq xmm1, rbx
    subsd xmm0, xmm1
    movq rax, xmm0
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L277:
    mov rax, [rbp-24]
    movq xmm0, rax
    mov rdx, 4890909195324358656
    movq xmm1, rdx
    ucomisd xmm0, xmm1
    jb .L279
    subsd xmm0, xmm1
    cvttsd2si rax, xmm0
    bts rax, 63
    jmp .L280
.L279:
    cvttsd2si rax, xmm0
.L280:
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    test rax, rax
    jns .L281
    shr rax, 1
    adc rax, 0
    cvtsi2sd xmm0, rax
    addsd xmm0, xmm0
    jmp .L282
.L281:
    cvtsi2sd xmm0, rax
.L282:
    movq rax, xmm0
    mov rbx, rax
    pop rax
    movq xmm0, rax
    movq xmm1, rbx
    subsd xmm0, xmm1
    movq rax, xmm0
    mov [rbp-40], rax
    mov rax, 64
    push rax
    pop rdi
    call std_io__io_alloc_cstr
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L283
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L283:
    mov rax, [rbp-48]
    mov [rbp-56], rax
    mov rax, 0
    mov [rbp-64], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L285
    mov rax, 45
    and rax, 255
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-64]
    pop rbx
    mov [rax], rbx
.L285:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-64]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    pop rdi
    pop rsi
    call std_io__io_u64_to_ascii
    mov [rbp-72], rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-72]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-64]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-40]
    push rax
    mov rax, [rel _flt114]
    mov rbx, rax
    pop rax
    movq xmm0, rax
    movq xmm1, rbx
    ucomisd xmm0, xmm1
    setbe al
    movzx rax, al
    test rax, rax
    jz .L287
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-48]
    mov rsp, rbp
    pop rbp
    ret
.L287:
    mov rax, 46
    and rax, 255
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-64]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-64]
    mov [rbp-80], rax
    mov rax, 0
    mov [rbp-88], rax
.L289:
    mov rax, [rbp-88]
    push rax
    mov rax, 6
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L291
    mov rax, [rbp-40]
    push rax
    mov rax, [rel _flt129]
    mov rbx, rax
    pop rax
    movq xmm0, rax
    movq xmm1, rbx
    mulsd xmm0, xmm1
    movq rax, xmm0
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-40]
    movq xmm0, rax
    mov rdx, 4890909195324358656
    movq xmm1, rdx
    ucomisd xmm0, xmm1
    jb .L292
    subsd xmm0, xmm1
    cvttsd2si rax, xmm0
    bts rax, 63
    jmp .L293
.L292:
    cvttsd2si rax, xmm0
.L293:
    mov [rbp-96], rax
    mov rax, [rbp-96]
    push rax
    mov rax, 9
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L294
    mov rax, 9
    push rax
    lea rax, [rbp-96]
    pop rbx
    mov [rax], rbx
.L294:
    mov rax, 48
    push rax
    mov rax, [rbp-96]
    mov rbx, rax
    pop rax
    add rax, rbx
    and rax, 255
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-64]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-96]
    test rax, rax
    jns .L296
    shr rax, 1
    adc rax, 0
    cvtsi2sd xmm0, rax
    addsd xmm0, xmm0
    jmp .L297
.L296:
    cvtsi2sd xmm0, rax
.L297:
    movq rax, xmm0
    mov rbx, rax
    pop rax
    movq xmm0, rax
    movq xmm1, rbx
    subsd xmm0, xmm1
    movq rax, xmm0
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
.L290:
    mov rax, [rbp-88]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-88]
    pop rbx
    mov [rax], rbx
    jmp .L289
.L291:
.L298:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-80]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L300
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 48
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L301
.L300:
    xor eax, eax
.L301:
    test rax, rax
    jz .L299
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    lea rax, [rbp-64]
    pop rbx
    mov [rax], rbx
    jmp .L298
.L299:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-80]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L302
    mov rax, [rbp-80]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    lea rax, [rbp-64]
    pop rbx
    mov [rax], rbx
.L302:
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-48]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__to_str_slice_meta:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_io__to_str_u64
    mov [rbp-16], rax
    mov rax, 1
    push rax
    lea rax, [rel _str304]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_str__str_len
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 11
    push rax
    lea rax, [rel _str305]
    push rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop r8
    pop r9
    call std_str__str_concat3
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__to_str_array_meta:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_io__to_str_u64
    mov [rbp-16], rax
    mov rax, 1
    push rax
    lea rax, [rel _str304]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_str__str_len
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 11
    push rax
    lea rax, [rel _str306]
    push rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop r8
    pop r9
    call std_str__str_concat3
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__to_str_struct_meta:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 1
    push rax
    lea rax, [rel _str304]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    push rax
    lea rax, [rel _str307]
    push rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop r8
    pop r9
    call std_str__str_concat3
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__to_str_func_meta:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    lea rax, [rel _str308]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__to_str_null:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    lea rax, [rel _str309]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_io__to_str_u8_slice:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-16], rdi
    mov [rbp-8], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_io__to_str_bytes
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_mem__memset:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-16]
    push rax
    mov rax, 255
    mov rbx, rax
    pop rax
    and rax, rbx
    mov [rbp-32], rax
    mov rax, [rbp-8]
    mov [rbp-40], rax
    mov rax, 0
    mov [rbp-48], rax
.L310:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L312
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L311:
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    jmp .L310
.L312:
    mov rax, [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_mem__malloc:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_io__heap_alloc
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_mem__free:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_io__heap_free
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_char__is_alpha:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 65
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setae al
    movzx rax, al
    test rax, rax
    jz .L315
    mov rax, [rbp-8]
    push rax
    mov rax, 90
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setbe al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L316
.L315:
    xor eax, eax
.L316:
    test rax, rax
    jz .L313
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L313:
    mov rax, [rbp-8]
    push rax
    mov rax, 97
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setae al
    movzx rax, al
    test rax, rax
    jz .L319
    mov rax, [rbp-8]
    push rax
    mov rax, 122
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setbe al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L320
.L319:
    xor eax, eax
.L320:
    test rax, rax
    jz .L317
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L317:
    mov rax, [rbp-8]
    push rax
    mov rax, 95
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L321
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L321:
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_char__is_digit:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 48
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setae al
    movzx rax, al
    test rax, rax
    jz .L325
    mov rax, [rbp-8]
    push rax
    mov rax, 57
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setbe al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L326
.L325:
    xor eax, eax
.L326:
    test rax, rax
    jz .L323
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L323:
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_char__is_alnum:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_char__is_alpha
    test rax, rax
    jz .L327
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L327:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_char__is_digit
    test rax, rax
    jz .L329
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L329:
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_char__is_whitespace:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 32
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L331
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L331:
    mov rax, [rbp-8]
    push rax
    mov rax, 9
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L333
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L333:
    mov rax, [rbp-8]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L335
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L335:
    mov rax, [rbp-8]
    push rax
    mov rax, 13
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L337
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L337:
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_path__path_dirname:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 1
    neg rax
    mov [rbp-24], rax
    mov rax, [rbp-8]
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
.L339:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L341
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 47
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L344
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 92
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L345
.L344:
    mov eax, 1
.L345:
    test rax, rax
    jz .L342
    mov rax, [rbp-40]
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L342:
.L340:
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    jmp .L339
.L341:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L346
    mov rax, 2
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-48], rax
    mov rax, [rbp-48]
    mov [rbp-56], rax
    mov rax, 46
    and rax, 255
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-48]
    mov rsp, rbp
    pop rbp
    ret
.L346:
    mov rax, [rbp-24]
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rax, 2
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-72], rax
    mov rax, [rbp-72]
    mov [rbp-80], rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-72]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_str__str_copy
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-64]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-72]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_path__path_basename_noext:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 1
    neg rax
    mov [rbp-24], rax
    mov rax, [rbp-8]
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
.L348:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L350
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 47
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L353
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 92
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L354
.L353:
    mov eax, 1
.L354:
    test rax, rax
    jz .L351
    mov rax, [rbp-40]
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L351:
.L349:
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    jmp .L348
.L350:
    mov rax, 0
    mov [rbp-48], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setge al
    movzx rax, al
    test rax, rax
    jz .L355
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
.L355:
    mov rax, 1
    neg rax
    mov [rbp-56], rax
    mov rax, [rbp-48]
    mov [rbp-64], rax
.L357:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L359
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-64]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 46
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L360
    mov rax, [rbp-64]
    push rax
    lea rax, [rbp-56]
    pop rbx
    mov [rax], rbx
.L360:
.L358:
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-64]
    pop rbx
    mov [rax], rbx
    jmp .L357
.L359:
    mov rax, [rbp-16]
    mov [rbp-72], rax
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setge al
    movzx rax, al
    test rax, rax
    jz .L362
    mov rax, [rbp-56]
    push rax
    lea rax, [rbp-72]
    pop rbx
    mov [rax], rbx
.L362:
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L364
    mov rax, [rbp-48]
    push rax
    lea rax, [rbp-72]
    pop rbx
    mov [rax], rbx
.L364:
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov [rbp-80], rax
    mov rax, [rbp-80]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-88], rax
    mov rax, [rbp-88]
    mov [rbp-96], rax
    mov rax, [rbp-80]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L366
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-88]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_str__str_copy
.L366:
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-80]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-88]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__init_stack_trace:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, [rel _gvar_std_util__g_stack_initialized]
    test rax, rax
    jz .L368
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L368:
    mov rax, 128
    push rax
    mov rax, 40
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    push rax
    lea rax, [rel _gvar_std_util__g_stack_frames]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    lea rax, [rel _gvar_std_util__g_stack_depth]
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    lea rax, [rel _gvar_std_util__g_stack_initialized]
    pop rbx
    mov [rax], rbx
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__push_trace:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rel _gvar_std_util__g_stack_initialized]
    test rax, rax
    setz al
    movzx rax, al
    test rax, rax
    jnz .L372
    mov rax, [rel _gvar_std_util__g_stack_frames]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L373
.L372:
    mov eax, 1
.L373:
    test rax, rax
    jz .L370
    call std_util__init_stack_trace
.L370:
    mov rax, [rel _gvar_std_util__g_stack_frames]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L374
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L374:
    mov rax, [rel _gvar_std_util__g_stack_depth]
    push rax
    mov rax, 128
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setae al
    movzx rax, al
    test rax, rax
    jz .L376
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L376:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_str__str_len
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_str__str_len
    mov [rbp-40], rax
    mov rax, [rel _gvar_std_util__g_stack_frames]
    push rax
    mov rax, [rel _gvar_std_util__g_stack_depth]
    push rax
    mov rax, 40
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-48], rax
    mov rax, [rbp-48]
    mov [rbp-56], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-56]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-56]
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-56]
    add rax, 16
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-56]
    add rax, 24
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-56]
    add rax, 32
    pop rbx
    mov [rax], rbx
    mov rax, [rel _gvar_std_util__g_stack_depth]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rel _gvar_std_util__g_stack_depth]
    pop rbx
    mov [rax], rbx
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__pop_trace:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, [rel _gvar_std_util__g_stack_initialized]
    test rax, rax
    setz al
    movzx rax, al
    test rax, rax
    jz .L378
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L378:
    mov rax, [rel _gvar_std_util__g_stack_depth]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L380
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L380:
    mov rax, [rel _gvar_std_util__g_stack_depth]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    lea rax, [rel _gvar_std_util__g_stack_depth]
    pop rbx
    mov [rax], rbx
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__print_stack_trace:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, [rel _gvar_std_util__g_stack_initialized]
    test rax, rax
    setz al
    movzx rax, al
    test rax, rax
    jz .L382
    lea rax, [rel _str384]
    push rax
    pop rdi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L382:
    mov rax, [rel _gvar_std_util__g_stack_depth]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L385
    lea rax, [rel _str387]
    push rax
    pop rdi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L385:
    lea rax, [rel _str388]
    push rax
    pop rdi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
    mov rax, [rel _gvar_std_util__g_stack_depth]
    mov [rbp-8], rax
.L389:
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L391
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov [rbp-16], rax
    mov rax, [rel _gvar_std_util__g_stack_frames]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 40
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-24], rax
    mov rax, [rbp-24]
    mov [rbp-32], rax
    mov rax, [rbp-32]
    mov rax, [rax]
    mov [rbp-40], rax
    mov rax, [rbp-32]
    add rax, 8
    mov rax, [rax]
    mov [rbp-48], rax
    mov rax, [rbp-32]
    add rax, 16
    mov rax, [rax]
    mov [rbp-56], rax
    mov rax, [rbp-32]
    add rax, 24
    mov rax, [rax]
    mov [rbp-64], rax
    mov rax, [rbp-32]
    add rax, 32
    mov rax, [rax]
    mov [rbp-72], rax
    lea rax, [rel _str392]
    push rax
    pop rdi
    call std_util__emit_stderr
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr_len
    lea rax, [rel _str393]
    push rax
    pop rdi
    call std_util__emit_stderr
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr_len
    lea rax, [rel _str394]
    push rax
    pop rdi
    call std_util__emit_stderr
    mov rax, [rbp-72]
    push rax
    pop rdi
    call std_util__emit_i64_stderr
    lea rax, [rel _str395]
    push rax
    pop rdi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
.L390:
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    lea rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    jmp .L389
.L391:
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__set_parsing_context:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-8]
    push rax
    lea rax, [rel _gvar_std_util__g_current_func_name]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-16]
    push rax
    lea rax, [rel _gvar_std_util__g_current_func_name_len]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    lea rax, [rel _gvar_std_util__g_current_func_line]
    pop rbx
    mov [rax], rbx
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__clear_parsing_context:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, 0
    push rax
    lea rax, [rel _gvar_std_util__g_current_func_name]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    lea rax, [rel _gvar_std_util__g_current_func_name_len]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    lea rax, [rel _gvar_std_util__g_current_func_line]
    pop rbx
    mov [rax], rbx
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__begin_error_capture:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, [rel _gvar_std_util__g_error_buffer]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L396
    mov rax, 512
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    push rax
    lea rax, [rel _gvar_std_util__g_error_buffer]
    pop rbx
    mov [rax], rbx
.L396:
    mov rax, 0
    push rax
    lea rax, [rel _gvar_std_util__g_error_buffer_pos]
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    lea rax, [rel _gvar_std_util__g_capturing_error]
    pop rbx
    mov [rax], rbx
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__end_error_capture:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, 0
    push rax
    lea rax, [rel _gvar_std_util__g_capturing_error]
    pop rbx
    mov [rax], rbx
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__set_error_context:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    lea rax, [rel _gvar_std_util__g_last_error_msg]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-16]
    push rax
    lea rax, [rel _gvar_std_util__g_last_error_len]
    pop rbx
    mov [rax], rbx
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__emit_error:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rel _str398]
    push rax
    pop rdi
    call std_util__emit_stderr
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr_len
    call std_util__emit_stderr_nl
    mov rax, [rbp-8]
    push rax
    lea rax, [rel _gvar_std_util__g_last_error_msg]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-16]
    push rax
    lea rax, [rel _gvar_std_util__g_last_error_len]
    pop rbx
    mov [rax], rbx
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__panic:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    call std_util__end_error_capture
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L399
    lea rax, [rel _str211]
    push rax
    pop rdi
    call std_util__emit_stderr
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_str__str_len
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr_len
    call std_util__emit_stderr_nl
.L399:
    mov rax, [rel _gvar_std_util__g_current_func_name]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L401
    call std_util__emit_stderr_nl
    lea rax, [rel _str403]
    push rax
    pop rdi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
    lea rax, [rel _str404]
    push rax
    pop rdi
    call std_util__emit_stderr
    mov rax, [rel _gvar_std_util__g_current_func_name_len]
    push rax
    mov rax, [rel _gvar_std_util__g_current_func_name]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr_len
    lea rax, [rel _str405]
    push rax
    pop rdi
    call std_util__emit_stderr
    mov rax, [rel _gvar_std_util__g_current_func_line]
    push rax
    pop rdi
    call std_util__emit_i64_stderr
    lea rax, [rel _str395]
    push rax
    pop rdi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
.L401:
    call std_util__emit_stderr_nl
    lea rax, [rel _str406]
    push rax
    pop rdi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
    call std_util__print_stack_trace
    mov rax, [rel _gvar_std_util__g_error_buffer_pos]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L407
    call std_util__emit_stderr_nl
    lea rax, [rel _str409]
    push rax
    pop rdi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
    mov rax, [rel _gvar_std_util__g_error_buffer_pos]
    push rax
    mov rax, [rel _gvar_std_util__g_error_buffer]
    push rax
    mov rax, 2
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_io__sys_write
    call std_util__emit_stderr_nl
.L407:
    call std_util__emit_stderr_nl
    mov rax, 1
    push rax
    pop rdi
    call std_io__sys_exit
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__debug_fail:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    lea rax, [rel _str410]
    push rax
    pop rdi
    call std_util__emit_stderr
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr_len
    lea rax, [rel _str411]
    push rax
    pop rdi
    call std_util__emit_stderr
    mov rax, [rbp-24]
    push rax
    pop rdi
    call std_util__emit_u64_stderr
    call std_util__emit_stderr_nl
    call std_util__print_stack_trace
    mov rax, 1
    push rax
    pop rdi
    call std_io__sys_exit
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__emit_stderr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L412
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L412:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_str__str_len
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr_len
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__emit_stderr_len:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rel _gvar_std_util__g_capturing_error]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L414
    mov rax, [rel _gvar_std_util__g_error_buffer_pos]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 512
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L416
    mov rax, [rel _gvar_std_util__g_error_buffer]
    mov [rbp-24], rax
    mov rax, [rbp-8]
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
.L418:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L420
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rel _gvar_std_util__g_error_buffer_pos]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rel _gvar_std_util__g_error_buffer_pos]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rel _gvar_std_util__g_error_buffer_pos]
    pop rbx
    mov [rax], rbx
.L419:
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    jmp .L418
.L420:
.L416:
    jmp .L415
.L414:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, 2
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_io__sys_write
.L415:
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__emit_stderr_nl:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, 1
    push rax
    lea rax, [rel _str212]
    push rax
    mov rax, 2
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_io__sys_write
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__warn:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rel _str421]
    push rax
    pop rdi
    call std_util__emit_stderr
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr_len
    call std_util__emit_stderr_nl
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__emit_char:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rel _gvar_std_util__g_emit_char_buf]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L422
    mov rax, 1
    push rax
    pop rdi
    call std_io__heap_alloc
    push rax
    lea rax, [rel _gvar_std_util__g_emit_char_buf]
    pop rbx
    mov [rax], rbx
.L422:
    mov rax, [rel _gvar_std_util__g_emit_char_buf]
    mov [rbp-16], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 1
    push rax
    mov rax, [rel _gvar_std_util__g_emit_char_buf]
    push rax
    pop rdi
    pop rsi
    call std_io__io_write_out
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__emit_u64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rel _gvar_std_util__g_emit_u64_buf]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L424
    mov rax, 32
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    push rax
    lea rax, [rel _gvar_std_util__g_emit_u64_buf]
    pop rbx
    mov [rax], rbx
.L424:
    mov rax, [rel _gvar_std_util__g_emit_u64_buf]
    mov [rbp-16], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_io__io_u64_to_ascii
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_io__io_write_out
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__emit_u64_stderr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rel _gvar_std_util__g_emit_u64_stderr_buf]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L426
    mov rax, 32
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    push rax
    lea rax, [rel _gvar_std_util__g_emit_u64_stderr_buf]
    pop rbx
    mov [rax], rbx
.L426:
    mov rax, [rel _gvar_std_util__g_emit_u64_stderr_buf]
    mov [rbp-16], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_io__io_u64_to_ascii
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr_len
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__emit_i64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L428
    lea rax, [rel _str250]
    push rax
    pop rdi
    call std_io__emit
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    pop rdi
    call std_util__emit_u64
    jmp .L429
.L428:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_util__emit_u64
.L429:
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__emit_i64_stderr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L430
    lea rax, [rel _str250]
    push rax
    pop rdi
    call std_util__emit_stderr
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    pop rdi
    call std_util__emit_u64_stderr
    jmp .L431
.L430:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_util__emit_u64_stderr
.L431:
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_util__emit_nl:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, 1
    push rax
    lea rax, [rel _str212]
    push rax
    pop rdi
    pop rsi
    call std_io__io_write_out
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string_builder__StringBuilder_constructor:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    add rax, 16
    pop rbx
    mov [rax], rbx
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string_builder__sb_copy_bytes:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-8]
    mov [rbp-32], rax
    mov rax, [rbp-16]
    mov [rbp-40], rax
    mov rax, 0
    mov [rbp-48], rax
.L432:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L434
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-48]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L433:
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    jmp .L432
.L434:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string_builder__StringBuilder_ensure_cap:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    add rax, 16
    mov rax, [rax]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setbe al
    movzx rax, al
    test rax, rax
    jz .L435
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L435:
    mov rax, [rbp-8]
    add rax, 16
    mov rax, [rax]
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L437
    mov rax, 8
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
.L437:
.L439:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L441
.L440:
    mov rax, [rbp-32]
    push rax
    mov rax, 2
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    jmp .L439
.L441:
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L442
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L442:
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L444
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_string_builder__sb_copy_bytes
.L444:
    mov rax, [rbp-40]
    mov [rbp-48], rax
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    add rax, 16
    pop rbx
    mov [rax], rbx
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string_builder__StringBuilder_init:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L446
    mov rax, 8
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L446:
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L448
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L448:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    add rax, 16
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-32]
    mov [rbp-40], rax
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string_builder__StringBuilder_new:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rdi, 24
    call std_mem__malloc
    mov r12, rax
    mov rdi, r12
    mov rsi, 0
    mov rdx, 24
    call std_mem__memset
    mov rax, 0
    mov [r12], rax
    mov rax, 0
    mov [r12+8], rax
    mov rax, 0
    mov [r12+16], rax
    mov rax, r12
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L450
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L450:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_string_builder__StringBuilder_init
    test rax, rax
    setz al
    movzx rax, al
    test rax, rax
    jz .L452
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L452:
    mov rax, [rbp-16]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string_builder__StringBuilder_clear:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-8]
    mov rax, [rax]
    mov [rbp-16], rax
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string_builder__StringBuilder_len:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string_builder__StringBuilder_ptr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string_builder__StringBuilder_append_bytes:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L454
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L454:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_string_builder__StringBuilder_ensure_cap
    test rax, rax
    setz al
    movzx rax, al
    test rax, rax
    jz .L456
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L456:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_string_builder__sb_copy_bytes
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-8]
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-8]
    mov rax, [rax]
    mov [rbp-32], rax
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string_builder__StringBuilder_append_cstr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_str__str_len
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_string_builder__StringBuilder_append_bytes
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string_builder__StringBuilder_append_u64_dec:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 32
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-24], rax
    mov rax, [rbp-24]
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L458
    mov rax, 48
    and rax, 255
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 1
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    jmp .L459
.L458:
    mov rax, [rbp-16]
    mov [rbp-48], rax
.L460:
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L462
    mov rax, 48
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov rax, rdx
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
.L461:
    mov rax, [rbp-48]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    jmp .L460
.L462:
.L459:
    mov rax, 0
    mov [rbp-56], rax
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov [rbp-64], rax
.L463:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L465
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-56]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    mov [rbp-72], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-64]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    mov [rbp-80], rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-56]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-64]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-56]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    lea rax, [rbp-64]
    pop rbx
    mov [rax], rbx
.L464:
    jmp .L463
.L465:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_string_builder__StringBuilder_append_bytes
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_vec__vec_memcpy:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L466
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L466:
    mov rax, [rbp-24]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L468
    mov rax, [rbp-8]
    mov [rbp-32], rax
    mov rax, [rbp-16]
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L468:
    mov rax, [rbp-24]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L470
    mov rax, [rbp-8]
    mov [rbp-48], rax
    mov rax, [rbp-16]
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L470:
    mov rax, [rbp-24]
    push rax
    mov rax, 24
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L472
    mov rax, [rbp-8]
    mov [rbp-64], rax
    mov rax, [rbp-16]
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-72]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-72]
    push rax
    mov rax, 2
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, 2
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L472:
    mov rax, [rbp-24]
    push rax
    mov rax, 32
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L474
    mov rax, [rbp-8]
    mov [rbp-80], rax
    mov rax, [rbp-16]
    mov [rbp-88], rax
    mov rax, [rbp-88]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-88]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-88]
    push rax
    mov rax, 2
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, 2
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-88]
    push rax
    mov rax, 3
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, 3
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L474:
    mov rax, [rbp-24]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L476
    mov rax, [rbp-8]
    mov [rbp-96], rax
    mov rax, [rbp-16]
    mov [rbp-104], rax
    mov rax, 0
    mov [rbp-112], rax
.L478:
    mov rax, [rbp-112]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L480
    mov rax, [rbp-104]
    push rax
    mov rax, [rbp-112]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-112]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L479:
    mov rax, [rbp-112]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-112]
    pop rbx
    mov [rax], rbx
    jmp .L478
.L480:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L476:
    mov rax, [rbp-24]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov [rbp-120], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov rax, rdx
    mov [rbp-128], rax
    mov rax, [rbp-8]
    mov [rbp-136], rax
    mov rax, [rbp-16]
    mov [rbp-144], rax
    mov rax, 0
    mov [rbp-152], rax
.L481:
    mov rax, [rbp-152]
    push rax
    mov rax, [rbp-120]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L483
    mov rax, [rbp-144]
    push rax
    mov rax, [rbp-152]
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-136]
    push rax
    mov rax, [rbp-152]
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
.L482:
    mov rax, [rbp-152]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-152]
    pop rbx
    mov [rax], rbx
    jmp .L481
.L483:
    mov rax, [rbp-128]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L484
    mov rax, [rbp-120]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov [rbp-160], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-160]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-168], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-160]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-176], rax
    mov rax, 0
    mov [rbp-184], rax
.L486:
    mov rax, [rbp-184]
    push rax
    mov rax, [rbp-128]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L488
    mov rax, [rbp-176]
    push rax
    mov rax, [rbp-184]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-168]
    push rax
    mov rax, [rbp-184]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L487:
    mov rax, [rbp-184]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-184]
    pop rbx
    mov [rax], rbx
    jmp .L486
.L488:
.L484:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_hashmap__hm_memzero:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L489
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L489:
    mov rax, [rbp-16]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov [rbp-24], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov rax, rdx
    mov [rbp-32], rax
    mov rax, [rbp-8]
    mov [rbp-40], rax
    mov rax, 0
    mov [rbp-48], rax
.L491:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L493
    mov rax, 0
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
.L492:
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    jmp .L491
.L493:
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L494
    mov rax, [rbp-24]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov [rbp-56], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-56]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-64], rax
    mov rax, 0
    mov [rbp-72], rax
.L496:
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L498
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-72]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L497:
    mov rax, [rbp-72]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-72]
    pop rbx
    mov [rax], rbx
    jmp .L496
.L498:
.L494:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_hashmap__hm_memcpy:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L499
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L499:
    mov rax, [rbp-24]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L501
    mov rax, [rbp-8]
    mov [rbp-32], rax
    mov rax, [rbp-16]
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L501:
    mov rax, [rbp-24]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L503
    mov rax, [rbp-8]
    mov [rbp-48], rax
    mov rax, [rbp-16]
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L503:
    mov rax, [rbp-24]
    push rax
    mov rax, 24
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L505
    mov rax, [rbp-8]
    mov [rbp-64], rax
    mov rax, [rbp-16]
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-72]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-72]
    push rax
    mov rax, 2
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, 2
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L505:
    mov rax, [rbp-24]
    push rax
    mov rax, 32
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L507
    mov rax, [rbp-8]
    mov [rbp-80], rax
    mov rax, [rbp-16]
    mov [rbp-88], rax
    mov rax, [rbp-88]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-88]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-88]
    push rax
    mov rax, 2
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, 2
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-88]
    push rax
    mov rax, 3
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, 3
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L507:
    mov rax, [rbp-24]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov [rbp-96], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov rax, rdx
    mov [rbp-104], rax
    mov rax, [rbp-8]
    mov [rbp-112], rax
    mov rax, [rbp-16]
    mov [rbp-120], rax
    mov rax, 0
    mov [rbp-128], rax
.L509:
    mov rax, [rbp-128]
    push rax
    mov rax, [rbp-96]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L511
    mov rax, [rbp-120]
    push rax
    mov rax, [rbp-128]
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-112]
    push rax
    mov rax, [rbp-128]
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
.L510:
    mov rax, [rbp-128]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-128]
    pop rbx
    mov [rax], rbx
    jmp .L509
.L511:
    mov rax, [rbp-104]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L512
    mov rax, [rbp-96]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov [rbp-136], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-136]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-144], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-136]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-152], rax
    mov rax, 0
    mov [rbp-160], rax
.L514:
    mov rax, [rbp-160]
    push rax
    mov rax, [rbp-104]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L516
    mov rax, [rbp-152]
    push rax
    mov rax, [rbp-160]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-144]
    push rax
    mov rax, [rbp-160]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L515:
    mov rax, [rbp-160]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-160]
    pop rbx
    mov [rax], rbx
    jmp .L514
.L516:
.L512:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_hashmap__HashMap_hash:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 1469598103934665603
    mov [rbp-24], rax
    mov rax, 1099511628211
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov [rbp-40], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov rax, rdx
    mov [rbp-48], rax
    mov rax, [rbp-8]
    mov [rbp-56], rax
    mov rax, 0
    mov [rbp-64], rax
.L517:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-40]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L519
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    mov rbx, rax
    pop rax
    xor rax, rbx
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L518:
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-64]
    pop rbx
    mov [rax], rbx
    jmp .L517
.L519:
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L520
    mov rax, [rbp-40]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov [rbp-72], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-72]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-80], rax
    mov rax, 0
    mov [rbp-88], rax
.L522:
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L524
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-88]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    mov rbx, rax
    pop rax
    xor rax, rbx
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L523:
    mov rax, [rbp-88]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-88]
    pop rbx
    mov [rax], rbx
    jmp .L522
.L524:
.L520:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L525
    mov rax, 1
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L525:
    mov rax, [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__NumberBig_constructor:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    add rax, 8
    pop rbx
    mov [rax], rbx
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_panic_null:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_util__panic
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_panic_number:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_util__panic
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_panic_big:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_util__panic
    call std_number__number_big_zero
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_panic_u64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_util__panic
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_small_encode:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    mov rcx, rbx
    shl rax, cl
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    or rax, rbx
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_small_decode:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    mov rcx, rbx
    sar rax, cl
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_make_small:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_small_encode
    mov [rbp-16], rax
    mov rax, [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_make_zero:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, 0
    push rax
    pop rdi
    call std_number__number_make_small
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_from_i64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_fits_small_i64
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L527
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_make_small
    mov rsp, rbp
    pop rbp
    ret
.L527:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_from_i64_raw
    push rax
    pop rdi
    call std_number__number_make_big_handle
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_from_u64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 4611686018427387903
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setbe al
    movzx rax, al
    test rax, rax
    jz .L529
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_make_small
    mov rsp, rbp
    pop rbp
    ret
.L529:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_from_u64_raw
    push rax
    pop rdi
    call std_number__number_make_big_handle
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_is_small:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L531
    lea rax, [rel _str533]
    push rax
    pop rdi
    call std_number__number_panic_null
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L531:
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    and rax, rbx
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_small_value:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L534
    lea rax, [rel _str536]
    push rax
    pop rdi
    call std_number__number_panic_null
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L534:
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call std_number__number_small_decode
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_ptr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L537
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L537:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_is_small
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L539
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L539:
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 18446744073709551614
    mov rbx, rax
    pop rax
    and rax, rbx
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_make_big_handle:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L541
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L541:
    mov rax, [rbp-8]
    push rax
    mov rax, 18446744073709551614
    mov rbx, rax
    pop rax
    and rax, rbx
    mov [rbp-16], rax
    mov rax, [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_i64_abs_mag:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L543
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L543:
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setge al
    movzx rax, al
    test rax, rax
    jz .L545
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L545:
    mov rax, [rbp-8]
    push rax
    mov rax, 9223372036854775808
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L547
    mov rax, 9223372036854775808
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L547:
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_fits_small_i64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 13835058055282163712
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L549
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L549:
    mov rax, [rbp-8]
    push rax
    mov rax, 4611686018427387903
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    test rax, rax
    jz .L551
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L551:
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_new:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L553
    mov rax, 1
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L553:
    mov rdi, 16
    call std_mem__malloc
    mov r12, rax
    mov rdi, r12
    mov rsi, 0
    mov rdx, 16
    call std_mem__memset
    mov rax, r12
    mov [rbp-32], rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    mov rax, 4
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-40], rax
    mov rdi, 24
    call std_mem__malloc
    mov r12, rax
    mov rdi, r12
    mov rsi, 0
    mov rdx, 24
    call std_mem__memset
    mov rax, [rbp-40]
    mov [r12], rax
    mov rax, 0
    mov [r12+8], rax
    mov rax, [rbp-24]
    mov [r12+16], rax
    mov rax, r12
    push rax
    mov rax, [rbp-32]
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_zero:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, 1
    push rax
    mov rax, 0
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_new
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_trim_inplace:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L557
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L558
.L557:
    mov eax, 1
.L558:
    test rax, rax
    jz .L555
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L555:
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    mov [rbp-16], rax
.L559:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L560
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    mov [rbp-20], eax
    mov eax, [rbp-20]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L561
    jmp .L560
.L561:
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_pop__G__T_u32
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    lea rax, [rbp-16]
    pop rbx
    mov [rax], rbx
    jmp .L559
.L560:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L563
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L563:
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    test rax, rax
    jz .L565
    mov rax, 1
    push rax
    mov rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    jmp .L566
.L565:
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L567
    mov rax, 1
    neg rax
    push rax
    mov rax, [rbp-8]
    pop rbx
    mov [rax], rbx
.L567:
.L566:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_copy:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L569
    call std_number__number_big_zero
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L569:
    mov rax, 0
    mov [rbp-16], rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L571
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    push rax
    lea rax, [rbp-16]
    pop rbx
    mov [rax], rbx
.L571:
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_new
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
.L573:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L575
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    push rax
    mov rax, [rbp-24]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_push__G__T_u32
.L574:
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    jmp .L573
.L575:
    mov rax, [rbp-24]
    push rax
    pop rdi
    call std_number__number_big_trim_inplace
    mov rax, [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_abs_copy:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_copy
    mov [rbp-16], rax
    mov rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L576
    mov rax, 1
    push rax
    mov rax, [rbp-16]
    pop rbx
    mov [rax], rbx
.L576:
    mov rax, [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_from_u64_raw:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L578
    call std_number__number_big_zero
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L578:
    mov rax, 4
    push rax
    mov rax, 1
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_new
    mov [rbp-16], rax
    mov rax, [rbp-8]
    mov [rbp-24], rax
.L580:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L581
    mov rax, [rbp-24]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov rax, rdx
    mov eax, eax
    push rax
    mov rax, [rbp-16]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_push__G__T_u32
    mov rax, [rbp-24]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    jmp .L580
.L581:
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_big_trim_inplace
    mov rax, [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_from_i64_raw:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L582
    call std_number__number_big_zero
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L582:
    mov rax, 0
    mov [rbp-16], rax
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_i64_abs_mag
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_big_from_u64_raw
    mov [rbp-24], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L586
    mov rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L587
.L586:
    xor eax, eax
.L587:
    test rax, rax
    jz .L584
    mov rax, 1
    neg rax
    push rax
    mov rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L584:
    mov rax, [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_abs_to_u64_checked:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L588
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L588:
    mov rax, 0
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L594
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L595
.L594:
    mov eax, 1
.L595:
    test rax, rax
    jnz .L592
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L593
.L592:
    mov eax, 1
.L593:
    test rax, rax
    jz .L590
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L590:
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
    mov rax, [rbp-24]
    mov [rbp-40], rax
.L596:
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L597
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    mov [rbp-48], rax
    mov rax, [rbp-32]
    push rax
    mov rax, 18446744073709551615
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    cqo
    idiv rbx
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L598
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L598:
    mov rax, [rbp-32]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    jmp .L596
.L597:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_try_to_i64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L600
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L600:
    mov rax, 0
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L604
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L605
.L604:
    mov eax, 1
.L605:
    test rax, rax
    jz .L602
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L602:
    mov rax, 0
    mov [rbp-24], rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_abs_to_u64_checked
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L606
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L606:
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    test rax, rax
    jz .L608
    mov rax, [rbp-24]
    push rax
    mov rax, 9223372036854775807
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L610
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L610:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L608:
    mov rax, [rbp-24]
    push rax
    mov rax, 9223372036854775808
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L612
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L612:
    mov rax, [rbp-24]
    push rax
    mov rax, 9223372036854775808
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L614
    mov rax, 9223372036854775808
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L614:
    mov rax, 0
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_abs_cmp:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 0
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L618
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L619
.L618:
    xor eax, eax
.L619:
    test rax, rax
    jz .L616
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L616:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L622
    mov rax, [rbp-16]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L623
.L622:
    xor eax, eax
.L623:
    test rax, rax
    jz .L620
    mov rax, [rbp-16]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
.L620:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L624
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L624:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L626
    mov rax, 1
    neg rax
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L626:
    mov rax, [rbp-24]
    mov [rbp-40], rax
.L628:
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L629
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    mov [rbp-48], rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    mov [rbp-56], rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-56]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L630
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L630:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-56]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L632
    mov rax, 1
    neg rax
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L632:
    jmp .L628
.L629:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_add_abs:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 0
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L636
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L637
.L636:
    xor eax, eax
.L637:
    test rax, rax
    jz .L634
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L634:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L640
    mov rax, [rbp-16]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L641
.L640:
    xor eax, eax
.L641:
    test rax, rax
    jz .L638
    mov rax, [rbp-16]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
.L638:
    mov rax, [rbp-24]
    mov [rbp-40], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L642
    mov rax, [rbp-32]
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
.L642:
    mov rax, [rbp-40]
    push rax
    mov rax, 2
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_new
    mov [rbp-48], rax
    mov rax, 0
    mov [rbp-56], rax
    mov rax, 0
    mov [rbp-64], rax
.L644:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-40]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L646
    mov rax, 0
    mov [rbp-72], rax
    mov rax, 0
    mov [rbp-80], rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L647
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    push rax
    lea rax, [rbp-72]
    pop rbx
    mov [rax], rbx
.L647:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L649
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-16]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    push rax
    lea rax, [rbp-80]
    pop rbx
    mov [rax], rbx
.L649:
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-80]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-56]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-88], rax
    mov rax, [rbp-88]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov rax, rdx
    mov eax, eax
    push rax
    mov rax, [rbp-48]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_push__G__T_u32
    mov rax, [rbp-88]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    push rax
    lea rax, [rbp-56]
    pop rbx
    mov [rax], rbx
.L645:
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-64]
    pop rbx
    mov [rax], rbx
    jmp .L644
.L646:
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L651
    mov rax, [rbp-56]
    mov eax, eax
    push rax
    mov rax, [rbp-48]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_push__G__T_u32
.L651:
    mov rax, [rbp-48]
    push rax
    pop rdi
    call std_number__number_big_trim_inplace
    mov rax, [rbp-48]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_sub_abs:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 0
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L655
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L656
.L655:
    xor eax, eax
.L656:
    test rax, rax
    jz .L653
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L653:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L659
    mov rax, [rbp-16]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L660
.L659:
    xor eax, eax
.L660:
    test rax, rax
    jz .L657
    mov rax, [rbp-16]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
.L657:
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_new
    mov [rbp-40], rax
    mov rax, 0
    mov [rbp-48], rax
    mov rax, 0
    mov [rbp-56], rax
.L661:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L663
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    mov [rbp-64], rax
    mov rax, 0
    mov [rbp-72], rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L664
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-16]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    push rax
    lea rax, [rbp-72]
    pop rbx
    mov [rax], rbx
.L664:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-72]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov [rbp-80], rax
    mov rax, [rbp-80]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L666
    mov rax, [rbp-80]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-80]
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    jmp .L667
.L666:
    mov rax, 0
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
.L667:
    mov rax, [rbp-80]
    mov eax, eax
    push rax
    mov rax, [rbp-40]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_push__G__T_u32
.L662:
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-56]
    pop rbx
    mov [rax], rbx
    jmp .L661
.L663:
    mov rax, [rbp-40]
    push rax
    pop rdi
    call std_number__number_big_trim_inplace
    mov rax, [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_mul_abs:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L674
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L675
.L674:
    mov eax, 1
.L675:
    test rax, rax
    jnz .L672
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L673
.L672:
    mov eax, 1
.L673:
    test rax, rax
    jnz .L670
    mov rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L671
.L670:
    mov eax, 1
.L671:
    test rax, rax
    jz .L668
    call std_number__number_big_zero
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L668:
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    mov [rbp-24], rax
    mov rax, [rbp-16]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 2
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_new
    mov [rbp-40], rax
    mov rax, 0
    mov [rbp-48], rax
.L676:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L678
    mov rax, 0
    push rax
    mov rax, [rbp-40]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_push__G__T_u32
.L677:
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    jmp .L676
.L678:
    mov rax, 0
    mov [rbp-56], rax
.L679:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L681
    mov rax, 0
    mov [rbp-64], rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    mov [rbp-72], rax
    mov rax, 0
    mov [rbp-80], rax
.L682:
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L684
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-80]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-88], rax
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-40]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    mov [rbp-96], rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-16]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    mov [rbp-104], rax
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-104]
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-64]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-112], rax
    mov rax, [rbp-112]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov rax, rdx
    mov eax, eax
    push rax
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-40]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_vec__Vec_set__G__T_u32
    mov rax, [rbp-112]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    push rax
    lea rax, [rbp-64]
    pop rbx
    mov [rax], rbx
.L683:
    mov rax, [rbp-80]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-80]
    pop rbx
    mov [rax], rbx
    jmp .L682
.L684:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-120], rax
.L685:
    mov rax, [rbp-64]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L686
    mov rax, [rbp-120]
    push rax
    mov rax, [rbp-40]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    mov [rbp-128], rax
    mov rax, [rbp-128]
    push rax
    mov rax, [rbp-64]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-136], rax
    mov rax, [rbp-136]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov rax, rdx
    mov eax, eax
    push rax
    mov rax, [rbp-120]
    push rax
    mov rax, [rbp-40]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_vec__Vec_set__G__T_u32
    mov rax, [rbp-136]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    push rax
    lea rax, [rbp-64]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-120]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-120]
    pop rbx
    mov [rax], rbx
    jmp .L685
.L686:
.L680:
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-56]
    pop rbx
    mov [rax], rbx
    jmp .L679
.L681:
    mov rax, [rbp-40]
    push rax
    pop rdi
    call std_number__number_big_trim_inplace
    mov rax, [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_mul_small_abs:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L691
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L692
.L691:
    mov eax, 1
.L692:
    test rax, rax
    jnz .L689
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L690
.L689:
    mov eax, 1
.L690:
    test rax, rax
    jz .L687
    call std_number__number_big_zero
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L687:
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_new
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
    mov rax, 0
    mov [rbp-48], rax
.L693:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L695
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    mov rax, [rbp-40]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov rax, rdx
    mov eax, eax
    push rax
    mov rax, [rbp-32]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_push__G__T_u32
    mov rax, [rbp-64]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
.L694:
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    jmp .L693
.L695:
.L696:
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L697
    mov rax, [rbp-40]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov rax, rdx
    mov eax, eax
    push rax
    mov rax, [rbp-32]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_push__G__T_u32
    mov rax, [rbp-40]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    jmp .L696
.L697:
    mov rax, [rbp-32]
    push rax
    pop rdi
    call std_number__number_big_trim_inplace
    mov rax, [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_div_small_abs:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L698
    lea rax, [rel _str700]
    push rax
    pop rdi
    call std_number__number_panic_big
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L698:
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L703
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L704
.L703:
    mov eax, 1
.L704:
    test rax, rax
    jz .L701
    call std_number__number_big_zero
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L701:
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_new
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
.L705:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L707
    mov rax, 0
    push rax
    mov rax, [rbp-32]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_push__G__T_u32
.L706:
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    jmp .L705
.L707:
    mov rax, 0
    mov [rbp-48], rax
    mov rax, [rbp-24]
    mov [rbp-56], rax
.L708:
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L709
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    lea rax, [rbp-56]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-48]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov [rbp-72], rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov rax, rdx
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-72]
    mov eax, eax
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-32]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_vec__Vec_set__G__T_u32
    jmp .L708
.L709:
    mov rax, [rbp-32]
    push rax
    pop rdi
    call std_number__number_big_trim_inplace
    mov rax, [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_mod_small_abs:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L710
    lea rax, [rel _str712]
    push rax
    pop rdi
    call std_number__number_panic_u64
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L710:
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L715
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L716
.L715:
    mov eax, 1
.L716:
    test rax, rax
    jz .L713
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L713:
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
    mov rax, [rbp-24]
    mov [rbp-40], rax
.L717:
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L718
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-32]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov rax, rdx
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    jmp .L717
.L718:
    mov rax, [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_from_big_normalized:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L719
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L719:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_trim_inplace
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L721
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L721:
    mov rax, 0
    mov [rbp-16], rax
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_try_to_i64
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L723
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_fits_small_i64
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L725
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_make_small
    mov rsp, rbp
    pop rbp
    ret
.L725:
.L723:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_make_big_handle
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_to_abs_big:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L727
    call std_number__number_big_zero
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L727:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_is_small
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L729
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_small_value
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L731
    call std_number__number_big_zero
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L731:
    mov rax, 0
    mov [rbp-24], rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_number__number_i64_abs_mag
    mov rax, [rbp-24]
    push rax
    pop rdi
    call std_number__number_big_from_u64_raw
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L729:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_ptr
    push rax
    pop rdi
    call std_number__number_big_abs_copy
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_signum:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L733
    lea rax, [rel _str735]
    push rax
    pop rdi
    call std_number__number_panic_null
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L733:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_is_small
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L736
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_small_value
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    test rax, rax
    jz .L738
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L738:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L740
    mov rax, 1
    neg rax
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L740:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L736:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_ptr
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L742
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L742:
    mov rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    test rax, rax
    jz .L744
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L744:
    mov rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L746
    mov rax, 1
    neg rax
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L746:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_negated:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L748
    lea rax, [rel _str750]
    push rax
    pop rdi
    call std_number__number_panic_null
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L748:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_is_small
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L751
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_small_value
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    pop rdi
    call std_number__number_from_i64
    mov rsp, rbp
    pop rbp
    ret
.L751:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_ptr
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L755
    mov rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L756
.L755:
    mov eax, 1
.L756:
    test rax, rax
    jz .L753
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L753:
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_big_copy
    mov [rbp-24], rax
    mov rax, 0
    push rax
    mov rax, [rbp-24]
    mov rax, [rax]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    mov rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    pop rdi
    call std_number__number_from_big_normalized
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_abs_with_sign:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L757
    lea rax, [rel _str759]
    push rax
    pop rdi
    call std_number__number_panic_null
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L757:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L762
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L763
.L762:
    mov eax, 1
.L763:
    test rax, rax
    jz .L760
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L760:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_is_small
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L764
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_small_value
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
    lea rax, [rbp-32]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    pop rsi
    call std_number__number_i64_abs_mag
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L766
    mov rax, [rbp-32]
    push rax
    mov rax, 9223372036854775807
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setbe al
    movzx rax, al
    test rax, rax
    jz .L768
    mov rax, 0
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    pop rdi
    call std_number__number_from_i64
    mov rsp, rbp
    pop rbp
    ret
.L768:
    mov rax, [rbp-32]
    push rax
    pop rdi
    call std_number__number_big_from_u64_raw
    mov [rbp-40], rax
    mov rax, 1
    neg rax
    push rax
    mov rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-40]
    push rax
    pop rdi
    call std_number__number_from_big_normalized
    mov rsp, rbp
    pop rbp
    ret
.L766:
    mov rax, [rbp-32]
    push rax
    pop rdi
    call std_number__number_from_u64
    mov rsp, rbp
    pop rbp
    ret
.L764:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_ptr
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L770
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L770:
    mov rax, [rbp-48]
    push rax
    pop rdi
    call std_number__number_big_abs_copy
    mov [rbp-56], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L772
    mov rax, 1
    neg rax
    push rax
    mov rax, [rbp-56]
    pop rbx
    mov [rax], rbx
    jmp .L773
.L772:
    mov rax, 1
    push rax
    mov rax, [rbp-56]
    pop rbx
    mov [rax], rbx
.L773:
    mov rax, [rbp-56]
    push rax
    pop rdi
    call std_number__number_from_big_normalized
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_abs_cmp:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L774
    lea rax, [rel _str776]
    push rax
    pop rdi
    call std_number__number_panic_null
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L774:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L777
    lea rax, [rel _str779]
    push rax
    pop rdi
    call std_number__number_panic_null
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L777:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_is_small
    mov [rbp-24], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_is_small
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L782
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L783
.L782:
    xor eax, eax
.L783:
    test rax, rax
    jz .L780
    mov rax, 0
    mov [rbp-40], rax
    mov rax, 0
    mov [rbp-48], rax
    lea rax, [rbp-40]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_small_value
    push rax
    pop rdi
    pop rsi
    call std_number__number_i64_abs_mag
    lea rax, [rbp-48]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_small_value
    push rax
    pop rdi
    pop rsi
    call std_number__number_i64_abs_mag
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L784
    mov rax, 1
    neg rax
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L784:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L786
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L786:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L780:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L788
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_big_ptr
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L792
    mov rax, [rbp-56]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L793
.L792:
    mov eax, 1
.L793:
    test rax, rax
    jz .L790
    mov rax, 0
    mov [rbp-64], rax
    lea rax, [rbp-64]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_small_value
    push rax
    pop rdi
    pop rsi
    call std_number__number_i64_abs_mag
    mov rax, [rbp-64]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L794
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L794:
.L790:
    mov rax, 1
    neg rax
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L788:
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L796
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_ptr
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L800
    mov rax, [rbp-72]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L801
.L800:
    mov eax, 1
.L801:
    test rax, rax
    jz .L798
    mov rax, 0
    mov [rbp-80], rax
    lea rax, [rbp-80]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_small_value
    push rax
    pop rdi
    pop rsi
    call std_number__number_i64_abs_mag
    mov rax, [rbp-80]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L802
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L802:
.L798:
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L796:
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_big_ptr
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_ptr
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_abs_cmp
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_cmp_ptr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L804
    lea rax, [rel _str806]
    push rax
    pop rdi
    call std_number__number_panic_null
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L804:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L807
    lea rax, [rel _str809]
    push rax
    pop rdi
    call std_number__number_panic_null
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L807:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_is_small
    mov [rbp-24], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_is_small
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L812
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L813
.L812:
    xor eax, eax
.L813:
    test rax, rax
    jz .L810
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_small_value
    mov [rbp-40], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_small_value
    mov [rbp-48], rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L814
    mov rax, 1
    neg rax
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L814:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    test rax, rax
    jz .L816
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L816:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L810:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_signum
    mov [rbp-56], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_signum
    mov [rbp-64], rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L818
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L820
    mov rax, 1
    neg rax
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L820:
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L818:
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L822
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L822:
    mov rax, 0
    mov [rbp-72], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L826
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L827
.L826:
    xor eax, eax
.L827:
    test rax, rax
    jz .L824
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_big_ptr
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_ptr
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_abs_cmp
    push rax
    lea rax, [rbp-72]
    pop rbx
    mov [rax], rbx
    jmp .L825
.L824:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L828
    mov rax, 1
    push rax
    lea rax, [rbp-72]
    pop rbx
    mov [rax], rbx
    jmp .L829
.L828:
    mov rax, 1
    neg rax
    push rax
    lea rax, [rbp-72]
    pop rbx
    mov [rax], rbx
.L829:
.L825:
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    test rax, rax
    jz .L830
    mov rax, [rbp-72]
    mov rsp, rbp
    pop rbp
    ret
.L830:
    mov rax, 0
    push rax
    mov rax, [rbp-72]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_add_values:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_signum
    mov [rbp-24], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_signum
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L832
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_clone
    mov rsp, rbp
    pop rbp
    ret
.L832:
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L834
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_clone
    mov rsp, rbp
    pop rbp
    ret
.L834:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_to_abs_big
    mov [rbp-40], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_to_abs_big
    mov [rbp-48], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L836
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_add_abs
    mov [rbp-56], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-56]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-56]
    push rax
    pop rdi
    call std_number__number_from_big_normalized
    mov rsp, rbp
    pop rbp
    ret
.L836:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_abs_cmp
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L838
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L838:
    mov rax, [rbp-64]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    test rax, rax
    jz .L840
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_sub_abs
    mov [rbp-72], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-72]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-72]
    push rax
    pop rdi
    call std_number__number_from_big_normalized
    mov rsp, rbp
    pop rbp
    ret
.L840:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_sub_abs
    mov [rbp-80], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-80]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-80]
    push rax
    pop rdi
    call std_number__number_from_big_normalized
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_sub_values:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_negated
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_add_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_mul_values:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_signum
    mov [rbp-24], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_signum
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L844
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L845
.L844:
    mov eax, 1
.L845:
    test rax, rax
    jz .L842
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L842:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_to_abs_big
    mov [rbp-40], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_to_abs_big
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_mul_abs
    mov [rbp-56], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    mov rax, [rbp-56]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-56]
    push rax
    pop rdi
    call std_number__number_from_big_normalized
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_divmod_values_nonzero:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    call std_number__number_make_zero
    mov [rbp-32], rax
    call std_number__number_make_zero
    mov [rbp-24], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L848
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L849
.L848:
    mov eax, 1
.L849:
    test rax, rax
    jz .L846
    lea rax, [rbp-32]
    mov r10, rax
    mov rax, [r10]
    mov rdx, [r10+8]
    mov rsp, rbp
    pop rbp
    ret
.L846:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_signum
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L850
    lea rax, [rbp-32]
    mov r10, rax
    mov rax, [r10]
    mov rdx, [r10+8]
    mov rsp, rbp
    pop rbp
    ret
.L850:
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_signum
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L852
    lea rax, [rbp-32]
    mov r10, rax
    mov rax, [r10]
    mov rdx, [r10+8]
    mov rsp, rbp
    pop rbp
    ret
.L852:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_is_small
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L856
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_is_small
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L857
.L856:
    xor eax, eax
.L857:
    test rax, rax
    jz .L854
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_small_value
    mov [rbp-56], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_small_value
    mov [rbp-64], rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    mov rbx, rax
    pop rax
    cqo
    idiv rbx
    push rax
    pop rdi
    call std_number__number_from_i64
    push rax
    push rdx
    lea rax, [rbp-32]
    pop rcx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    mov rbx, rax
    pop rax
    cqo
    idiv rbx
    mov rax, rdx
    push rax
    pop rdi
    call std_number__number_from_i64
    push rax
    push rdx
    lea rax, [rbp-24]
    pop rcx
    pop rbx
    mov [rax], rbx
    lea rax, [rbp-32]
    mov r10, rax
    mov rax, [r10]
    mov rdx, [r10+8]
    mov rsp, rbp
    pop rbp
    ret
.L854:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_to_abs_big
    mov [rbp-72], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_to_abs_big
    mov [rbp-80], rax
    call std_number__number_big_zero
    mov [rbp-88], rax
    call std_number__number_make_zero
    mov [rbp-96], rax
    lea r12, [rbp-96]
    mov rax, 0
    mov [rbp-104], rax
    lea rax, [rbp-104]
    push rax
    mov rax, [rbp-80]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_abs_to_u64_checked
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L858
    mov rax, [rbp-104]
    push rax
    mov rax, [rbp-72]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_div_small_abs
    push rax
    lea rax, [rbp-88]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-104]
    push rax
    mov rax, [rbp-72]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_mod_small_abs
    mov [rbp-112], rax
    mov rax, [rbp-112]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L860
    mov rax, [rbp-112]
    push rax
    pop rdi
    call std_number__number_from_u64
    push rax
    push rdx
    lea rax, [rbp-96]
    pop rcx
    pop rbx
    mov [rax], rbx
.L860:
    jmp .L859
.L858:
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-72]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_abs_divmod_long
    mov [rbp-128], rax
    mov [rbp-120], rdx
    lea r12, [rbp-128]
    lea rax, [rbp-128]
    mov rax, [rax]
    push rax
    lea rax, [rbp-88]
    pop rbx
    mov [rax], rbx
    lea rax, [rbp-128]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_number__number_from_big_normalized
    push rax
    push rdx
    lea rax, [rbp-96]
    pop rcx
    pop rbx
    mov [rax], rbx
.L859:
    mov rax, [rbp-88]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L862
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    mov rax, [rbp-88]
    pop rbx
    mov [rax], rbx
.L862:
    mov rax, [rbp-88]
    push rax
    pop rdi
    call std_number__number_from_big_normalized
    push rax
    push rdx
    lea rax, [rbp-32]
    pop rcx
    pop rbx
    mov [rax], rbx
    lea rax, [rbp-24]
    mov r8, rax
    lea rax, [rbp-96]
    mov rcx, [rax]
    mov [r8], rcx
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L866
    lea rax, [rbp-24]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L867
.L866:
    xor eax, eax
.L867:
    test rax, rax
    jz .L864
    mov rax, 1
    neg rax
    push rax
    lea rax, [rbp-24]
    push rax
    pop rdi
    pop rsi
    call std_number__number_abs_with_sign
    push rax
    push rdx
    lea rax, [rbp-24]
    pop rcx
    pop rbx
    mov [rax], rbx
.L864:
    lea rax, [rbp-32]
    mov r10, rax
    mov rax, [r10]
    mov rdx, [r10+8]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_div_values:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L868
    lea rax, [rel _str870]
    push rax
    pop rdi
    call std_number__number_panic_null
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L868:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L871
    lea rax, [rel _str873]
    push rax
    pop rdi
    call std_number__number_panic_null
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L871:
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L874
    lea rax, [rel _str700]
    push rax
    pop rdi
    call std_number__number_panic_number
    mov rsp, rbp
    pop rbp
    ret
.L874:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_divmod_values_nonzero
    mov [rbp-32], rax
    mov [rbp-24], rdx
    lea r12, [rbp-32]
    lea rax, [rbp-32]
    mov r10, rax
    mov rax, [r10]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_mod_values:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L876
    lea rax, [rel _str878]
    push rax
    pop rdi
    call std_number__number_panic_null
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L876:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L879
    lea rax, [rel _str881]
    push rax
    pop rdi
    call std_number__number_panic_null
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L879:
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L882
    lea rax, [rel _str712]
    push rax
    pop rdi
    call std_number__number_panic_number
    mov rsp, rbp
    pop rbp
    ret
.L882:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_divmod_values_nonzero
    mov [rbp-32], rax
    mov [rbp-24], rdx
    lea r12, [rbp-32]
    lea rax, [rbp-24]
    mov r10, rax
    mov rax, [r10]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_mul_small:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L886
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L887
.L886:
    mov eax, 1
.L887:
    test rax, rax
    jz .L884
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L884:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_signum
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L888
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L888:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_to_abs_big
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_mul_small_abs
    mov [rbp-40], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-40]
    push rax
    pop rdi
    call std_number__number_from_big_normalized
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_abs_clone:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L890
    lea rax, [rel _str892]
    push rax
    pop rdi
    call std_number__number_panic_null
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L890:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_is_small
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L893
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_small_value
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setge al
    movzx rax, al
    test rax, rax
    jz .L895
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_make_small
    mov rsp, rbp
    pop rbp
    ret
.L895:
    mov rax, 0
    mov [rbp-24], rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_number__number_i64_abs_mag
    mov rax, [rbp-24]
    push rax
    pop rdi
    call std_number__number_from_u64
    mov rsp, rbp
    pop rbp
    ret
.L893:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_ptr
    push rax
    pop rdi
    call std_number__number_big_abs_copy
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    pop rdi
    call std_number__number_from_big_normalized
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_div_small_abs:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L897
    lea rax, [rel _str899]
    push rax
    pop rdi
    call std_number__number_panic_null
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L897:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L900
    lea rax, [rel _str700]
    push rax
    pop rdi
    call std_number__number_panic_number
    mov rsp, rbp
    pop rbp
    ret
.L900:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L902
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L902:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_is_small
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L904
    mov rax, 0
    mov [rbp-24], rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_small_value
    push rax
    pop rdi
    pop rsi
    call std_number__number_i64_abs_mag
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    push rax
    pop rdi
    call std_number__number_from_u64
    mov rsp, rbp
    pop rbp
    ret
.L904:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_to_abs_big
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_div_small_abs
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    call std_number__number_from_big_normalized
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_mod_small_abs:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L906
    lea rax, [rel _str908]
    push rax
    pop rdi
    call std_number__number_panic_null
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L906:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L909
    lea rax, [rel _str712]
    push rax
    pop rdi
    call std_number__number_panic_u64
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L909:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L911
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L911:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_is_small
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L913
    mov rax, 0
    mov [rbp-24], rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_small_value
    push rax
    pop rdi
    pop rsi
    call std_number__number_i64_abs_mag
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov rax, rdx
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L913:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_to_abs_big
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_mod_small_abs
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_shift_limbs_abs:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L919
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L920
.L919:
    mov eax, 1
.L920:
    test rax, rax
    jnz .L917
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L918
.L917:
    mov eax, 1
.L918:
    test rax, rax
    jz .L915
    call std_number__number_big_zero
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L915:
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_new
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
.L921:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L923
    mov rax, 0
    push rax
    mov rax, [rbp-32]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_push__G__T_u32
.L922:
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    jmp .L921
.L923:
    mov rax, 0
    mov [rbp-48], rax
.L924:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L926
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    push rax
    mov rax, [rbp-32]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_push__G__T_u32
.L925:
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    jmp .L924
.L926:
    mov rax, [rbp-32]
    push rax
    pop rdi
    call std_number__number_big_trim_inplace
    mov rax, [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_big_abs_divmod_long:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 0
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-24], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L933
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L934
.L933:
    mov eax, 1
.L934:
    test rax, rax
    jnz .L931
    mov rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L932
.L931:
    mov eax, 1
.L932:
    test rax, rax
    jnz .L929
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L930
.L929:
    mov eax, 1
.L930:
    test rax, rax
    jz .L927
    call std_number__number_big_zero
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    call std_number__number_big_zero
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    lea rax, [rbp-32]
    mov r10, rax
    mov rax, [r10]
    mov rdx, [r10+8]
    mov rsp, rbp
    pop rbp
    ret
.L927:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_abs_cmp
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L935
    call std_number__number_big_zero
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_abs_copy
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    lea rax, [rbp-32]
    mov r10, rax
    mov rax, [r10]
    mov rdx, [r10+8]
    mov rsp, rbp
    pop rbp
    ret
.L935:
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L937
    mov rax, 1
    push rax
    pop rdi
    call std_number__number_big_from_u64_raw
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    call std_number__number_big_zero
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    lea rax, [rbp-32]
    mov r10, rax
    mov rax, [r10]
    mov rdx, [r10+8]
    mov rsp, rbp
    pop rbp
    ret
.L937:
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    mov [rbp-48], rax
    mov rax, [rbp-16]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    mov [rbp-56], rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-56]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_new
    mov [rbp-72], rax
    mov rax, 0
    mov [rbp-80], rax
.L939:
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-64]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L941
    mov rax, 0
    push rax
    mov rax, [rbp-72]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_push__G__T_u32
.L940:
    mov rax, [rbp-80]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-80]
    pop rbx
    mov [rax], rbx
    jmp .L939
.L941:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_abs_copy
    mov [rbp-88], rax
    mov rax, [rbp-64]
    mov [rbp-96], rax
.L942:
    mov rax, [rbp-96]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L943
    mov rax, [rbp-96]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    lea rax, [rbp-96]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_shift_limbs_abs
    mov [rbp-104], rax
    mov rax, [rbp-104]
    push rax
    mov rax, [rbp-88]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_abs_cmp
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L944
    jmp .L942
.L944:
    mov rax, 1
    mov [rbp-112], rax
    mov rax, 1000000000
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov [rbp-120], rax
    mov rax, 0
    mov [rbp-128], rax
.L946:
    mov rax, [rbp-112]
    push rax
    mov rax, [rbp-120]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setbe al
    movzx rax, al
    test rax, rax
    jz .L947
    mov rax, [rbp-112]
    push rax
    mov rax, [rbp-120]
    push rax
    mov rax, [rbp-112]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    mov rax, 2
    mov rbx, rax
    pop rax
    cqo
    idiv rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-136], rax
    mov rax, [rbp-136]
    push rax
    mov rax, [rbp-104]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_mul_small_abs
    mov [rbp-144], rax
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-144]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_abs_cmp
    mov [rbp-152], rax
    mov rax, [rbp-152]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setle al
    movzx rax, al
    test rax, rax
    jz .L948
    mov rax, [rbp-136]
    push rax
    lea rax, [rbp-128]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-136]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-112]
    pop rbx
    mov [rax], rbx
    jmp .L949
.L948:
    mov rax, [rbp-136]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    lea rax, [rbp-120]
    pop rbx
    mov [rax], rbx
.L949:
    jmp .L946
.L947:
    mov rax, [rbp-128]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L950
    mov rax, [rbp-128]
    push rax
    mov rax, [rbp-104]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_mul_small_abs
    mov [rbp-160], rax
    mov rax, [rbp-160]
    push rax
    mov rax, [rbp-88]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_sub_abs
    push rax
    lea rax, [rbp-88]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-128]
    mov eax, eax
    push rax
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-72]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_vec__Vec_set__G__T_u32
.L950:
    jmp .L942
.L943:
    mov rax, [rbp-72]
    push rax
    pop rdi
    call std_number__number_big_trim_inplace
    mov rax, [rbp-88]
    push rax
    pop rdi
    call std_number__number_big_trim_inplace
    mov rax, [rbp-72]
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-88]
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    lea rax, [rbp-32]
    mov r10, rax
    mov rax, [r10]
    mov rdx, [r10+8]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_pow2:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, 1
    push rax
    pop rdi
    call std_number__number_from_i64
    mov [rbp-16], rax
    lea r12, [rbp-16]
    mov rax, 0
    mov [rbp-24], rax
.L952:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L954
    mov rax, 2
    push rax
    lea rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_number__number_mul_small
    push rax
    push rdx
    lea rax, [rbp-16]
    pop rcx
    pop rbx
    mov [rax], rbx
.L953:
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    jmp .L952
.L954:
    lea rax, [rbp-16]
    mov r10, rax
    mov rax, [r10]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_bit_length_abs:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L955
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L955:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_abs_clone
    mov [rbp-16], rax
    lea r12, [rbp-16]
    mov rax, 0
    mov [rbp-24], rax
.L957:
    lea rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L958
    mov rax, 2
    push rax
    lea rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_number__number_div_small_abs
    push rax
    push rdx
    lea rax, [rbp-16]
    pop rcx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    jmp .L957
.L958:
    mov rax, [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_shl_values:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L961
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L962
.L961:
    mov eax, 1
.L962:
    test rax, rax
    jz .L959
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L959:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L963
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_clone
    mov rsp, rbp
    pop rbp
    ret
.L963:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_abs_clone
    mov [rbp-24], rax
    lea r12, [rbp-24]
    mov rax, 0
    mov [rbp-32], rax
.L965:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L967
    mov rax, 2
    push rax
    lea rax, [rbp-24]
    push rax
    pop rdi
    pop rsi
    call std_number__number_mul_small
    push rax
    push rdx
    lea rax, [rbp-24]
    pop rcx
    pop rbx
    mov [rax], rbx
.L966:
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    jmp .L965
.L967:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_signum
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L970
    lea rax, [rbp-24]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L971
.L970:
    xor eax, eax
.L971:
    test rax, rax
    jz .L968
    mov rax, 1
    neg rax
    push rax
    lea rax, [rbp-24]
    push rax
    pop rdi
    pop rsi
    call std_number__number_abs_with_sign
    push rax
    push rdx
    lea rax, [rbp-24]
    pop rcx
    pop rbx
    mov [rax], rbx
.L968:
    lea rax, [rbp-24]
    mov r10, rax
    mov rax, [r10]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_bitwise_nonneg_abs:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_abs_clone
    mov [rbp-32], rax
    lea r12, [rbp-32]
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_abs_clone
    mov [rbp-40], rax
    lea r12, [rbp-40]
    mov rax, 1
    push rax
    pop rdi
    call std_number__number_from_i64
    mov [rbp-48], rax
    lea r12, [rbp-48]
    call std_number__number_make_zero
    mov [rbp-56], rax
    lea r12, [rbp-56]
.L972:
    lea rax, [rbp-32]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jnz .L974
    lea rax, [rbp-40]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L975
.L974:
    mov eax, 1
.L975:
    test rax, rax
    jz .L973
    mov rax, 2
    push rax
    lea rax, [rbp-32]
    push rax
    pop rdi
    pop rsi
    call std_number__number_mod_small_abs
    mov [rbp-64], rax
    mov rax, 2
    push rax
    lea rax, [rbp-40]
    push rax
    pop rdi
    pop rsi
    call std_number__number_mod_small_abs
    mov [rbp-72], rax
    mov rax, 0
    mov [rbp-80], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L976
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-72]
    mov rbx, rax
    pop rax
    and rax, rbx
    push rax
    lea rax, [rbp-80]
    pop rbx
    mov [rax], rbx
    jmp .L977
.L976:
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L978
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-72]
    mov rbx, rax
    pop rax
    or rax, rbx
    push rax
    lea rax, [rbp-80]
    pop rbx
    mov [rax], rbx
    jmp .L979
.L978:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-72]
    mov rbx, rax
    pop rax
    xor rax, rbx
    push rax
    lea rax, [rbp-80]
    pop rbx
    mov [rax], rbx
.L979:
.L977:
    mov rax, [rbp-80]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L980
    lea rax, [rbp-48]
    push rax
    lea rax, [rbp-56]
    push rax
    pop rdi
    pop rsi
    call std_number__number_add_values
    push rax
    push rdx
    lea rax, [rbp-56]
    pop rcx
    pop rbx
    mov [rax], rbx
.L980:
    mov rax, 2
    push rax
    lea rax, [rbp-32]
    push rax
    pop rdi
    pop rsi
    call std_number__number_div_small_abs
    push rax
    push rdx
    lea rax, [rbp-32]
    pop rcx
    pop rbx
    mov [rax], rbx
    mov rax, 2
    push rax
    lea rax, [rbp-40]
    push rax
    pop rdi
    pop rsi
    call std_number__number_div_small_abs
    push rax
    push rdx
    lea rax, [rbp-40]
    pop rcx
    pop rbx
    mov [rax], rbx
    mov rax, 2
    push rax
    lea rax, [rbp-48]
    push rax
    pop rdi
    pop rsi
    call std_number__number_mul_small
    push rax
    push rdx
    lea rax, [rbp-48]
    pop rcx
    pop rbx
    mov [rax], rbx
    jmp .L972
.L973:
    lea rax, [rbp-56]
    mov r10, rax
    mov rax, [r10]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_bitwise_values:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_bit_length_abs
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_bit_length_abs
    mov [rbp-40], rax
    mov rax, [rbp-32]
    mov [rbp-48], rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L982
    mov rax, [rbp-40]
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
.L982:
    mov rax, [rbp-48]
    push rax
    mov rax, 2
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_abs_clone
    mov [rbp-56], rax
    lea r12, [rbp-56]
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L984
    mov rax, [rbp-48]
    push rax
    pop rdi
    call std_number__number_pow2
    mov [rbp-64], rax
    lea r12, [rbp-64]
    mov rax, [rbp-8]
    push rax
    lea rax, [rbp-64]
    push rax
    pop rdi
    pop rsi
    call std_number__number_add_values
    push rax
    push rdx
    lea rax, [rbp-56]
    pop rcx
    pop rbx
    mov [rax], rbx
.L984:
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_abs_clone
    mov [rbp-72], rax
    lea r12, [rbp-72]
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L986
    mov rax, [rbp-48]
    push rax
    pop rdi
    call std_number__number_pow2
    mov [rbp-80], rax
    lea r12, [rbp-80]
    mov rax, [rbp-16]
    push rax
    lea rax, [rbp-80]
    push rax
    pop rdi
    pop rsi
    call std_number__number_add_values
    push rax
    push rdx
    lea rax, [rbp-72]
    pop rcx
    pop rbx
    mov [rax], rbx
.L986:
    mov rax, [rbp-24]
    push rax
    lea rax, [rbp-72]
    push rax
    lea rax, [rbp-56]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_number__number_bitwise_nonneg_abs
    mov [rbp-88], rax
    lea r12, [rbp-88]
    lea rax, [rbp-88]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L990
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L991
.L990:
    mov eax, 1
.L991:
    test rax, rax
    jz .L988
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L988:
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    pop rdi
    call std_number__number_pow2
    mov [rbp-96], rax
    lea r12, [rbp-96]
    lea rax, [rbp-96]
    push rax
    lea rax, [rbp-88]
    push rax
    pop rdi
    pop rsi
    call std_number__number_abs_cmp
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L992
    lea rax, [rbp-88]
    push rax
    pop rdi
    call std_number__number_abs_clone
    mov rsp, rbp
    pop rbp
    ret
.L992:
    mov rax, [rbp-48]
    push rax
    pop rdi
    call std_number__number_pow2
    mov [rbp-104], rax
    lea r12, [rbp-104]
    lea rax, [rbp-104]
    push rax
    lea rax, [rbp-88]
    push rax
    pop rdi
    pop rsi
    call std_number__number_sub_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_bitand_values:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 0
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_number__number_bitwise_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_bitor_values:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 1
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_number__number_bitwise_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_bitxor_values:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 2
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_number__number_bitwise_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_bitnot_values:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_negated
    mov [rbp-16], rax
    lea r12, [rbp-16]
    mov rax, 1
    push rax
    pop rdi
    call std_number__number_from_i64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    lea rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_number__number_sub_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_shift_amount_from_number:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L994
    lea rax, [rel _str996]
    push rax
    pop rdi
    call std_number__number_panic_null
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L994:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setle al
    movzx rax, al
    test rax, rax
    jz .L997
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L997:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_is_small
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L999
    mov rax, 0
    mov [rbp-16], rax
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_small_value
    push rax
    pop rdi
    pop rsi
    call std_number__number_i64_abs_mag
    mov rax, [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L999:
    mov rax, 0
    mov [rbp-24], rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_ptr
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_abs_to_u64_checked
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1001
    mov rax, 18446744073709551615
    mov rsp, rbp
    pop rbp
    ret
.L1001:
    mov rax, [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_shr_values:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L1005
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L1006
.L1005:
    mov eax, 1
.L1006:
    test rax, rax
    jz .L1003
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L1003:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1007
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_clone
    mov rsp, rbp
    pop rbp
    ret
.L1007:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    test rax, rax
    jz .L1009
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_abs_clone
    mov [rbp-24], rax
    lea r12, [rbp-24]
    mov rax, 0
    mov [rbp-32], rax
.L1011:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L1013
    mov rax, 2
    push rax
    lea rax, [rbp-24]
    push rax
    pop rdi
    pop rsi
    call std_number__number_div_small_abs
    push rax
    push rdx
    lea rax, [rbp-24]
    pop rcx
    pop rbx
    mov [rax], rbx
    lea rax, [rbp-24]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1014
    jmp .L1013
.L1014:
.L1012:
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    jmp .L1011
.L1013:
    lea rax, [rbp-24]
    mov r10, rax
    mov rax, [r10]
    mov rsp, rbp
    pop rbp
    ret
.L1009:
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_pow2
    mov [rbp-40], rax
    lea r12, [rbp-40]
    lea rax, [rbp-40]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_div_values
    mov [rbp-48], rax
    lea r12, [rbp-48]
    lea rax, [rbp-40]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_mod_values
    mov [rbp-56], rax
    lea r12, [rbp-56]
    lea rax, [rbp-56]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L1016
    mov rax, 1
    push rax
    pop rdi
    call std_number__number_from_i64
    mov [rbp-64], rax
    lea r12, [rbp-64]
    lea rax, [rbp-64]
    push rax
    lea rax, [rbp-48]
    push rax
    pop rdi
    pop rsi
    call std_number__number_sub_values
    push rax
    push rdx
    lea rax, [rbp-48]
    pop rcx
    pop rbx
    mov [rax], rbx
.L1016:
    lea rax, [rbp-48]
    mov r10, rax
    mov rax, [r10]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_clone:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1018
    lea rax, [rel _str1020]
    push rax
    pop rdi
    call std_number__number_panic_null
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L1018:
    mov rax, [rbp-8]
    mov rax, [rax]
    mov [rbp-16], rax
    mov rax, [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_from_str:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L1023
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L1024
.L1023:
    mov eax, 1
.L1024:
    test rax, rax
    jz .L1021
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L1021:
    mov rax, [rbp-8]
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
    mov rax, 1
    mov [rbp-40], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 45
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1025
    mov rax, 1
    neg rax
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    jmp .L1026
.L1025:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 43
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1027
    mov rax, 1
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
.L1027:
.L1026:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setae al
    movzx rax, al
    test rax, rax
    jz .L1029
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L1029:
    call std_number__number_make_zero
    mov [rbp-48], rax
    lea r12, [rbp-48]
.L1031:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L1033
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    mov [rbp-49], al
    movzx rax, byte [rbp-49]
    push rax
    mov rax, 48
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jnz .L1036
    movzx rax, byte [rbp-49]
    push rax
    mov rax, 57
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L1037
.L1036:
    mov eax, 1
.L1037:
    test rax, rax
    jz .L1034
    call std_number__number_make_zero
    mov rsp, rbp
    pop rbp
    ret
.L1034:
    mov rax, 10
    push rax
    lea rax, [rbp-48]
    push rax
    pop rdi
    pop rsi
    call std_number__number_mul_small
    push rax
    push rdx
    lea rax, [rbp-48]
    pop rcx
    pop rbx
    mov [rax], rbx
    movzx rax, byte [rbp-49]
    push rax
    mov rax, 48
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    pop rdi
    call std_number__number_from_u64
    mov [rbp-57], rax
    lea r12, [rbp-57]
    lea rax, [rbp-57]
    push rax
    lea rax, [rbp-48]
    push rax
    pop rdi
    pop rsi
    call std_number__number_add_values
    push rax
    push rdx
    lea rax, [rbp-48]
    pop rcx
    pop rbx
    mov [rax], rbx
.L1032:
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    jmp .L1031
.L1033:
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L1040
    lea rax, [rbp-48]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L1041
.L1040:
    xor eax, eax
.L1041:
    test rax, rax
    jz .L1038
    mov rax, 1
    neg rax
    push rax
    lea rax, [rbp-48]
    push rax
    pop rdi
    pop rsi
    call std_number__number_abs_with_sign
    push rax
    push rdx
    lea rax, [rbp-48]
    pop rcx
    pop rbx
    mov [rax], rbx
.L1038:
    lea rax, [rbp-48]
    mov r10, rax
    mov rax, [r10]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__number_input:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 0
    mov [rbp-24], rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_io__input
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L1042
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
.L1042:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rdi
    pop rsi
    call std_number__number_from_str
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number_from_i64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_from_i64
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number_from_u64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_from_u64
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number_from_str:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_from_str
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number_set_i64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1044
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1044:
    ; ERROR: Member access on non-identifier
    push rax
    mov rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number_set_u64:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1046
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1046:
    ; ERROR: Member access on non-identifier
    push rax
    mov rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number_set_from_str:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1048
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1048:
    ; ERROR: Member access on non-identifier
    push rax
    mov rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number_clone:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_clone
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_add__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_add_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_add__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_i64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_add_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_add__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_u64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_add_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_sub__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_sub_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_sub__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_i64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_sub_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_sub__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_u64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_sub_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_sub__OL:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_negated
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_mul__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_mul_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_mul__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_i64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_mul_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_mul__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_u64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_mul_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_div__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_div_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_div__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_i64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_div_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_div__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_u64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_div_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_mod__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_mod_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_mod__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_i64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_mod_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_mod__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_u64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_mod_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_bitand__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 0
    push rax
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_number__number_bitwise_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_bitand__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_i64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    mov rax, 0
    push rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_number__number_bitwise_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_bitand__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_u64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    mov rax, 0
    push rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_number__number_bitwise_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_bitor__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 1
    push rax
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_number__number_bitwise_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_bitor__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_i64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    mov rax, 1
    push rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_number__number_bitwise_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_bitor__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_u64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    mov rax, 1
    push rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_number__number_bitwise_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_bitxor__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 2
    push rax
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_number__number_bitwise_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_bitxor__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_i64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    mov rax, 2
    push rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_number__number_bitwise_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_bitxor__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_u64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    mov rax, 2
    push rax
    lea rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_number__number_bitwise_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_shl__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_shift_amount_from_number
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_shl_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_shl__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_i64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    pop rdi
    call std_number__number_shift_amount_from_number
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_shl_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_shl__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_u64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    pop rdi
    call std_number__number_shift_amount_from_number
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_shl_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_shr__OL_0000000000000014000000000000000000000000000000000000000000000006Number_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_shift_amount_from_number
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_shr_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_shr__OL_0000000000000005000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_i64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    pop rdi
    call std_number__number_shift_amount_from_number
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_shr_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_shr__OL_0000000000000004000000000000000000000000000000000000000000000000_00000000000000000000000000000000000000000000000000000000000000000000000000000000_:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_number__number_from_u64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    pop rdi
    call std_number__number_shift_amount_from_number
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_shr_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_bitnot:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_bitnot_values
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_eq:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_cmp_ptr
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_ne:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_cmp_ptr
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_lt:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_cmp_ptr
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_le:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_cmp_ptr
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setle al
    movzx rax, al
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_gt:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_cmp_ptr
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number___op_ge:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_cmp_ptr
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setge al
    movzx rax, al
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number_cmp:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__number_cmp_ptr
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number_to_i64_checked:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1050
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1050:
    mov rax, 0
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1052
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1052:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_is_small
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L1054
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_small_value
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1054:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_ptr
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_try_to_i64
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number_to_u64_checked:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1056
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1056:
    mov rax, 0
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1058
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1058:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_is_small
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L1060
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_small_value
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L1062
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1062:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1060:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_ptr
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L1066
    mov rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L1067
.L1066:
    mov eax, 1
.L1067:
    test rax, rax
    jz .L1064
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1064:
    mov rax, [rbp-32]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L1068
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1068:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rdi
    pop rsi
    call std_number__number_big_abs_to_u64_checked
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number_to_str:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, 0
    mov [rbp-16], rax
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L1070
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    lea rax, [rbp-16]
    pop rbx
    mov [rax], rbx
.L1070:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1072
    mov rax, 2
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-24], rax
    mov rax, [rbp-24]
    mov [rbp-32], rax
    mov rax, 48
    and rax, 255
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L1072:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_abs_clone
    mov [rbp-40], rax
    lea r12, [rbp-40]
    mov rax, 32
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-48], rax
    mov rdi, 24
    call std_mem__malloc
    mov r12, rax
    mov rdi, r12
    mov rsi, 0
    mov rdx, 24
    call std_mem__memset
    mov rax, [rbp-48]
    mov [r12], rax
    mov rax, 0
    mov [r12+8], rax
    mov rax, 32
    mov [r12+16], rax
    mov rax, r12
    mov [rbp-56], rax
.L1074:
    lea rax, [rbp-40]
    push rax
    pop rdi
    call std_number__number_signum
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L1075
    mov rax, 10
    push rax
    lea rax, [rbp-40]
    push rax
    pop rdi
    pop rsi
    call std_number__number_mod_small_abs
    mov [rbp-64], rax
    mov rax, 48
    push rax
    mov rax, [rbp-64]
    mov rbx, rax
    pop rax
    add rax, rbx
    and rax, 255
    push rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_push__G__T_u8
    mov rax, 10
    push rax
    lea rax, [rbp-40]
    push rax
    pop rdi
    pop rsi
    call std_number__number_div_small_abs
    push rax
    push rdx
    lea rax, [rbp-40]
    pop rcx
    pop rbx
    mov [rax], rbx
    jmp .L1074
.L1075:
    mov rax, 0
    mov [rbp-72], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L1076
    mov rax, 1
    push rax
    lea rax, [rbp-72]
    pop rbx
    mov [rax], rbx
.L1076:
    mov rax, [rbp-56]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u8
    mov [rbp-80], rax
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-80]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-88], rax
    mov rax, [rbp-88]
    mov [rbp-96], rax
    mov rax, 0
    mov [rbp-104], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L1078
    mov rax, 45
    and rax, 255
    push rax
    mov rax, [rbp-96]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 1
    push rax
    lea rax, [rbp-104]
    pop rbx
    mov [rax], rbx
.L1078:
    mov rax, [rbp-80]
    mov [rbp-112], rax
.L1080:
    mov rax, [rbp-112]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L1081
    mov rax, [rbp-112]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    lea rax, [rbp-112]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-112]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u8
    push rax
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-104]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-104]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-104]
    pop rbx
    mov [rax], rbx
    jmp .L1080
.L1081:
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-104]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-88]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_number__Number_to_i64_lossy:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, 0
    mov [rbp-16], rax
    lea rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_number__Number_to_i64_checked
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L1082
    mov rax, [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1082:
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1084
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1084:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_is_small
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L1086
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_small_value
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1086:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_number__number_big_ptr
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L1090
    mov rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L1091
.L1090:
    mov eax, 1
.L1091:
    test rax, rax
    jz .L1088
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1088:
    mov rax, [rbp-24]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_u32
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
    mov rax, [rbp-32]
    mov [rbp-48], rax
.L1092:
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L1093
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-40]
    push rax
    mov rax, 1000000000
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-24]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_get__G__T_u32
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    jmp .L1092
.L1093:
    mov rax, [rbp-24]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L1094
    mov rax, 0
    push rax
    mov rax, [rbp-40]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1094:
    mov rax, [rbp-40]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_empty:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    lea r12, [rbp-32]
    mov rax, 0
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    lea rax, [rbp-16]
    pop rbx
    mov [rax], rbx
    mov rdi, [rbp-8]
    push rdi
    lea rax, [rbp-32]
    mov rbx, rax
    pop rdi
    mov rax, [rbx]
    mov [rdi], rax
    mov rax, [rbx+8]
    mov [rdi+8], rax
    mov rax, [rbx+16]
    mov [rdi+16], rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_alloc:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    lea r12, [rbp-40]
    mov rax, [rbp-16]
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L1096
    mov rax, 1
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
.L1096:
    mov rax, [rbp-48]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1098
    mov rax, 0
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    mov rdi, [rbp-8]
    push rdi
    lea rax, [rbp-40]
    mov rbx, rax
    pop rdi
    mov rax, [rbx]
    mov [rdi], rax
    mov rax, [rbx+8]
    mov [rdi+8], rax
    mov rax, [rbx+16]
    mov [rdi+16], rax
    mov rsp, rbp
    pop rbp
    ret
.L1098:
    mov rax, [rbp-56]
    mov [rbp-64], rax
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-56]
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-48]
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    mov rdi, [rbp-8]
    push rdi
    lea rax, [rbp-40]
    mov rbx, rax
    pop rdi
    mov rax, [rbx]
    mov [rdi], rax
    mov rax, [rbx+8]
    mov [rdi+8], rax
    mov rax, [rbx+16]
    mov [rdi+16], rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_from_bytes:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-24]
    push rax
    lea rdi, [rbp-48]
    pop rsi
    call std_string__string_alloc
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1100
    mov rdi, [rbp-8]
    push rdi
    lea rax, [rbp-48]
    mov rbx, rax
    pop rdi
    mov rax, [rbx]
    mov [rdi], rax
    mov rax, [rbx+8]
    mov [rdi+8], rax
    mov rax, [rbx+16]
    mov [rdi+16], rax
    mov rsp, rbp
    pop rbp
    ret
.L1100:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L1104
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L1105
.L1104:
    xor eax, eax
.L1105:
    test rax, rax
    jz .L1102
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    lea rax, [rbp-48]
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_str__str_copy
.L1102:
    lea rax, [rbp-48]
    mov rax, [rax]
    mov [rbp-56], rax
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-24]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-24]
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    mov rdi, [rbp-8]
    push rdi
    lea rax, [rbp-48]
    mov rbx, rax
    pop rdi
    mov rax, [rbx]
    mov [rdi], rax
    mov rax, [rbx+8]
    mov [rdi+8], rax
    mov rax, [rbx+16]
    mov [rdi+16], rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_from_cstr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1106
    mov rdi, [rbp-8]
    push rdi
    pop rdi
    mov rdi, rdi
    call std_string__string_empty
    mov rsp, rbp
    pop rbp
    ret
.L1106:
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_str__str_len
    mov [rbp-24], rax
    mov rdi, [rbp-8]
    push rdi
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rsi
    pop rdx
    pop rdi
    mov rdi, rdi
    call std_string__string_from_bytes
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_from_slice:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-24], rsi
    mov [rbp-16], rdx
    mov rdi, [rbp-8]
    push rdi
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rsi
    pop rdx
    pop rdi
    mov rdi, rdi
    call std_string__string_from_bytes
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_input:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, 0
    mov [rbp-32], rax
    lea rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_io__input
    mov [rbp-40], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L1108
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
.L1108:
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1110
    mov rdi, [rbp-8]
    push rdi
    pop rdi
    mov rdi, rdi
    call std_string__string_empty
    mov rsp, rbp
    pop rbp
    ret
.L1110:
    lea r12, [rbp-64]
    mov rax, [rbp-40]
    push rax
    lea rax, [rbp-64]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-32]
    push rax
    lea rax, [rbp-56]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-16]
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
    lea rax, [rbp-64]
    add rax, 16
    mov rax, [rax]
    push rax
    lea rax, [rbp-64]
    add rax, 8
    mov rax, [rax]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L1112
    lea rax, [rbp-64]
    add rax, 8
    mov rax, [rax]
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
.L1112:
    lea rax, [rbp-64]
    add rax, 16
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L1114
    mov rax, 1
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
.L1114:
    mov rdi, [rbp-8]
    push rdi
    lea rax, [rbp-64]
    mov rbx, rax
    pop rdi
    mov rax, [rbx]
    mov [rdi], rax
    mov rax, [rbx+8]
    mov [rdi+8], rax
    mov rax, [rbx+16]
    mov [rdi+16], rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_copy:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1116
    mov rdi, [rbp-8]
    push rdi
    pop rdi
    mov rdi, rdi
    call std_string__string_empty
    mov rsp, rbp
    pop rbp
    ret
.L1116:
    mov rdi, [rbp-8]
    push rdi
    mov rax, [rbp-16]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, [rbp-16]
    mov rax, [rax]
    push rax
    pop rsi
    pop rdx
    pop rdi
    mov rdi, rdi
    call std_string__string_from_bytes
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_view:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1118
    mov rax, 0
    mov rbx, rax
    mov rax, 0
    mov rdx, rax
    mov rax, rbx
    push rax
    push rdx
    pop rdx
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1118:
    mov rax, [rbp-8]
    mov rax, [rax]
    mov rbx, rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    mov rdx, rax
    mov rax, rbx
    push rax
    push rdx
    pop rdx
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_cstr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1120
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1120:
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1122
    mov rax, 1
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1124
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1124:
    mov rax, [rbp-16]
    mov [rbp-24], rax
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-16]
    mov rsp, rbp
    pop rbp
    ret
.L1122:
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_ensure_cap:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1126
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1126:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    add rax, 16
    mov rax, [rax]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setbe al
    movzx rax, al
    test rax, rax
    jz .L1130
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L1131
.L1130:
    xor eax, eax
.L1131:
    test rax, rax
    jz .L1128
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1128:
    mov rax, [rbp-8]
    add rax, 16
    mov rax, [rax]
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L1132
    mov rax, 8
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L1132:
.L1134:
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L1136
.L1135:
    mov rax, [rbp-24]
    push rax
    mov rax, 2
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    jmp .L1134
.L1136:
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1137
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1137:
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L1141
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L1142
.L1141:
    xor eax, eax
.L1142:
    test rax, rax
    jz .L1139
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, [rbp-32]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_str__str_copy
.L1139:
    mov rax, [rbp-32]
    mov [rbp-40], rax
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    add rax, 16
    pop rbx
    mov [rax], rbx
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_append_slice:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-24], rsi
    mov [rbp-16], rdx
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1143
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1143:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1145
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1145:
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_string__string_ensure_cap
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1147
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1147:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_str__str_copy
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-8]
    mov rax, [rax]
    mov [rbp-40], rax
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_append_raw_cstr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1149
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1149:
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_str__str_len
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_string__string_append_slice
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_push_byte:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1151
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1151:
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-24], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_string__string_ensure_cap
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1153
    mov rax, 0
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1153:
    mov rax, [rbp-8]
    mov rax, [rax]
    mov [rbp-32], rax
    movzx rax, byte [rbp-16]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov rax, 0
    and rax, 255
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_release:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1155
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1155:
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L1157
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    call std_io__heap_free
.L1157:
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    add rax, 16
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_eq:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L1161
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L1162
.L1161:
    mov eax, 1
.L1162:
    test rax, rax
    jz .L1159
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1159:
    mov rax, [rbp-16]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, [rbp-16]
    mov rax, [rax]
    push rax
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    call std_str__str_eq
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_constructor:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    add rax, 16
    pop rbx
    mov [rax], rbx
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_len:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_ptr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    mov rax, [rax]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_as_slice:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_string__string_view
    push rax
    push rdx
    pop rdx
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_clone:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rdi, [rbp-8]
    push rdi
    mov rax, [rbp-16]
    push rax
    pop rsi
    pop rdi
    mov rdi, rdi
    call std_string__string_copy
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_append:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-24], rsi
    mov [rbp-16], rdx
    lea rax, [rbp-24]
    mov rbx, [rax+8]
    push rbx
    mov rbx, [rax]
    push rbx
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_string__string_append_slice
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_append_cstr:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_string__string_append_raw_cstr
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_push:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    movzx rax, byte [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_string__string_push_byte
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_free:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_string__string_release
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string_to_str:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_string__string_cstr
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string___op_eq:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, rsi
    lea rbx, [rbp-32]
    mov rcx, [rax]
    mov [rbx], rcx
    mov rcx, [rax+8]
    mov [rbx+8], rcx
    mov rcx, [rax+16]
    mov [rbx+16], rcx
    lea rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_string__string_eq
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_string__string___op_ne:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, rsi
    lea rbx, [rbp-32]
    mov rcx, [rax]
    mov [rbx], rcx
    mov rcx, [rax+8]
    mov [rbx+8], rcx
    mov rcx, [rax+16]
    mov [rbx+16], rcx
    lea rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_string__string_eq
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
main:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, 41
    push rax
    pop rdi
    call std_number__number_from_i64
    mov [rbp-8], rax
    lea r12, [rbp-8]
    lea rax, [rbp-8]
    mov rbx, rax
    lea r8, [rbp-16]
    mov rcx, [rbx]
    mov [r8], rcx
    lea rax, [rbp-16]
    push rax
    mov rax, 41
    mov rdi, rax
    call std_number__number_from_i64
    sub rsp, 8
    mov [rsp], rax
    mov rdi, [rsp+8]
    lea rsi, [rsp]
    call std_number__number_cmp_ptr
    add rsp, 16
    cmp rax, 0
    setne al
    movzx rax, al
    test rax, rax
    jz .L1163
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1163:
    mov rax, 5
    push rax
    pop rdi
    call std_number__Number_from_i64
    mov [rbp-24], rax
    lea r12, [rbp-24]
    lea rax, [rbp-24]
    push rax
    mov rax, 5
    mov rdi, rax
    call std_number__number_from_i64
    sub rsp, 8
    mov [rsp], rax
    mov rdi, [rsp+8]
    lea rsi, [rsp]
    call std_number__number_cmp_ptr
    add rsp, 16
    cmp rax, 0
    setne al
    movzx rax, al
    test rax, rax
    jz .L1165
    mov rax, 2
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1165:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_vec__Vec_len__G__T_u32:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_vec__Vec_get__G__T_u32:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    mov rax, [rax]
    mov [rbp-24], rax
    mov rax, 4
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-44], rax
    lea rax, [rbp-36]
    mov [rbp-52], rax
    mov rax, [rbp-32]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1167
    mov rax, [rbp-52]
    mov [rbp-60], rax
    mov rax, [rbp-44]
    mov [rbp-68], rax
    mov rax, [rbp-68]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-60]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    jmp .L1168
.L1167:
    mov rax, [rbp-32]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1169
    mov rax, [rbp-52]
    mov [rbp-76], rax
    mov rax, [rbp-44]
    mov [rbp-84], rax
    mov rax, [rbp-84]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-76]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-84]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-76]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    jmp .L1170
.L1169:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-44]
    push rax
    mov rax, [rbp-52]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_vec__vec_memcpy
.L1170:
.L1168:
    mov eax, [rbp-36]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_vec__Vec_pop__G__T_u32:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1171
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L1171:
    mov rax, [rbp-8]
    mov rax, [rax]
    mov [rbp-24], rax
    mov rax, 4
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-44], rax
    lea rax, [rbp-36]
    mov [rbp-52], rax
    mov rax, [rbp-32]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1173
    mov rax, [rbp-52]
    mov [rbp-60], rax
    mov rax, [rbp-44]
    mov [rbp-68], rax
    mov rax, [rbp-68]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-60]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    jmp .L1174
.L1173:
    mov rax, [rbp-32]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1175
    mov rax, [rbp-52]
    mov [rbp-76], rax
    mov rax, [rbp-44]
    mov [rbp-84], rax
    mov rax, [rbp-84]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-76]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-84]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-76]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    jmp .L1176
.L1175:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-44]
    push rax
    mov rax, [rbp-52]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_vec__vec_memcpy
.L1176:
.L1174:
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    mov rax, [rbp-8]
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov eax, [rbp-36]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_vec__Vec_push__G__T_u32:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    mov [rbp-24], rax
    mov rax, [rbp-8]
    add rax, 16
    mov rax, [rax]
    mov [rbp-32], rax
    mov rax, 4
    mov [rbp-40], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setae al
    movzx rax, al
    test rax, rax
    jz .L1177
    mov rax, [rbp-32]
    push rax
    mov rax, 2
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 4
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L1179
    mov rax, 4
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
.L1179:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-40]
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-56], rax
    mov rax, [rbp-8]
    mov rax, [rax]
    mov [rbp-64], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L1181
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_vec__vec_memcpy
.L1181:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-8]
    add rax, 16
    pop rbx
    mov [rax], rbx
.L1177:
    mov rax, [rbp-8]
    mov rax, [rax]
    mov [rbp-80], rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-88], rax
    lea rax, [rbp-16]
    mov [rbp-96], rax
    mov rax, [rbp-40]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1183
    mov rax, [rbp-88]
    mov [rbp-104], rax
    mov rax, [rbp-96]
    mov [rbp-112], rax
    mov rax, [rbp-112]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-104]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    jmp .L1184
.L1183:
    mov rax, [rbp-40]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1185
    mov rax, [rbp-88]
    mov [rbp-120], rax
    mov rax, [rbp-96]
    mov [rbp-128], rax
    mov rax, [rbp-128]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-120]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-128]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-120]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    jmp .L1186
.L1185:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-88]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_vec__vec_memcpy
.L1186:
.L1184:
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-8]
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_vec__Vec_set__G__T_u32:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov rax, [rbp-8]
    mov rax, [rax]
    mov [rbp-32], rax
    mov rax, 4
    mov [rbp-40], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-40]
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-48], rax
    lea rax, [rbp-24]
    mov [rbp-56], rax
    mov rax, [rbp-40]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1187
    mov rax, [rbp-48]
    mov [rbp-64], rax
    mov rax, [rbp-56]
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    jmp .L1188
.L1187:
    mov rax, [rbp-40]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1189
    mov rax, [rbp-48]
    mov [rbp-80], rax
    mov rax, [rbp-56]
    mov [rbp-88], rax
    mov rax, [rbp-88]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-88]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    jmp .L1190
.L1189:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_vec__vec_memcpy
.L1190:
.L1188:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_vec__Vec_push__G__T_u8:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    mov [rbp-24], rax
    mov rax, [rbp-8]
    add rax, 16
    mov rax, [rax]
    mov [rbp-32], rax
    mov rax, 1
    mov [rbp-40], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setae al
    movzx rax, al
    test rax, rax
    jz .L1191
    mov rax, [rbp-32]
    push rax
    mov rax, 2
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    mov rax, 4
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L1193
    mov rax, 4
    push rax
    lea rax, [rbp-48]
    pop rbx
    mov [rax], rbx
.L1193:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-40]
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-56], rax
    mov rax, [rbp-8]
    mov rax, [rax]
    mov [rbp-64], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov [rbp-72], rax
    mov rax, [rbp-72]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L1195
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_vec__vec_memcpy
.L1195:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-8]
    add rax, 16
    pop rbx
    mov [rax], rbx
.L1191:
    mov rax, [rbp-8]
    mov rax, [rax]
    mov [rbp-80], rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-88], rax
    lea rax, [rbp-16]
    mov [rbp-96], rax
    mov rax, [rbp-40]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1197
    mov rax, [rbp-88]
    mov [rbp-104], rax
    mov rax, [rbp-96]
    mov [rbp-112], rax
    mov rax, [rbp-112]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-104]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    jmp .L1198
.L1197:
    mov rax, [rbp-40]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1199
    mov rax, [rbp-88]
    mov [rbp-120], rax
    mov rax, [rbp-96]
    mov [rbp-128], rax
    mov rax, [rbp-128]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-120]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-128]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-120]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    jmp .L1200
.L1199:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-88]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_vec__vec_memcpy
.L1200:
.L1198:
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-8]
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_vec__Vec_len__G__T_u8:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    add rax, 8
    mov rax, [rax]
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
std_vec__Vec_get__G__T_u8:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    mov rax, [rax]
    mov [rbp-24], rax
    mov rax, 1
    mov [rbp-32], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-41], rax
    lea rax, [rbp-33]
    mov [rbp-49], rax
    mov rax, [rbp-32]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1201
    mov rax, [rbp-49]
    mov [rbp-57], rax
    mov rax, [rbp-41]
    mov [rbp-65], rax
    mov rax, [rbp-65]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-57]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    jmp .L1202
.L1201:
    mov rax, [rbp-32]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L1203
    mov rax, [rbp-49]
    mov [rbp-73], rax
    mov rax, [rbp-41]
    mov [rbp-81], rax
    mov rax, [rbp-81]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-73]
    push rax
    mov rax, 0
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-81]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, [rbp-73]
    push rax
    mov rax, 1
    imul rax, 8
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], rbx
    jmp .L1204
.L1203:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-41]
    push rax
    mov rax, [rbp-49]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_vec__vec_memcpy
.L1204:
.L1202:
    movzx rax, byte [rbp-33]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
default rel
section .text
global _start
_start:
    pop rdi          ; argc
    mov rsi, rsp     ; argv
    push rsi
    push rdi
    call main
    mov rdi, rax
    mov rax, 60
    syscall

section .data
_str106: db 116,114,117,101,0
_str109: db 102,97,108,115,101,0
_str211: db 91,80,65,78,73,67,93,32,0
_str212: db 10,0
_str219: db 101,109,105,116,108,110,58,32,105,110,118,97,108,105,100,32,67,45,115,116,114,105,110,103,32,112,111,105,110,116,101,114,0
_str222: db 101,109,105,116,58,32,105,110,118,97,108,105,100,32,67,45,115,116,114,105,110,103,32,112,111,105,110,116,101,114,0
_str225: db 101,109,105,116,95,108,101,110,58,32,105,110,118,97,108,105,100,32,67,45,115,116,114,105,110,103,32,112,111,105,110,116,101,114,0
_str228: db 112,114,105,110,116,58,32,105,110,118,97,108,105,100,32,67,45,115,116,114,105,110,103,32,112,111,105,110,116,101,114,0
_str231: db 112,114,105,110,116,108,110,58,32,105,110,118,97,108,105,100,32,67,45,115,116,114,105,110,103,32,112,111,105,110,116,101,114,0
_str232: db 112,114,105,110,116,95,99,115,116,114,58,32,105,110,118,97,108,105,100,32,67,45,115,116,114,105,110,103,32,112,111,105,110,116,101,114,0
_str233: db 112,114,105,110,116,108,110,95,99,115,116,114,58,32,105,110,118,97,108,105,100,32,67,45,115,116,114,105,110,103,32,112,111,105,110,116,101,114,0
_str247: db 45,57,50,50,51,51,55,50,48,51,54,56,53,52,55,55,53,56,48,56,0
_str250: db 45,0
_str276: db 110,97,110,0
_str304: db 62,0
_str305: db 60,115,108,105,99,101,32,108,101,110,61,0
_str306: db 60,97,114,114,97,121,32,108,101,110,61,0
_str307: db 60,0
_str308: db 60,102,117,110,99,62,0
_str309: db 110,117,108,108,0
_str384: db 32,32,40,110,111,32,115,116,97,99,107,32,116,114,97,99,101,32,97,118,97,105,108,97,98,108,101,41,0
_str387: db 32,32,40,115,116,97,99,107,32,116,114,97,99,101,32,105,115,32,101,109,112,116,121,41,0
_str388: db 83,116,97,99,107,32,116,114,97,99,101,32,40,109,111,115,116,32,114,101,99,101,110,116,32,99,97,108,108,32,102,105,114,115,116,41,58,0
_str392: db 32,32,97,116,32,0
_str393: db 32,40,0
_str394: db 58,0
_str395: db 41,0
_str398: db 91,69,82,82,79,82,93,32,0
_str403: db 80,97,114,115,105,110,103,32,99,111,110,116,101,120,116,58,0
_str404: db 32,32,45,62,32,73,110,32,102,117,110,99,116,105,111,110,58,32,0
_str405: db 32,40,108,105,110,101,32,0
_str406: db 67,111,109,112,105,108,101,114,32,105,110,116,101,114,110,97,108,32,116,114,97,99,101,58,0
_str409: db 69,114,114,111,114,32,100,101,116,97,105,108,115,58,0
_str410: db 91,68,69,66,85,71,93,32,0
_str411: db 32,97,116,32,108,105,110,101,32,0
_str421: db 91,87,65,82,78,93,32,0
_str533: db 110,117,109,98,101,114,95,105,115,95,115,109,97,108,108,58,32,110,117,108,108,32,78,117,109,98,101,114,42,0
_str536: db 110,117,109,98,101,114,95,115,109,97,108,108,95,118,97,108,117,101,58,32,110,117,108,108,32,78,117,109,98,101,114,42,0
_str700: db 78,117,109,98,101,114,32,100,105,118,105,100,101,32,98,121,32,122,101,114,111,0
_str712: db 78,117,109,98,101,114,32,109,111,100,117,108,111,32,98,121,32,122,101,114,111,0
_str735: db 110,117,109,98,101,114,95,115,105,103,110,117,109,58,32,110,117,108,108,32,78,117,109,98,101,114,42,0
_str750: db 110,117,109,98,101,114,95,110,101,103,97,116,101,100,58,32,110,117,108,108,32,78,117,109,98,101,114,42,0
_str759: db 110,117,109,98,101,114,95,97,98,115,95,119,105,116,104,95,115,105,103,110,58,32,110,117,108,108,32,78,117,109,98,101,114,42,0
_str776: db 110,117,109,98,101,114,95,97,98,115,95,99,109,112,58,32,110,117,108,108,32,108,104,115,0
_str779: db 110,117,109,98,101,114,95,97,98,115,95,99,109,112,58,32,110,117,108,108,32,114,104,115,0
_str806: db 110,117,109,98,101,114,95,99,109,112,95,112,116,114,58,32,110,117,108,108,32,108,104,115,0
_str809: db 110,117,109,98,101,114,95,99,109,112,95,112,116,114,58,32,110,117,108,108,32,114,104,115,0
_str870: db 110,117,109,98,101,114,95,100,105,118,95,118,97,108,117,101,115,58,32,110,117,108,108,32,108,104,115,0
_str873: db 110,117,109,98,101,114,95,100,105,118,95,118,97,108,117,101,115,58,32,110,117,108,108,32,114,104,115,0
_str878: db 110,117,109,98,101,114,95,109,111,100,95,118,97,108,117,101,115,58,32,110,117,108,108,32,108,104,115,0
_str881: db 110,117,109,98,101,114,95,109,111,100,95,118,97,108,117,101,115,58,32,110,117,108,108,32,114,104,115,0
_str892: db 110,117,109,98,101,114,95,97,98,115,95,99,108,111,110,101,58,32,110,117,108,108,32,78,117,109,98,101,114,42,0
_str899: db 110,117,109,98,101,114,95,100,105,118,95,115,109,97,108,108,95,97,98,115,58,32,110,117,108,108,32,78,117,109,98,101,114,42,0
_str908: db 110,117,109,98,101,114,95,109,111,100,95,115,109,97,108,108,95,97,98,115,58,32,110,117,108,108,32,78,117,109,98,101,114,42,0
_str996: db 110,117,109,98,101,114,95,115,104,105,102,116,95,97,109,111,117,110,116,95,102,114,111,109,95,110,117,109,98,101,114,58,32,110,117,108,108,32,114,104,115,0
_str1020: db 110,117,109,98,101,114,95,99,108,111,110,101,58,32,110,117,108,108,32,78,117,109,98,101,114,42,0

section .data
_flt114: dq 0.0
_flt129: dq 10.0
_flt134: dq 0.1

section .bss
_gvar_std_os__g_syscall_arg0: resb 8
_gvar_std_os__g_syscall_arg1: resb 8
_gvar_std_os__g_syscall_arg2: resb 8
_gvar_std_os__g_syscall_arg3: resb 8
_gvar_std_os__g_syscall_ret: resb 8
_gvar_std_io__heap_inited: resb 8
_gvar_std_io__heap_brk: resb 8
_gvar_std_io__heap_reserved_end: resb 8
_gvar_std_io__heap_base: resb 8
_gvar_std_io__heap_free_head: resb 8
_gvar_std_io__g_out_fd: resb 8
_gvar_std_io__g_out_buf: resb 8
_gvar_std_io__g_out_buf_len: resb 8
_gvar_std_io__g_print_u64_buf: resb 8
_gvar_std_util__g_stack_frames: resb 8
_gvar_std_util__g_stack_depth: resb 8
_gvar_std_util__g_stack_initialized: resb 8
_gvar_std_util__g_last_error_msg: resb 8
_gvar_std_util__g_last_error_len: resb 8
_gvar_std_util__g_error_buffer: resb 8
_gvar_std_util__g_error_buffer_pos: resb 8
_gvar_std_util__g_capturing_error: resb 8
_gvar_std_util__g_current_func_name: resb 8
_gvar_std_util__g_current_func_name_len: resb 8
_gvar_std_util__g_current_func_line: resb 8
_gvar_std_util__g_emit_char_buf: resb 8
_gvar_std_util__g_emit_u64_buf: resb 8
_gvar_std_util__g_emit_u64_stderr_buf: resb 8
