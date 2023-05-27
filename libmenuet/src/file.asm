; uint32_t FileSystem(
;    file_block_t *file_block
; );
global _FileSystem
_FileSystem:
    push ebp
    mov ebp, esp
    pushad

    mov eax, 58              ; syscall 58
    mov ebx, dword [ebp + 8] ; file_block
    int 0x40
    mov dword [return], eax

    popad
    leave
    mov eax, dword [return]
    ret
