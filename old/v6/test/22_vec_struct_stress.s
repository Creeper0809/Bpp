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
    mov rsp, rbp
    pop rbp
    ret
.L0:
    mov rax, [rbp-8]
    mov [rbp-40], rax
    mov rax, [rbp-24]
    mov [rbp-48], rax
    mov rax, 0
    mov [rbp-56], rax
.L2:
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L4
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-56]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-56]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L5
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L5:
.L3:
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
    jmp .L2
.L4:
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
.L7:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L9
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
.L8:
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
    jmp .L7
.L9:
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_str__str_len:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    mov [rbp-16], rax
    mov rax, 0
    mov [rbp-24], rax
.L10:
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
    jz .L12
.L11:
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
    jmp .L10
.L12:
    mov rax, [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    mov rax, [rbp-40]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_str__str_copy
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-40]
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
    mov rax, [rbp-56]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_str__str_copy
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-56]
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
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_str__str_copy
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
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    jz .L13
    mov rax, 1
    neg rax
    mov rsp, rbp
    pop rbp
    ret
.L13:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L15
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
    mov rax, 1
    push rax
    pop rdi
    call std_os__os_sys_exit
    mov rax, [rbp-32]
    mov rsp, rbp
    pop rbp
    ret
.L15:
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
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_io__sys_brk:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_os__os_sys_brk
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_io__sys_close:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_os__os_sys_close
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    jz .L17
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L17:
    mov rax, [rel _gvar_std_io__g_out_fd]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    jz .L19
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L19:
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
    mov rax, 7
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
    mov rax, [rel _gvar_std_io__heap_inited]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L21
    mov rax, 0
    push rax
    pop rdi
    call std_os__os_sys_brk
    push rax
    lea rax, [rel _gvar_std_io__heap_brk]
    pop rbx
    mov [rax], rbx
    mov rax, 1
    push rax
    lea rax, [rel _gvar_std_io__heap_inited]
    pop rbx
    mov [rax], rbx
.L21:
    mov rax, [rel _gvar_std_io__heap_brk]
    push rax
    mov rax, 7
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    and rax, rbx
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-32]
    mov [rbp-40], rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-48], rax
    mov rax, [rbp-48]
    push rax
    pop rdi
    call std_os__os_sys_brk
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L23
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
.L23:
    mov rax, [rbp-48]
    push rax
    lea rax, [rel _gvar_std_io__heap_brk]
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-40]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    mov rax, 1
    push rax
    lea rax, [rel _str25]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_os__os_sys_write
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_io__emit:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, [rbp-8]
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
.L26:
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L28
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L29
    mov rax, [rbp-32]
    push rax
    lea rax, [rbp-16]
    pop rbx
    mov [rax], rbx
    jmp .L28
.L29:
.L27:
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
    jmp .L26
.L28:
    call std_io__io_get_output_fd
    mov [rbp-40], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_os__os_sys_write
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_io__print:
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
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_io__print_nl:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    call std_io__io_get_output_fd
    mov [rbp-8], rax
    mov rax, 1
    push rax
    lea rax, [rel _str25]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_os__os_sys_write
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_io__println:
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
    mov rax, 1
    push rax
    lea rax, [rel _str25]
    push rax
    mov rax, [rbp-24]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_os__os_sys_write
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_io__print_u64:
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
    jz .L31
    call std_io__io_get_output_fd
    mov [rbp-16], rax
    mov rax, 1
    push rax
    lea rax, [rel _str33]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_os__os_sys_write
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L31:
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
    mov rax, [rbp-8]
    mov [rbp-48], rax
.L34:
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    test rax, rax
    jz .L36
    mov rax, [rbp-48]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    xor rdx, rdx
    div rbx
    mov rax, rdx
    mov [rbp-56], rax
    mov rax, [rbp-56]
    push rax
    mov rax, 48
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
.L35:
    jmp .L34
.L36:
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov [rbp-64], rax
.L37:
    mov rax, [rbp-64]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setge al
    movzx rax, al
    test rax, rax
    jz .L39
    call std_io__io_get_output_fd
    mov [rbp-72], rax
    mov rax, 1
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-64]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-72]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_os__os_sys_write
.L38:
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
    jmp .L37
.L39:
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    jz .L40
    call std_io__io_get_output_fd
    mov [rbp-16], rax
    mov rax, 1
    push rax
    lea rax, [rel _str42]
    push rax
    mov rax, [rbp-16]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_os__os_sys_write
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    pop rdi
    call std_io__print_u64
    jmp .L41
