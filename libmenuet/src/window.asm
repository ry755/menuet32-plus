; void DrawWindow(
;    uint16_t x_start,
;    uint16_t y_start,
;    uint16_t x_size,
;    uint16_t y_size,
;    uint32_t color,
;    char *label,
;    char *menu_struct
; );
global _DrawWindow
_DrawWindow:
    push ebp
    mov ebp, esp
    pushad

    mov eax, 0                 ; syscall 0
    movzx ebx, word [ebp + 8]  ; x_start
    shl ebx, 16
    mov bx, word [ebp + 16]    ; x_size
    movzx ecx, word [ebp + 12] ; y_start
    shl ecx, 16
    mov cx, word [ebp + 20]    ; y_size
    mov edx, dword [ebp + 24]  ; color
    and edx, 0x00FFFFFF
    or edx, 0x04000000         ; "skinned window with menu"
    mov esi, dword [ebp + 28]  ; label
    mov edi, dword [ebp + 32]  ; menu_struct
    int 0x40

    popad
    leave
    ret

; void PutPixel(
;    uint32_t x,
;    uint32_t y,
;    uint32_t color
; );
global _PutPixel
_PutPixel:
    push ebp
    mov ebp, esp
    pushad

    mov eax, 1                ; syscall 1
    mov ebx, dword [ebp + 8]  ; x
    mov ecx, dword [ebp + 12] ; y
    mov edx, dword [ebp + 16] ; color
    int 0x40

    popad
    leave
    ret

; void PutText(
;    uint16_t x,
;    uint16_t y,
;    uint32_t color,
;    char *text
; );
global _PutText
_PutText:
    push ebp
    mov ebp, esp
    pushad

    mov eax, 4                 ; syscall 4
    movzx ebx, word [ebp + 8]  ; x
    shl ebx, 16
    mov bx, word [ebp + 12]    ; y
    mov ecx, dword [ebp + 16]  ; color
    mov edx, dword [ebp + 20]  ; text
    mov esi, -1                ; null-terminated string
    int 0x40

    popad
    leave
    ret

; void PutImage(
;    uint16_t x_start,
;    uint16_t y_start,
;    uint16_t x_size,
;    uint16_t y_size,
;    char *image,
; );
global _PutImage
_PutImage:
    push ebp
    mov ebp, esp
    pushad

    mov eax, 7                 ; syscall 7
    movzx edx, word [ebp + 8]  ; x_start
    shl edx, 16
    mov dx, word [ebp + 12]    ; y_start
    movzx ecx, word [ebp + 16]  ; x_size
    shl ecx, 16
    mov cx, word [ebp + 20]    ; y_size
    mov ebx, dword [ebp + 24]
    int 0x40

    popad
    leave
    ret

; void BeginRedraw();
global _BeginRedraw
_BeginRedraw:
    push ebp
    mov ebp, esp
    pushad

    mov eax, 12 ; syscall 12
    mov ebx, 1  ; begin redraw
    int 0x40

    popad
    leave
    ret

; void EndRedraw();
global _EndRedraw
_EndRedraw:
    push ebp
    mov ebp, esp
    pushad

    mov eax, 12 ; syscall 12
    mov ebx, 2  ; end redraw
    int 0x40

    popad
    leave
    ret
