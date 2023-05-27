#include "libmenuet.h"

#include <stdint.h>

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
                if (button == 1)
                    EndApplication();
            }
        }
    }
}

void RedrawWindow() {
    BeginRedraw();
    DrawWindow(64, 64, 128, 128, 0xFFFFFF, "C TEST", NULL);
    DisplayText(32, 32, 0x10000000, "hi");
    EndRedraw();
}
