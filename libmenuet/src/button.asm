; void DefineButton(
;    uint16_t x_start,
;    uint16_t y_start,
;    uint16_t x_size,
;    uint16_t y_size,
;    uint32_t id,
;    uint32_t color,
;    char *label
; );
global _DefineButton
_DefineButton:
    push ebp
    mov ebp, esp
    pushad

    mov eax, 8 ; syscall 8
    movzx ebx, word [ebp + 8]  ; x_start
    shl ebx, 16
    mov bx, word [ebp + 16]    ; x_size
    movzx ecx, word [ebp + 12] ; y_start
    shl ecx, 16
    mov cx, word [ebp + 20]    ; y_size
    mov edx, dword [ebp + 24]  ; id
    mov esi, dword [ebp + 28]  ; color
    mov edi, dword [ebp + 32]  ; label
    int 0x40

    popad
    leave
    ret

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
