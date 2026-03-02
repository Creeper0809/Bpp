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
    push rax
    pop rax
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
.L28:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L29
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L30
    mov rax, 1
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L30:
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_io__heap_block_get_next
    push rax
    lea rax, [rbp-16]
    pop rbx
    mov [rax], rbx
    jmp .L28
.L29:
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
.L32:
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L33
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
    jz .L34
    jmp .L33
.L34:
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
    jz .L36
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
    jmp .L32
.L36:
    mov rax, [rbp-16]
    push rax
    lea rax, [rbp-8]
    pop rbx
    mov [rax], rbx
    jmp .L32
.L33:
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
    jz .L38
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L38:
    mov rax, [rel _gvar_std_io__heap_free_head]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jnz .L42
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
    jmp .L43
.L42:
    mov eax, 1
.L43:
    test rax, rax
    jz .L40
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
.L40:
    mov rax, [rel _gvar_std_io__heap_free_head]
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    call std_io__heap_block_get_next
    mov [rbp-24], rax
.L44:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L46
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
    jmp .L47
.L46:
    xor eax, eax
.L47:
    test rax, rax
    jz .L45
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
    jmp .L44
.L45:
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
.L48:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L49
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
    jz .L50
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
    jz .L52
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
    jz .L54
    mov rax, [rbp-56]
    push rax
    lea rax, [rel _gvar_std_io__heap_free_head]
    pop rbx
    mov [rax], rbx
    jmp .L55
.L54:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_io__heap_block_set_next
.L55:
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    pop rsi
    call std_io__heap_block_set_size
    jmp .L53
.L52:
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L56
    mov rax, [rbp-40]
    push rax
    lea rax, [rel _gvar_std_io__heap_free_head]
    pop rbx
    mov [rax], rbx
    jmp .L57
.L56:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    call std_io__heap_block_set_next
.L57:
.L53:
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
.L50:
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
    jmp .L48
.L49:
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
    jz .L58
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L58:
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
    jz .L60
    mov rax, [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
.L60:
    mov rax, [rel _gvar_std_io__heap_inited]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L62
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
.L62:
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
    jz .L64
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
    jz .L66
    mov rax, 1048576
    push rax
    lea rax, [rbp-72]
    pop rbx
    mov [rax], rbx
.L66:
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
    jz .L68
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L68:
    mov rax, [rbp-80]
    push rax
    lea rax, [rel _gvar_std_io__heap_reserved_end]
    pop rbx
    mov [rax], rbx
.L64:
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
    jz .L70
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L70:
    mov rax, [rel _gvar_std_io__heap_inited]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L72
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L72:
    mov rax, [rbp-8]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L74
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L74:
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
    jnz .L78
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
    jz .L80
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L80:
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
    jz .L82
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L82:
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
std_io__emitln:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
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
    lea rax, [rel _str84]
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
    jz .L85
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L85:
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
    jz .L87
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L87:
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
    mov rax, [rbp-16]
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
std_io__print_nl:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, 1
    push rax
    lea rax, [rel _str84]
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
std_io__println:
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
    call std_io__io_write_out
    mov rax, 1
    push rax
    lea rax, [rel _str84]
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
    jz .L89
    mov rax, 48
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
.L89:
    mov rax, 0
    mov [rbp-32], rax
    mov rax, [rbp-16]
    mov [rbp-40], rax
.L91:
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L93
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
.L92:
    jmp .L91
.L93:
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
.L94:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-56]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L96
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
.L95:
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
    jmp .L94
.L96:
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
    mov rax, [rel _gvar_std_io__g_print_u64_buf]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L97
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
.L97:
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
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L99
    mov rax, 1
    push rax
    lea rax, [rel _str101]
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
    jmp .L100
.L99:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_io__print_u64
.L100:
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
.L102:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L104
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L103:
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
    jmp .L102
.L104:
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
    jz .L107
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
    jmp .L108
.L107:
    xor eax, eax
.L108:
    test rax, rax
    jz .L105
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L105:
    mov rax, [rbp-8]
    push rax
    mov rax, 97
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setae al
    movzx rax, al
    test rax, rax
    jz .L111
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
    jmp .L112
.L111:
    xor eax, eax
.L112:
    test rax, rax
    jz .L109
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L109:
    mov rax, [rbp-8]
    push rax
    mov rax, 95
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L113
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L113:
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
    jz .L117
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
    jmp .L118
.L117:
    xor eax, eax