.L40:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_io__print_u64
.L41:
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
.L43:
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L45
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L44:
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
    jmp .L43
.L45:
    mov rax, [rbp-8]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_mem__malloc:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_io__heap_alloc
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_mem__free:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    setge al
    movzx rax, al
    test rax, rax
    jz .L48
    mov rax, [rbp-8]
    push rax
    mov rax, 90
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setle al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L49
.L48:
    xor eax, eax
.L49:
    test rax, rax
    jz .L46
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L46:
    mov rax, [rbp-8]
    push rax
    mov rax, 97
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setge al
    movzx rax, al
    test rax, rax
    jz .L52
    mov rax, [rbp-8]
    push rax
    mov rax, 122
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setle al
    movzx rax, al
    test rax, rax
    setne al
    movzx rax, al
    jmp .L53
.L52:
    xor eax, eax
.L53:
    test rax, rax
    jz .L50
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L50:
    mov rax, [rbp-8]
    push rax
    mov rax, 95
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L54
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L54:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    setge al
    movzx rax, al
    test rax, rax
    jz .L58
    mov rax, [rbp-8]
    push rax
    mov rax, 57
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setle al
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
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L56:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    jz .L60
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L60:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_char__is_digit
    test rax, rax
    jz .L62
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L62:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    jz .L64
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L64:
    mov rax, [rbp-8]
    push rax
    mov rax, 9
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L66
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L66:
    mov rax, [rbp-8]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L68
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L68:
    mov rax, [rbp-8]
    push rax
    mov rax, 13
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L70
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L70:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_path__path_dirname:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 0
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov [rbp-24], rax
    mov rax, [rbp-8]
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
.L72:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L74
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
    jz .L75
    mov rax, [rbp-40]
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L75:
.L73:
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
    jmp .L72
.L74:
    mov rax, [rbp-24]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L77
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
.L77:
    mov rax, [rbp-24]
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
    mov [rbp-64], rax
    mov rax, [rbp-64]
    mov [rbp-72], rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-8]
    push rax
    mov rax, [rbp-64]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_str__str_copy
    mov rax, 0
    push rax
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-24]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-64]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_path__path_join:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov [rbp-24], rdx
    mov [rbp-32], rcx
    mov rax, 1
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-40], rax
    mov rax, [rbp-40]
    mov [rbp-48], rax
    mov rax, 47
    push rax
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, 1
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop r8
    pop r9
    call std_str__str_concat3
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_path__module_to_path:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 4
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
    mov rax, 46
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 0
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 98
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 112
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 2
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 112
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, 3
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
    mov rax, 4
    push rax
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    call std_str__str_concat
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_path__path_basename_noext:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 0
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov [rbp-24], rax
    mov rax, [rbp-8]
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
.L79:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L81
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
    jz .L82
    mov rax, [rbp-40]
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L82:
.L80:
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
    jmp .L79
.L81:
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
    jz .L84
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
.L84:
    mov rax, 0
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov [rbp-56], rax
    mov rax, [rbp-48]
    mov [rbp-64], rax
.L86:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L88
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
    jz .L89
    mov rax, [rbp-64]
    push rax
    lea rax, [rbp-56]
    pop rbx
    mov [rax], rbx
.L89:
.L87:
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
    jmp .L86
.L88:
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
    jz .L91
    mov rax, [rbp-56]
    push rax
    lea rax, [rbp-72]
    pop rbx
    mov [rax], rbx
.L91:
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L93
    mov rax, [rbp-48]
    push rax
    lea rax, [rbp-72]
    pop rbx
    mov [rax], rbx
.L93:
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
    setg al
    movzx rax, al
    test rax, rax
    jz .L95
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
.L95:
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
std_util__init_stack_trace:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, [rel _gvar_std_util__g_stack_initialized]
    test rax, rax
    jz .L97
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L97:
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
    jz .L99
    call std_util__init_stack_trace
.L99:
    mov rax, [rel _gvar_std_util__g_stack_depth]
    push rax
    mov rax, 128
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setge al
    movzx rax, al
    test rax, rax
    jz .L101
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L101:
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
    push rax
    pop rax
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rax
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rax
    add rax, 16
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rax
    add rax, 24
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rax
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
std_util__pop_trace:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, [rel _gvar_std_util__g_stack_depth]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    test rax, rax
    jz .L103
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
.L103:
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_util__print_stack_trace:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, [rel _gvar_std_util__g_stack_initialized]
    test rax, rax
    setz al
    movzx rax, al
    test rax, rax
    jz .L105
    mov rax, 28
    push rax
    lea rax, [rel _str107]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L105:
    mov rax, [rel _gvar_std_util__g_stack_depth]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    sete al
    movzx rax, al
    test rax, rax
    jz .L108
    mov rax, 24
    push rax
    lea rax, [rel _str110]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L108:
    mov rax, 38
    push rax
    lea rax, [rel _str111]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
    mov rax, [rel _gvar_std_util__g_stack_depth]
    mov [rbp-8], rax
