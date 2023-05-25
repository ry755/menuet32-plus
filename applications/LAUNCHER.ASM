;
;   LAUNCHER.ASM
;
;   Compile with FASM for Menuet
;
;   Mike Hibbett   Added reading the settings from a text file
;

use32

    org    0x0

    db     'MENUET01'              ; 8 byte id
    dd     0x01                    ; header version
    dd     START                   ; start of code
    dd     I_END                   ; size of image
    dd     0x100000                ; memory for app
    dd     0x7fff0                 ; esp
    dd     0x0 , 0x0               ; I_Param , I_Icon


START:

    call    make_table          ; Create the pretty icon

    call    draw_window

    ; For some reason, draw_window needs to be called first
    ; Maybe it adds a delay

    call    readBootFile        ; Load the startup data file

    call    draw_window

    mov     ecx,16
  newdelay2:
    ; Delay for 30ms
    mov     eax,5
    mov     ebx,3
    int     0x40
    call    update_candy
    loop    newdelay2

still:
    mov     eax,11                  ; wait here for event
    int     0x40

    cmp     eax,1                   ; redraw request ?
    je      red
    cmp     eax,2                   ; key in buffer ?
    je      key
    cmp     eax,3                   ; button in buffer ?
    je      button

    call    launch_applications

    jmp     still

red:                                ; redraw
    call    draw_window
    jmp     still

key:                                ; key
    mov     eax,2                   ; just read it and ignore
    int     0x40
    jmp     still

button:
    mov     eax,17                  ; get id
    int     0x40

    cmp     ah,1                    ; button id=1 ?
    jne     noclose

    mov     eax,-1                  ; close this program
    int     0x40

noclose:
    jmp     still


;***************************************************************************
;   Function
;      readBootFile
;
;   Description
;
;***************************************************************************
readBootFile:
    mov   eax,6    ; Read file from ramdisk
    mov   ebx,bootFilename
    mov   ecx,0
    mov   edx,0xffffffff
    mov   esi,I_END + 4096      ; The first 4096 are reserved for the file list
    int   0x40

    cmp   eax,0xffffffff
    jnz   filefound
    ret

filefound:
    add     eax, I_END + 4096
    mov     [fileEnd], eax          ; Store the end pos of file in memory

    ; OK, lets parse the text file.
    ; I assume that lines are terminated by CR or LF or CR/LF or LF/CR ..
    ; .. Just to be safe :o)
    ; Lines beginning with # are comments and are skipped
    ; Lines with only white space are skipped
    ; Line format is APPNAME PARAMETER DELAY
    ; APPNAME,PARAMETER and DELAY contain no whitespace
    ; APPNAME has no path or extension
    ; APPNAME,PARAMETER are no longer than 16 characters long
    ; DELAY is postive interger number and is the delay in ms
    ; Fields are seperated by 1 or more whitespace characters
    ; End the file with an empty line
    ; Whitespace is space or tab
    ; Garbage in, garbage out.

    mov     esi, I_END +4096        ; esi is source file data
    mov     edi, file_list          ; edi is place to write

    xor     eax, eax
    mov     [files], eax            ; We have 0 boot options at start

findline:
    call    findParam               ; point to next parameter, skip comments
    cmp     esi, [fileEnd]
    jae      fileLoaded              ; Have we reached the end of the file?
    push    edi
    call    storeParam              ; copy string to file_list
    pop     edi
    add     edi, 16
    call    skipWhite               ; past any whitespace
    push    edi
    call    storeParam              ; copy string to file_list
    pop     edi
    add     edi, 64
    call    skipWhite               ; past any whitespace
    call    storeDecimal            ; get decimal string to binary, store

    mov     eax, [files]
    inc     eax
    mov     [files], eax

    cmp     esi, [fileEnd]
    jae      fileLoaded              ; Have we reached the end of the file?


    cmp     eax, 50                 ; We can only have 50 maximum
    je      fileLoaded
    jmp     findline                ; Get more

fileLoaded:
    mov     eax, [files]
    cmp     eax, 0
    jne     rbExit

    ; Restore the default boot load size
    mov     eax, 3
    mov     [files], eax
rbExit:

    ret



;***************************************************************************
;   Function
;       findParam
;
;   Description
;       skips comments and blank lines until the next parameter if found
;       source is in esi; dont touch edi
;
;***************************************************************************
findParam:
    ; Exit if at end of file
    cmp     esi, [fileEnd]
    jb     fp001
    ret                             ; Abort

fp001:
    mov     al, [esi]               ; get file character

    ; is it a comment line?
    cmp     al, '#'
    jne     fp002

    call    nextLine                ; Move to next line
    jmp     findParam