.L118:
    test rax, rax
    jz .L115
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L115:
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
    jz .L119
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L119:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_char__is_digit
    test rax, rax
    jz .L121
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L121:
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
    jz .L123
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L123:
    mov rax, [rbp-8]
    push rax
    mov rax, 9
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L125
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L125:
    mov rax, [rbp-8]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L127
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L127:
    mov rax, [rbp-8]
    push rax
    mov rax, 13
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L129
    mov rax, 1
    and rax, 255
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L129:
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
.L131:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L133
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
    jz .L134
    mov rax, [rbp-40]
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L134:
.L132:
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
    jmp .L131
.L133:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L136
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
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 0
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
.L136:
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
.L138:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L140
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
    jz .L141
    mov rax, [rbp-40]
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L141:
.L139:
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
    jmp .L138
.L140:
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
    jz .L143
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
.L143:
    mov rax, 1
    neg rax
    mov [rbp-56], rax
    mov rax, [rbp-48]
    mov [rbp-64], rax
.L145:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L147
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
    jz .L148
    mov rax, [rbp-64]
    push rax
    lea rax, [rbp-56]
    pop rbx
    mov [rax], rbx
.L148:
.L146:
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
    jmp .L145
.L147:
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
    jz .L150
    mov rax, [rbp-56]
    push rax
    lea rax, [rbp-72]
    pop rbx
    mov [rax], rbx
.L150:
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L152
    mov rax, [rbp-48]
    push rax
    lea rax, [rbp-72]
    pop rbx
    mov [rax], rbx
.L152:
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
    jz .L154
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
.L154:
    mov rax, 0
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
    jz .L156
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L156:
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
    jnz .L160
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
    jmp .L161
.L160:
    mov eax, 1
.L161:
    test rax, rax
    jz .L158
    call std_util__init_stack_trace
.L158:
    mov rax, [rel _gvar_std_util__g_stack_frames]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L162
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L162:
    mov rax, [rel _gvar_std_util__g_stack_depth]
    push rax
    mov rax, 128
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setae al
    movzx rax, al
    test rax, rax
    jz .L164
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L164:
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
    jz .L166
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L166:
    mov rax, [rel _gvar_std_util__g_stack_depth]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L168
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L168:
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
    jz .L170
    lea rax, [rel _str172]
    push rax
    pop rdi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L170:
    mov rax, [rel _gvar_std_util__g_stack_depth]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L173
    lea rax, [rel _str175]
    push rax
    pop rdi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L173:
    lea rax, [rel _str176]
    push rax
    pop rdi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
    mov rax, [rel _gvar_std_util__g_stack_depth]
    mov [rbp-8], rax
.L177:
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    seta al
    movzx rax, al
    test rax, rax
    jz .L179
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
    lea rax, [rel _str180]
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
    lea rax, [rel _str181]
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
    lea rax, [rel _str182]
    push rax
    pop rdi
    call std_util__emit_stderr
    mov rax, [rbp-72]
    push rax
    pop rdi
    call std_util__emit_i64_stderr
    lea rax, [rel _str183]
    push rax
    pop rdi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
.L178:
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
    jmp .L177
.L179:
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
    jz .L184
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
.L184:
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
    lea rax, [rel _str186]
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
    jz .L187
    lea rax, [rel _str189]
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
.L187:
    mov rax, [rel _gvar_std_util__g_current_func_name]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L190
    call std_util__emit_stderr_nl
    lea rax, [rel _str192]
    push rax
    pop rdi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
    lea rax, [rel _str193]
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
    lea rax, [rel _str194]
    push rax
    pop rdi
    call std_util__emit_stderr
    mov rax, [rel _gvar_std_util__g_current_func_line]
    push rax
    pop rdi
    call std_util__emit_i64_stderr
    lea rax, [rel _str183]
    push rax
    pop rdi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
.L190:
    call std_util__emit_stderr_nl
    lea rax, [rel _str195]
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
    jz .L196
    call std_util__emit_stderr_nl
    lea rax, [rel _str198]
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
.L196:
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
    lea rax, [rel _str199]
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
    lea rax, [rel _str200]
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
    jz .L201
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L201:
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
    jz .L203
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
    jz .L205
    mov rax, [rel _gvar_std_util__g_error_buffer]
    mov [rbp-24], rax
    mov rax, [rbp-8]
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
.L207:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L209
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
.L208:
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
    jmp .L207
.L209:
.L205:
    jmp .L204
.L203:
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
.L204:
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
    lea rax, [rel _str84]
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
    lea rax, [rel _str210]
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
    jz .L211
    mov rax, 1
    push rax
    pop rdi
    call std_io__heap_alloc
    push rax
    lea rax, [rel _gvar_std_util__g_emit_char_buf]
    pop rbx
    mov [rax], rbx