.L112:
    mov rax, [rbp-8]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    test rax, rax
    jz .L114
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
    push rax
    pop rax
    mov rax, [rax]
    mov [rbp-40], rax
    mov rax, [rbp-32]
    push rax
    pop rax
    add rax, 8
    mov rax, [rax]
    mov [rbp-48], rax
    mov rax, [rbp-32]
    push rax
    pop rax
    add rax, 16
    mov rax, [rax]
    mov [rbp-56], rax
    mov rax, [rbp-32]
    push rax
    pop rax
    add rax, 24
    mov rax, [rax]
    mov [rbp-64], rax
    mov rax, [rbp-32]
    push rax
    pop rax
    add rax, 32
    mov rax, [rax]
    mov [rbp-72], rax
    mov rax, 5
    push rax
    lea rax, [rel _str115]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-40]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    mov rax, 2
    push rax
    lea rax, [rel _str116]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-56]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    mov rax, 1
    push rax
    lea rax, [rel _str117]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    mov rax, [rbp-72]
    push rax
    pop rdi
    call std_util__emit_i64_stderr
    mov rax, 1
    push rax
    lea rax, [rel _str118]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
.L113:
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
    jmp .L112
.L114:
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    jz .L119
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
.L119:
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
std_util__emit_error:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 8
    push rax
    lea rax, [rel _str121]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
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
std_util__panic:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    call std_util__end_error_capture
    mov rax, [rel _gvar_std_util__g_current_func_name]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L122
    call std_util__emit_stderr_nl
    mov rax, 16
    push rax
    lea rax, [rel _str124]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
    mov rax, 18
    push rax
    lea rax, [rel _str125]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    mov rax, [rel _gvar_std_util__g_current_func_name_len]
    push rax
    mov rax, [rel _gvar_std_util__g_current_func_name]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    mov rax, 7
    push rax
    lea rax, [rel _str126]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    mov rax, [rel _gvar_std_util__g_current_func_line]
    push rax
    pop rdi
    call std_util__emit_i64_stderr
    mov rax, 1
    push rax
    lea rax, [rel _str118]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
.L122:
    call std_util__emit_stderr_nl
    mov rax, 24
    push rax
    lea rax, [rel _str127]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
    call std_util__print_stack_trace
    mov rax, [rel _gvar_std_util__g_error_buffer_pos]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    test rax, rax
    jz .L128
    call std_util__emit_stderr_nl
    mov rax, 14
    push rax
    lea rax, [rel _str130]
    push rax
    pop rdi
    pop rsi
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
.L128:
    call std_util__emit_stderr_nl
    mov rax, 0
    mov rax, [rax]
    mov [rbp-8], rax
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_util__emit_stderr:
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
    jz .L131
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
    jz .L133
    mov rax, [rel _gvar_std_util__g_error_buffer]
    mov [rbp-24], rax
    mov rax, [rbp-8]
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
.L135:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L137
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
.L136:
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
    jmp .L135
.L137:
.L133:
    jmp .L132
.L131:
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
.L132:
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_util__emit_stderr_nl:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, 1
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-8], rax
    mov rax, [rbp-8]
    mov [rbp-16], rax
    mov rax, 10
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
    mov rax, [rbp-8]
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
std_util__warn:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 7
    push rax
    lea rax, [rel _str138]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    call std_util__emit_stderr_nl
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_util__emit_char:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, 1
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-16], rax
    mov rax, [rbp-16]
    mov [rbp-24], rax
    mov rax, [rbp-8]
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
std_util__emit_u64:
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
    jz .L139
    mov rax, 1
    push rax
    lea rax, [rel _str33]
    push rax
    pop rdi
    pop rsi
    call std_io__emit
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L139:
    mov rax, 32
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
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
    mov rax, [rbp-8]
    mov [rbp-40], rax
.L141:
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    test rax, rax
    jz .L143
    mov rax, 48
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    cqo
    idiv rbx
    mov rax, rdx
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
    cqo
    idiv rbx
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
.L142:
    jmp .L141