fp002:
    call    skipWhite               ; Move past any spaces

    cmp     esi, [fileEnd]          ; Have we reached the end of the file?
    jae     findParam               ; If yes, jump back to start to force exit

    ; Was it an empty line?
    mov     al, [esi]
    cmp     al, 0x0a
    je      fp003
    cmp     al, 0x0d
    je      fp003
    ret                             ; We have the parameter!

fp003:
    ; It was an empty line; Read past the end of line marker
    ; and return to findParam for next line
    inc     esi
    mov     al, [esi]
    cmp     al, 0x0a
    je      fp004
    cmp     al, 0x0d
    je      fp004
    jmp     findParam

fp004:
    inc     esi
    jmp     findParam



;***************************************************************************
;   Function
;       nextLine
;
;   Description
;       skips to the beginning of the next line
;
;***************************************************************************
nextLine:
    ; Exit if at end of file
    cmp     esi, [fileEnd]
    jb     nl001
    ret                             ; Abort

nl001:
    mov     al, [esi]
    cmp     al, 0x0a
    je      nl002           ; We have reached the end
    cmp     al, 0x0d
    je      nl002
    inc     esi
    jmp     nextLine

nl002:                      ; Now skip the CR/LF bits
    inc     esi
    mov     al, [esi]
    cmp     al, 0x0a
    je      nl003
    cmp     al, 0x0d
    je      nl003
    ret                     ; Now at start of new line

nl003:
    inc     esi
    ret                     ; Now at start of new line




;***************************************************************************
;   Function
;       skipWhite
;
;   Description
;       skips any tabs or spaces
;
;***************************************************************************
skipWhite:
    ; Exit if at end of file
    cmp     esi, [fileEnd]
    jb     sw001
    ret                             ; Abort

sw001:
    mov     al, [esi]
    cmp     al, ' '
    je      sw002                   ; skip space char
    cmp     al, 0x09
    je      sw002                   ; skip tab char
    ret

sw002:
    inc     esi
    jmp     skipWhite




;***************************************************************************
;   Function
;       storeParam
;
;   Description
;       copies the string to the file table
;
;***************************************************************************
storeParam:
    ; Clear any previous string in the array
    push    edi
    mov     al, ' '
    mov     ecx, 64                 ; Yes, this is safe on the first parameter
    cld
    rep     stosb
    pop     edi

sp000:
    ; Exit if at end of file
    cmp     esi, [fileEnd]
    jb     sp001
    ret                             ; Abort

sp001:
;    cld
;    movsb
    mov     al, [esi]
    mov     [edi], al
    inc     esi
    inc     edi

    mov     al, [esi]
    cmp     al, ' '
    je      spExit
    cmp     al, 0x09
    je      spExit
    cmp     al, 0x0a
    je      spExit
    cmp     al, 0x0d
    je      spExit

    jmp     sp000

spError:
    mov     [fileEnd], esi          ; Abort rest of file

spExit:
    ret


;***************************************************************************
;   Function
;       storeDecimal
;
;   Description
;       The number that follows in the file is converted to binary and
;       stored. No Range checking is done; Number terminated by whitespace
;       or end of line
;
;***************************************************************************
storeDecimal:
    xor     ebx, ebx

sd000:
    ; Exit if at end of file
    cmp     esi, [fileEnd]
    jb     sd001
    ret                             ; Abort

sd001:
    movzx   eax, byte [esi]
    cmp     al, ' '
    je      sdExit
    cmp     al, 0x09
    je      sdExit
    cmp     al, 0x0a
    je      sdExit
    cmp     al, 0x0d
    je      sdExit

    ; multiply number by ten , then add al - '0' to it
    shl     ebx, 1
    mov     ecx, ebx
    shl     ebx, 2
    add     ebx, ecx
    add     ebx, eax
    sub     ebx, '0'
    mov     [edi], ebx
    inc     esi
    jmp     sd000

sdExit:
    ; Did we get a number? If not, default it to 2000
    cmp     ebx, 0
    jne     sdExit1
    mov     ebx, 2000
    mov     [edi], ebx

sdExit1:
    add     edi, 4
    call    nextLine
    ret



launch_applications:

    pusha

    ; Launch application ( old function, undocumented )

    mov  eax,19
    mov  ebx,[applications]
    mov  ecx,ebx    ; Application name
    add  ecx,16     ; Point to the boot option
    int  0x40

    push ecx

    ; Get the third application option

    mov     eax,[ecx+64]
    mov     cl, 30
    div     cl
    xor     ecx, ecx
    mov     cl, al

  newdelay:

    mov  eax,5
    mov  ebx,3
    int  0x40       ; Wait 30ms
    call update_candy

    loop newdelay   ; wait 30ms * the value defined in 3rd param ( div by 2 )

    pop  ecx

    dec  [files]
    jne  more
    mov  eax,-1
    int  0x40
  more:

    add  [applications],64+16+4

    popa

    ret


