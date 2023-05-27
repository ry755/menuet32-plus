    bits 32

    %include "crt0.asm"

    %include "application.asm"
    %include "button.asm"
    %include "event.asm"
    %include "window.asm"

return: dd 0x00000000