.L143:
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov [rbp-48], rax
.L144:
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setge al
    movzx rax, al
    test rax, rax
    jz .L146
    mov rax, 1
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 1
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_io__sys_write
.L145:
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
    jmp .L144
.L146:
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_util__emit_u64_stderr:
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
    jz .L147
    mov rax, 1
    push rax
    lea rax, [rel _str33]
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret
.L147:
    mov rax, 32
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
    mov [rbp-24], rax
    mov rax, 0
    mov [rbp-32], rax
    mov rax, [rbp-8]
    mov [rbp-40], rax
.L149:
    mov rax, [rbp-40]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setg al
    movzx rax, al
    test rax, rax
    jz .L151
    mov rax, 48
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    cqo
    idiv rbx
    mov rax, rdx
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
    cqo
    idiv rbx
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
.L150:
    jmp .L149
.L151:
    mov rax, [rbp-32]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    mov [rbp-48], rax
.L152:
    mov rax, [rbp-48]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setge al
    movzx rax, al
    test rax, rax
    jz .L154
    mov rax, 1
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    pop rdi
    pop rsi
    call std_util__emit_stderr
.L153:
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
    jmp .L152
.L154:
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    jz .L155
    mov rax, 1
    push rax
    lea rax, [rel _str42]
    push rax
    pop rdi
    pop rsi
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
    jmp .L156
.L155:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_util__emit_u64
.L156:
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
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
    jz .L157
    mov rax, 1
    push rax
    lea rax, [rel _str42]
    push rax
    pop rdi
    pop rsi
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
    jmp .L158
.L157:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_util__emit_u64_stderr
.L158:
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_util__emit_nl:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rax, 1
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-8], rax
    mov rax, [rbp-8]
    mov [rbp-16], rax
    mov rax, 10
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
    mov rax, [rbp-8]
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
std_vec__Vec_constructor:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 8
    mov [rbp-24], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-32], rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    pop rbx
    mov [rax], rbx
    mov rax, 0
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    add rax, 16
    pop rbx
    mov [rax], rbx
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_hashmap__HashMap_hash:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, 0
    mov [rbp-24], rax
    mov rax, [rbp-8]
    mov [rbp-32], rax
    mov rax, 0
    mov [rbp-40], rax
.L159:
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-16]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L161
    mov rax, [rbp-24]
    push rax
    mov rax, [rbp-32]
    push rax
    mov rax, [rbp-40]
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
    mov rax, 31
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
.L160:
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
    jmp .L159
.L161:
    mov rax, [rbp-24]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
_22_vec_struct_stress__check_s24:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, 24
    push rax
    mov rax, 24
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L162
    mov rax, 10
    mov rsp, rbp
    pop rbp
    ret
.L162:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_SS24
    push rax
    mov rax, 4
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L164
    mov rax, 11
    mov rsp, rbp
    pop rbp
    ret
.L164:
    mov rax, [rbp-8]
    push rax
    pop rax
    mov rax, [rax]
    mov [rbp-16], rax
    mov rax, [rbp-16]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, 100
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L166
    mov rax, 12
    mov rsp, rbp
    pop rbp
    ret
.L166:
    mov rax, [rbp-16]
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, 101
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L168
    mov rax, 13
    mov rsp, rbp
    pop rbp
    ret
.L168:
    mov rax, [rbp-16]
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, 102
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L170
    mov rax, 14
    mov rsp, rbp
    pop rbp
    ret
.L170:
    mov rax, 2
    push rax
    mov rax, 24
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov [rbp-24], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, 900
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L172
    mov rax, 15
    mov rsp, rbp
    pop rbp
    ret
.L172:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, 901
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L174
    mov rax, 16
    mov rsp, rbp
    pop rbp
    ret
.L174:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, 902
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L176
    mov rax, 17
    mov rsp, rbp
    pop rbp
    ret
.L176:
    mov rax, 3
    push rax
    mov rax, 24
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov [rbp-32], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, 400
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L178
    mov rax, 18
    mov rsp, rbp
    pop rbp
    ret
.L178:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, 401
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L180
    mov rax, 19
    mov rsp, rbp
    pop rbp
    ret
.L180:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, 402
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L182
    mov rax, 20
    mov rsp, rbp
    pop rbp
    ret
.L182:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
_22_vec_struct_stress__check_s40:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, 40
    push rax
    mov rax, 40
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L184
    mov rax, 30
    mov rsp, rbp
    pop rbp
    ret
