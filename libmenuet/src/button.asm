; uint32_t GetButtonID();
global _GetButtonID
_GetButtonID:
    push ebp
    mov ebp, esp
    pushad

    mov eax, 17 ; syscall 17
    int 0x40
    mov dword [return], eax

    popad
    leave
    mov eax, dword [return]
    ret
