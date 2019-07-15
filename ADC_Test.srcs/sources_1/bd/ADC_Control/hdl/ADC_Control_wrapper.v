//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
//Date        : Thu Jul 11 13:15:07 2019
//Host        : DESKTOP-N3U7HNE running 64-bit major release  (build 9200)
//Command     : generate_target ADC_Control_wrapper.bd
//Design      : ADC_Control_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module ADC_Control_wrapper
   (ADC_CSB1,
    ADC_CSB2,
    ADC_SCLK,
    ADC_SDIO,
    O,
    clk_100m,
    clk_50m,
    cpu_resetn,
    dcm_locked,
    usb_uart_rxd,
    usb_uart_txd);
  output [0:0]ADC_CSB1;
  output [0:0]ADC_CSB2;
  output ADC_SCLK;
  inout ADC_SDIO;
  output [31:0]O;
  input clk_100m;
  input clk_50m;
  input cpu_resetn;
  input dcm_locked;
  input usb_uart_rxd;
  output usb_uart_txd;

  wire [0:0]ADC_CSB1;
  wire [0:0]ADC_CSB2;
  wire ADC_SCLK;
  wire ADC_SDIO;
  wire [31:0]O;
  wire clk_100m;
  wire clk_50m;
  wire cpu_resetn;
  wire dcm_locked;
  wire usb_uart_rxd;
  wire usb_uart_txd;

  ADC_Control ADC_Control_i
       (.ADC_CSB1(ADC_CSB1),
        .ADC_CSB2(ADC_CSB2),
        .ADC_SCLK(ADC_SCLK),
        .ADC_SDIO(ADC_SDIO),
        .O(O),
        .clk_100m(clk_100m),
        .clk_50m(clk_50m),
        .cpu_resetn(cpu_resetn),
        .dcm_locked(dcm_locked),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd));
endmodule
