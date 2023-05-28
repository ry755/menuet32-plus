    bits 32

; __start must be here in order for the linker to not insert a jump before the Menuet header
global __start
__start:
    db 'MENUET01'   ; 8 byte id
    dd 0x01         ; header version
    dd actual_start ; program start
    dd 0x00100000   ; program image size (FIXME: this should be the actual image size)
    dd 0x00100000   ; required amount of memory
    dd 0x0007F000   ; stack
    dd 0x00, 0x00   ; param,icon

extern _main
actual_start:
    call _main
    call _EndApplication
    jmp $