update_candy:

    pusha

    sub  [cstate],2
    and  [cstate],63

    mov  ecx,[cstate]
    imul ecx,3
    mov  ebx,0x80000+32*3
    add  ebx,ecx
    mov  ecx,(241-40)*65536+1
    mov  edx,(15+5)*65536+75
    mov  edi,4
  newddd:
    mov  esi,12
  newdd:
    mov  eax,7
    int  0x40
    add  ebx,512*3
    add  edx,1
    dec  esi
    jnz  newdd

    popa

    ret



make_table:

    pusha

    mov  edi,0x80000
    mov  eax,0xffffff

    mov  ecx,11+2
  newgg:
    push ecx
    mov  ecx,512
   newg:
    mov  [edi],eax
    add  edi,3
    loop newg
    sub  eax,0x040404
    pop  ecx
    loop newgg

    mov  edi,0x80000+64*3
    mov  eax,0x6688bb

    mov  ecx,10+2
  newgg2:
    push ecx
    mov  ecx,32
  newg2:

    push eax

    mov  [edi],ax
    mov  [edi+64*3],ax
    mov  [edi+128*3],ax
    mov  [edi+192*3],ax
    mov  [edi+256*3],ax
    mov  [edi+256*3+64*3],ax
    mov  [edi+256*3+128*3],ax
    mov  [edi+256*3+192*3],ax

    shr  eax , 16

    mov  [edi+2],al
    mov  [edi+64*3+2],al
    mov  [edi+128*3+2],al
    mov  [edi+192*3+2],al
    mov  [edi+256*3+2],al
    mov  [edi+256*3+64*3+2],al
    mov  [edi+256*3+128*3+2],al
    mov  [edi+256*3+192*3+2],al

    pop  eax

    add  edi,3
    loop newg2
    sub  eax,0x060606
    pop  ecx
    add  edi,3+224*3+256*3
    loop newgg2

    popa

    ret



;   *********************************************
;   *******  WINDOW DEFINITIONS AND DRAW ********
;   *********************************************


draw_window:


    mov  eax,12                    ; function 12:tell os about windowdraw
    mov  ebx,1                     ; 1, start of draw
    int  0x40

    mov  eax,14
    int  0x40

    mov  ecx,150
    shl  ecx,16

    shr  eax,17
    sub  eax,(280-40)/2
    shl  eax,16
    mov  ebx,eax
                                   ; DRAW WINDOW
    mov  eax,0                     ; function 0 : define and draw window
    mov  bx,280-40                 ; [x start] *65536 + [x size]
    mov  cx,105-3                  ; [y start] *65536 + [y size]
    mov  edx,0x04ffffff            ; color of work area RRGGBB,8->color gl
    mov  esi,window_label          ; color of grab bar  RRGGBB,8->color gl
    mov  edi,0                     ; color of frames    RRGGBB
    int  0x40

                                   ; APPLICATION // PARAMETER
    mov  eax,4                     ; function 4 : write text to window
    mov  ebx,(80-40/2)*65536+48    ; [x start] *65536 + [y start]
    mov  ecx,0x000000              ; color of text RRGGBB
    mov  edx,text                  ; pointer to text beginning
    mov  esi,textlen-text          ; text length
    int  0x40

    mov  eax,12                    ; function 12:tell os about windowdraw
    mov  ebx,2                     ; 2, end of draw
    int  0x40

    ret




; DATA AREA

; The name of the file we will read the settings from
bootFilename  db 'RDBOOT.DAT',0


applications  dd  file_list

; We may have up to 50 files started
files         dd  3




star        db  '*'

pos         dd   35*65536+45

cstate      dd  0x0

fileEnd     dd  0

window_label:
            db   'LAUNCHER',0

text:
            db   'Setting up desktop..'
textlen:

; This is the list of files started by launcher. There are three default
; ones, run if the datafile RDBOOT.DAT does not exist.
; If it does exist, the data from RDBOOT.DAT will over write these defaults
file_list:
    db   'JPEGVIEW        '
    db   'BOOT                                                            '
    dd   100

    db   'ICONMNGR        '
    db   'BOOT                                                            '
    dd   100

    db   'PANEL           '
    db   'BOOT                                                            '
    dd   100

I_END:
; There is space for an additional 48 applications here.. and then
; .. the data read from the file goes after it