.L184:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_SS40
    push rax
    mov rax, 3
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L186
    mov rax, 31
    mov rsp, rbp
    pop rbp
    ret
.L186:
    mov rax, [rbp-8]
    push rax
    pop rax
    mov rax, [rax]
    mov [rbp-16], rax
    mov rax, 2
    push rax
    mov rax, 40
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov [rbp-24], rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, 2020
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L188
    mov rax, 32
    mov rsp, rbp
    pop rbp
    ret
.L188:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 8
    mov rbx, rax
    pop rax
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, 2021
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L190
    mov rax, 33
    mov rsp, rbp
    pop rbp
    ret
.L190:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 16
    mov rbx, rax
    pop rax
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, 2022
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L192
    mov rax, 34
    mov rsp, rbp
    pop rbp
    ret
.L192:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 24
    mov rbx, rax
    pop rax
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, 2023
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L194
    mov rax, 35
    mov rsp, rbp
    pop rbp
    ret
.L194:
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-24]
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, 32
    mov rbx, rax
    pop rax
    add rax, rbx
    mov rax, [rax]
    push rax
    mov rax, 2024
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L196
    mov rax, 36
    mov rsp, rbp
    pop rbp
    ret
.L196:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
main:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov rdi, 24
    call std_mem__malloc
    mov r12, rax
    mov rdi, r12
    xor esi, esi
    mov rdx, 24
    call std_mem__memset
    mov rax, 1
    push rax
    push r12
    pop rdi
    pop rsi
    call std_vec__Vec_constructor
    mov rax, r12
    mov [rbp-8], rax
    mov rax, 0
    mov [rbp-16], rax
.L198:
    mov rax, [rbp-16]
    push rax
    mov rax, 5
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L200
    mov rax, 100
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 100
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-40]
    pop rbx
    mov [rax], rbx
    mov rax, 101
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 100
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-32]
    pop rbx
    mov [rax], rbx
    mov rax, 102
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, 100
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-24]
    pop rbx
    mov [rax], rbx
    lea rax, [rbp-40]
    mov rbx, rax
    lea r8, [rbp-64]
    mov rcx, [rbx]
    mov [r8], rcx
    mov rcx, [rbx+8]
    mov [r8+8], rcx
    mov rcx, [rbx+16]
    mov [r8+16], rcx
    lea rax, [rbp-64]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_push__G__T_SS24
.L199:
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-16]
    pop rbx
    mov [rax], rbx
    jmp .L198
.L200:
    mov rax, [rbp-8]
    push rax
    pop rdi
    call std_vec__Vec_len__G__T_SS24
    push rax
    mov rax, 5
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L201
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.L201:
    mov rax, 900
    push rax
    lea rax, [rbp-88]
    pop rbx
    mov [rax], rbx
    mov rax, 901
    push rax
    lea rax, [rbp-80]
    pop rbx
    mov [rax], rbx
    mov rax, 902
    push rax
    lea rax, [rbp-72]
    pop rbx
    mov [rax], rbx
    lea rax, [rbp-88]
    mov rbx, rax
    lea r8, [rbp-112]
    mov rcx, [rbx]
    mov [r8], rcx
    mov rcx, [rbx+8]
    mov [r8+8], rcx
    mov rcx, [rbx+16]
    mov [r8+16], rcx
    lea rax, [rbp-112]
    push rax
    mov rax, 2
    push rax
    mov rax, [rbp-8]
    push rax
    pop rdi
    pop rsi
    pop rdx
    call std_vec__Vec_set__G__T_SS24
    mov rax, [rbp-8]
    push rax
    lea rdi, [rbp-136]
    pop rsi
    call std_vec__Vec_pop__G__T_SS24
    mov rax, [rbp-8]
    push rax
    pop rdi
    call _22_vec_struct_stress__check_s24
    mov [rbp-144], rax
    mov rax, [rbp-144]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L203
    mov rax, [rbp-144]
    mov rsp, rbp
    pop rbp
    ret
.L203:
    mov rdi, 24
    call std_mem__malloc
    mov r12, rax
    mov rdi, r12
    xor esi, esi
    mov rdx, 24
    call std_mem__memset
    mov rax, 2
    push rax
    push r12
    pop rdi
    pop rsi
    call std_vec__Vec_constructor
    mov rax, r12
    mov [rbp-152], rax
    mov rax, 0
    mov [rbp-160], rax
