#ifndef LIBMENUET_H
#define LIBMENUET_H

// See SYSFUNCS.TXT for details on the specifics of each syscall.

#include <stdint.h>

#ifndef NULL
#define NULL ((void*) 0x0)
#endif

#ifndef bool
typedef int bool;
#endif

#ifndef true
#define true 0x1
#endif

#ifndef false
#define false 0x0
#endif

typedef struct {
    uint32_t direction;
    uint32_t block;
    uint32_t size;
    char *buffer;
    char *temp;
    char path[256];
} file_block_t;

// application
void EndApplication();

// button
void DefineButton(uint16_t x_start, uint16_t y_start, uint16_t x_size, uint16_t y_size, uint32_t id, uint32_t color, char *label);
uint32_t GetButtonID();

// event
uint32_t WaitForEvent();
uint32_t CheckForEvent();

// file
uint32_t FileSystem(file_block_t *file_block);

// window
void DrawWindow(uint16_t x_start, uint16_t y_start, uint16_t x_size, uint16_t y_size, uint32_t color, char *label, char *menu_struct);
void PutPixel(uint32_t x, uint32_t y, uint32_t color);
void PutText(uint16_t x, uint16_t y, uint32_t color, char *text);
void PutImage(uint16_t x_start, uint16_t y_start, uint16_t x_size, uint16_t y_size, char *image);
void BeginRedraw();
void EndRedraw();

#endif