.L211:
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
    mov rax, 1
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
    jz .L213
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
.L213:
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
    mov rax, 1
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
    jz .L215
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
.L215:
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
    jz .L217
    lea rax, [rel _str101]
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
    jmp .L218
.L217:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_util__emit_u64
.L218:
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
    jz .L219
    lea rax, [rel _str101]
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
    jmp .L220
.L219:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_util__emit_u64_stderr
.L220:
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
    lea rax, [rel _str84]
    push rax
    mov rax, 1
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
    jz .L221
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L221:
    mov rax, [rbp-24]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L223
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
.L223:
    mov rax, [rbp-24]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L225
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
.L225:
    mov rax, [rbp-24]
    push rax
    mov rax, 24
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L227
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
.L227:
    mov rax, [rbp-24]
    push rax
    mov rax, 32
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L229
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
.L229:
    mov rax, [rbp-24]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L231
    mov rax, [rbp-8]
    mov [rbp-96], rax
    mov rax, [rbp-16]
    mov [rbp-104], rax
    mov rax, 0
    mov [rbp-112], rax
.L233:
    mov rax, [rbp-112]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L235
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
.L234:
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
    jmp .L233
.L235:
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L231:
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
.L236:
    mov rax, [rbp-152]
    push rax
    mov rax, [rbp-120]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L238
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
.L237:
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
    jmp .L236
.L238:
    mov rax, [rbp-128]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L239
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
.L241:
    mov rax, [rbp-184]
    push rax
    mov rax, [rbp-128]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L243
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
.L242:
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
    jmp .L241
.L243:
.L239:
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
    jz .L244
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L244:
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
.L246:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L248
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
.L247:
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
    jmp .L246
.L248:
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L249
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
.L251:
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L253
    mov rax, 0
    push rax
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-72]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L252:
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
    jmp .L251
.L253:
.L249:
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
    jz .L254
    mov rax, 0
    push rax
    pop rax
    mov rsp, rbp
    pop rbp
    ret
.L254:
    mov rax, [rbp-24]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L256
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
.L256:
    mov rax, [rbp-24]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L258
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
.L258:
    mov rax, [rbp-24]
    push rax
    mov rax, 24
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L260
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
.L260:
    mov rax, [rbp-24]
    push rax
    mov rax, 32
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L262
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
.L262:
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
.L264:
    mov rax, [rbp-128]
    push rax
    mov rax, [rbp-96]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L266
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
.L265:
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
    jmp .L264
.L266:
    mov rax, [rbp-104]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L267
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
.L269:
    mov rax, [rbp-160]
    push rax
    mov rax, [rbp-104]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L271
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
.L270:
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
    jmp .L269
.L271:
.L267:
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
.L272:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-40]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L274
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
.L273:
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
    jmp .L272
.L274:
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L275
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
.L277:
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setb al
    movzx rax, al
    test rax, rax
    jz .L279
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
.L278:
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
    jmp .L277
.L279:
.L275:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L280
    mov rax, 1
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L280:
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
main:
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
StackFrame_constructor:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
Vec_constructor__G__T_t:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
HashMap_constructor__G__T_t_T_t:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
section .text
align 16
HashEntry_constructor__G__T_t:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
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
_str84: db 10,0
_str101: db 45,0
_str172: db 32,32,40,110,111,32,115,116,97,99,107,32,116,114,97,99,101,32,97,118,97,105,108,97,98,108,101,41,0
_str175: db 32,32,40,115,116,97,99,107,32,116,114,97,99,101,32,105,115,32,101,109,112,116,121,41,0
_str176: db 83,116,97,99,107,32,116,114,97,99,101,32,40,109,111,115,116,32,114,101,99,101,110,116,32,99,97,108,108,32,102,105,114,115,116,41,58,0
_str180: db 32,32,97,116,32,0
_str181: db 32,40,0
_str182: db 58,0
_str183: db 41,0
_str186: db 91,69,82,82,79,82,93,32,0
_str189: db 91,80,65,78,73,67,93,32,0
_str192: db 80,97,114,115,105,110,103,32,99,111,110,116,101,120,116,58,0
_str193: db 32,32,45,62,32,73,110,32,102,117,110,99,116,105,111,110,58,32,0
_str194: db 32,40,108,105,110,101,32,0
_str195: db 67,111,109,112,105,108,101,114,32,105,110,116,101,114,110,97,108,32,116,114,97,99,101,58,0
_str198: db 69,114,114,111,114,32,100,101,116,97,105,108,115,58,0
_str199: db 91,68,69,66,85,71,93,32,0
_str200: db 32,97,116,32,108,105,110,101,32,0
_str210: db 91,87,65,82,78,93,32,0

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