.L205:
    mov rax, [rbp-160]
    push rax
    mov rax, 3
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L207
    mov rax, 2000
    push rax
    mov rax, [rbp-160]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-200]
    pop rbx
    mov [rax], rbx
    mov rax, 2001
    push rax
    mov rax, [rbp-160]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-192]
    pop rbx
    mov [rax], rbx
    mov rax, 2002
    push rax
    mov rax, [rbp-160]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-184]
    pop rbx
    mov [rax], rbx
    mov rax, 2003
    push rax
    mov rax, [rbp-160]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-176]
    pop rbx
    mov [rax], rbx
    mov rax, 2004
    push rax
    mov rax, [rbp-160]
    push rax
    mov rax, 10
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-168]
    pop rbx
    mov [rax], rbx
    lea rax, [rbp-200]
    mov rbx, rax
    lea r8, [rbp-240]
    mov rcx, [rbx]
    mov [r8], rcx
    mov rcx, [rbx+8]
    mov [r8+8], rcx
    mov rcx, [rbx+16]
    mov [r8+16], rcx
    mov rcx, [rbx+24]
    mov [r8+24], rcx
    mov rcx, [rbx+32]
    mov [r8+32], rcx
    lea rax, [rbp-240]
    push rax
    mov rax, [rbp-152]
    push rax
    pop rdi
    pop rsi
    call std_vec__Vec_push__G__T_SS40
.L206:
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
    jmp .L205
.L207:
    mov rax, [rbp-152]
    push rax
    pop rdi
    call _22_vec_struct_stress__check_s40
    mov [rbp-248], rax
    mov rax, [rbp-248]
    push rax
    mov rax, 0
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setne al
    movzx rax, al
    test rax, rax
    jz .L208
    mov rax, [rbp-248]
    mov rsp, rbp
    pop rbp
    ret
.L208:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
StackFrame_constructor:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
Vec_constructor__G__T_t:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
HashMap_constructor__G__T_t_T_t:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
HashEntry_constructor__G__T_t:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
HashMap_constructor:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
HashEntry_constructor:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
Vec_constructor__G__T_SS24:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
Vec_constructor__G__T_SS40:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
S24_constructor:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
S40_constructor:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_vec__Vec_len__G__T_SS24:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rax
    add rax, 8
    mov rax, [rax]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_vec__Vec_len__G__T_SS40:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, [rbp-8]
    push rax
    pop rax
    add rax, 8
    mov rax, [rax]
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_vec__Vec_push__G__T_SS24:
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
    mov rax, [rbp-8]
    push rax
    pop rax
    add rax, 8
    mov rax, [rax]
    mov [rbp-40], rax
    mov rax, [rbp-8]
    push rax
    pop rax
    add rax, 16
    mov rax, [rax]
    mov [rbp-48], rax
    mov rax, 24
    mov [rbp-56], rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-48]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setge al
    movzx rax, al
    test rax, rax
    jz .L210
    mov rax, [rbp-48]
    push rax
    mov rax, 2
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov [rbp-64], rax
    mov rax, [rbp-64]
    push rax
    mov rax, 4
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L212
    mov rax, 4
    push rax
    lea rax, [rbp-64]
    pop rbx
    mov [rax], rbx
.L212:
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-56]
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-72], rax
    mov rax, [rbp-8]
    push rax
    pop rax
    mov rax, [rax]
    mov [rbp-80], rax
    mov rax, 0
    mov [rbp-88], rax
.L214:
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-40]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L216
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-56]
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-96], rax
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-56]
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-104], rax
    mov rax, [rbp-96]
    mov [rbp-112], rax
    mov rax, [rbp-104]
    mov [rbp-120], rax
    mov rax, 0
    mov [rbp-128], rax
.L217:
    mov rax, [rbp-128]
    push rax
    mov rax, [rbp-56]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L219
    mov rax, [rbp-112]
    push rax
    mov rax, [rbp-128]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-120]
    push rax
    mov rax, [rbp-128]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L218:
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
    jmp .L217
.L219:
.L215:
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
    jmp .L214
.L216:
    mov rax, [rbp-72]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-64]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    add rax, 16
    pop rbx
    mov [rax], rbx
.L210:
    mov rax, [rbp-8]
    push rax
    pop rax
    mov rax, [rax]
    mov [rbp-136], rax
    mov rax, [rbp-136]
    push rax
    mov rax, [rbp-40]
    push rax
    mov rax, [rbp-56]
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-144], rax
    lea rax, [rbp-32]
    mov [rbp-152], rax
    mov rax, [rbp-144]
    mov [rbp-160], rax
    mov rax, [rbp-152]
    mov [rbp-168], rax
    mov rax, 0
    mov [rbp-176], rax
