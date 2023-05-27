; void EndApplication();
global _EndApplication
_EndApplication:
    push ebp
    mov ebp, esp
    pushad

    mov eax, -1 ; syscall -1
    int 0x40

    popad
    leave
    ret
