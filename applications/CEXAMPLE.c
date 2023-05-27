#include "libmenuet.h"
#include <stdint.h>

bool button_clicked = false;

void RedrawWindow();

void main() {
    RedrawWindow();

    while (true) {
        uint32_t event = WaitForEvent();
        switch (event) {
            case 1: {
                // redraw event
                RedrawWindow();
                break;
            }

            case 3: {
                // button event
                uint32_t button = GetButtonID() >> 8;
                switch (button) {
                    case 1: {
                        // button 1 is the window's close button
                        EndApplication();
                        break;
                    }

                    case 2: {
                        // button 2 is our "click me!" button
                        button_clicked = true;
                        RedrawWindow();
                        break;
                    }
                }
            }
        }
    }
}

void RedrawWindow() {
    BeginRedraw();
    DrawWindow(64, 64, 128, 128, 0xFFFFFF, "C TEST", NULL);
    DisplayText(16, 38, 0x00000000, "Hello world!");
    DefineButton(16, 64, 64, 16, 2, 0x10000000, "click me!");
    if (button_clicked)
        DisplayText(16, 96, 0x00000000, "Button clicked!");
    EndRedraw();
}