.L220:
    mov rax, [rbp-176]
    push rax
    mov rax, [rbp-56]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L222
    mov rax, [rbp-168]
    push rax
    mov rax, [rbp-176]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-160]
    push rax
    mov rax, [rbp-176]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L221:
    mov rax, [rbp-176]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-176]
    pop rbx
    mov [rax], rbx
    jmp .L220
.L222:
    mov rax, [rbp-40]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_vec__Vec_set__G__T_SS24:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov [rbp-16], rsi
    mov rax, rdx
    lea rbx, [rbp-40]
    mov rcx, [rax]
    mov [rbx], rcx
    mov rcx, [rax+8]
    mov [rbx+8], rcx
    mov rcx, [rax+16]
    mov [rbx+16], rcx
    mov rax, [rbp-8]
    push rax
    pop rax
    mov rax, [rax]
    mov [rbp-48], rax
    mov rax, 24
    mov [rbp-56], rax
    mov rax, [rbp-48]
    push rax
    mov rax, [rbp-16]
    push rax
    mov rax, [rbp-56]
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-64], rax
    lea rax, [rbp-40]
    mov [rbp-72], rax
    mov rax, [rbp-64]
    mov [rbp-80], rax
    mov rax, [rbp-72]
    mov [rbp-88], rax
    mov rax, 0
    mov [rbp-96], rax
.L223:
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-56]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L225
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-96]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-96]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L224:
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
    jmp .L223
.L225:
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret
std_vec__Vec_pop__G__T_SS24:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rsi
    mov rax, [rbp-8]
    push rax
    pop rax
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
    jz .L226
    push rdi
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
.L226:
    mov rax, [rbp-8]
    push rax
    pop rax
    mov rax, [rax]
    mov [rbp-24], rax
    mov rax, 24
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
    mov [rbp-64], rax
    lea rax, [rbp-56]
    mov [rbp-72], rax
    mov rax, [rbp-64]
    mov [rbp-80], rax
    mov rax, [rbp-72]
    mov [rbp-88], rax
    mov rax, 0
    mov [rbp-96], rax
.L228:
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-32]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L230
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
    pop rbx
    mov [rax], bl
.L229:
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
    jmp .L228
.L230:
    mov rax, [rbp-16]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    sub rax, rbx
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    add rax, 8
    pop rbx
    mov [rax], rbx
    push rdi
    lea rax, [rbp-56]
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
std_vec__Vec_push__G__T_SS40:
    push rbp
    mov rbp, rsp
    sub rsp, 2048
    mov [rbp-8], rdi
    mov rax, rsi
    lea rbx, [rbp-48]
    mov rcx, [rax]
    mov [rbx], rcx
    mov rcx, [rax+8]
    mov [rbx+8], rcx
    mov rcx, [rax+16]
    mov [rbx+16], rcx
    mov rcx, [rax+24]
    mov [rbx+24], rcx
    mov rcx, [rax+32]
    mov [rbx+32], rcx
    mov rax, [rbp-8]
    push rax
    pop rax
    add rax, 8
    mov rax, [rax]
    mov [rbp-56], rax
    mov rax, [rbp-8]
    push rax
    pop rax
    add rax, 16
    mov rax, [rax]
    mov [rbp-64], rax
    mov rax, 40
    mov [rbp-72], rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-64]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setge al
    movzx rax, al
    test rax, rax
    jz .L231
    mov rax, [rbp-64]
    push rax
    mov rax, 2
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov [rbp-80], rax
    mov rax, [rbp-80]
    push rax
    mov rax, 4
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L233
    mov rax, 4
    push rax
    lea rax, [rbp-80]
    pop rbx
    mov [rax], rbx
.L233:
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-72]
    mov rbx, rax
    pop rax
    imul rax, rbx
    push rax
    pop rdi
    call std_io__heap_alloc
    mov [rbp-88], rax
    mov rax, [rbp-8]
    push rax
    pop rax
    mov rax, [rax]
    mov [rbp-96], rax
    mov rax, 0
    mov [rbp-104], rax
.L235:
    mov rax, [rbp-104]
    push rax
    mov rax, [rbp-56]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L237
    mov rax, [rbp-96]
    push rax
    mov rax, [rbp-104]
    push rax
    mov rax, [rbp-72]
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-112], rax
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-104]
    push rax
    mov rax, [rbp-72]
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-120], rax
    mov rax, [rbp-112]
    mov [rbp-128], rax
    mov rax, [rbp-120]
    mov [rbp-136], rax
    mov rax, 0
    mov [rbp-144], rax
