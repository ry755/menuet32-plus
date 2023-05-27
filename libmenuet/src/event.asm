; uint32_t WaitForEvent();
global _WaitForEvent
_WaitForEvent:
    push ebp
    mov ebp, esp
    pushad

    mov eax, 10 ; syscall 10
    int 0x40
    mov dword [return], eax

    popad
    leave
    mov eax, dword [return]
    ret

; uint32_t CheckForEvent();
global _CheckForEvent
_CheckForEvent:
    push ebp
    mov ebp, esp
    pushad

    mov eax, 11 ; syscall 11
    int 0x40
    mov dword [return], eax

    popad
    leave
    mov eax, dword [return]
    ret
