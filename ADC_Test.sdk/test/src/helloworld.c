/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "sleep.h"


int main()
{
	int data;
    init_platform();

    print("Hello World\n\r");

    print("Reading ADC register 0: ");
    Xil_Out32(0x44a00000, 0x03);
    Xil_Out32(0x44a00008, 0x8000);
    Xil_Out32(0x44a00004, 0x01);
    Xil_Out32(0x44a00004, 0x00);

    usleep(100);

    data = Xil_In32(0x44a00010);
    xil_printf("0x%x\n\r", data);

    print("Reading ADC register 1: ");
    Xil_Out32(0x44a00000, 0x03);
    Xil_Out32(0x44a00008, 0x8001);
    Xil_Out32(0x44a00004, 0x01);
    Xil_Out32(0x44a00004, 0x00);

    usleep(100);

    data = Xil_In32(0x44a00010);
    xil_printf("0x%x\n\r", data);


    print("Reading ADC register 2: ");
    Xil_Out32(0x44a00000, 0x03);
    Xil_Out32(0x44a00008, 0x8002);
    Xil_Out32(0x44a00004, 0x01);
    Xil_Out32(0x44a00004, 0x00);

    usleep(100);

    data = Xil_In32(0x44a00010);
    xil_printf("0x%x\n\r", data);

    print("Reading ADC register 0x19: ");
    Xil_Out32(0x44a00000, 0x03);
    Xil_Out32(0x44a00008, 0x8019);
    Xil_Out32(0x44a00004, 0x01);
    Xil_Out32(0x44a00004, 0x00);

    usleep(100);

    data = Xil_In32(0x44a00010);
    xil_printf("0x%x\n\r", data);

    print("Writing ADC register 0x19\r\n");
	Xil_Out32(0x44a00000, 0x03);
	Xil_Out32(0x44a00008, 0x0019);
	Xil_Out32(0x44a0000C, 0xFF);
	Xil_Out32(0x44a00004, 0x03);
	Xil_Out32(0x44a00004, 0x00);

    usleep(100);

    print("Reading ADC register 0x19: ");
    Xil_Out32(0x44a00000, 0x03);
    Xil_Out32(0x44a00008, 0x8019);
    Xil_Out32(0x44a00004, 0x01);
    Xil_Out32(0x44a00004, 0x00);

    usleep(100);

    data = Xil_In32(0x44a00010);
    xil_printf("0x%x\n\r", data);


    cleanup_platform();
    return 0;
}