.L238:
    mov rax, [rbp-144]
    push rax
    mov rax, [rbp-72]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L240
    mov rax, [rbp-128]
    push rax
    mov rax, [rbp-144]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-136]
    push rax
    mov rax, [rbp-144]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L239:
    mov rax, [rbp-144]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-144]
    pop rbx
    mov [rax], rbx
    jmp .L238
.L240:
.L236:
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
    jmp .L235
.L237:
    mov rax, [rbp-88]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    pop rbx
    mov [rax], rbx
    mov rax, [rbp-80]
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    add rax, 16
    pop rbx
    mov [rax], rbx
.L231:
    mov rax, [rbp-8]
    push rax
    pop rax
    mov rax, [rax]
    mov [rbp-152], rax
    mov rax, [rbp-152]
    push rax
    mov rax, [rbp-56]
    push rax
    mov rax, [rbp-72]
    mov rbx, rax
    pop rax
    imul rax, rbx
    mov rbx, rax
    pop rax
    add rax, rbx
    mov [rbp-160], rax
    lea rax, [rbp-48]
    mov [rbp-168], rax
    mov rax, [rbp-160]
    mov [rbp-176], rax
    mov rax, [rbp-168]
    mov [rbp-184], rax
    mov rax, 0
    mov [rbp-192], rax
.L241:
    mov rax, [rbp-192]
    push rax
    mov rax, [rbp-72]
    mov rbx, rax
    pop rax
    cmp rax, rbx
    setl al
    movzx rax, al
    test rax, rax
    jz .L243
    mov rax, [rbp-184]
    push rax
    mov rax, [rbp-192]
    pop rbx
    add rax, rbx
    movzx rax, byte [rax]
    push rax
    mov rax, [rbp-176]
    push rax
    mov rax, [rbp-192]
    pop rbx
    add rax, rbx
    pop rbx
    mov [rax], bl
.L242:
    mov rax, [rbp-192]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    lea rax, [rbp-192]
    pop rbx
    mov [rax], rbx
    jmp .L241
.L243:
    mov rax, [rbp-56]
    push rax
    mov rax, 1
    mov rbx, rax
    pop rax
    add rax, rbx
    push rax
    mov rax, [rbp-8]
    push rax
    pop rax
    add rax, 8
    pop rbx
    mov [rax], rbx
    mov rax, 0
    mov rsp, rbp
    pop rbp
    ret
   xor eax, eax
    mov rsp, rbp
    pop rbp
   ret

section .data
_str25: db 10,0
_str33: db 48,0
_str42: db 45,0
_str107: db 32,32,40,110,111,32,115,116,97,99,107,32,116,114,97,99,101,32,97,118,97,105,108,97,98,108,101,41,0
_str110: db 32,32,40,115,116,97,99,107,32,116,114,97,99,101,32,105,115,32,101,109,112,116,121,41,0
_str111: db 83,116,97,99,107,32,116,114,97,99,101,32,40,109,111,115,116,32,114,101,99,101,110,116,32,99,97,108,108,32,102,105,114,115,116,41,58,0
_str115: db 32,32,97,116,32,0
_str116: db 32,40,0
_str117: db 58,0
_str118: db 41,0
_str121: db 91,69,82,82,79,82,93,32,0
_str124: db 80,97,114,115,105,110,103,32,99,111,110,116,101,120,116,58,0
_str125: db 32,32,45,62,32,73,110,32,102,117,110,99,116,105,111,110,58,32,0
_str126: db 32,40,108,105,110,101,32,0
_str127: db 67,111,109,112,105,108,101,114,32,105,110,116,101,114,110,97,108,32,116,114,97,99,101,58,0
_str130: db 69,114,114,111,114,32,100,101,116,97,105,108,115,58,0
_str138: db 91,87,65,82,78,93,32,0

section .bss
_gvar_std_os__g_syscall_arg0: resb 8
_gvar_std_os__g_syscall_arg1: resb 8
_gvar_std_os__g_syscall_arg2: resb 8
_gvar_std_os__g_syscall_arg3: resb 8
_gvar_std_os__g_syscall_ret: resb 8
_gvar_std_io__heap_inited: resb 8
_gvar_std_io__heap_brk: resb 8
_gvar_std_io__g_out_fd: resb 8
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
