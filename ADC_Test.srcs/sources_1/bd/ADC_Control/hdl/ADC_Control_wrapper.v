//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
//Date        : Mon Nov 12 17:20:36 2018
//Host        : DESKTOP-S0CCCTL running 64-bit major release  (build 9200)
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
        .clk_100m(clk_100m),
        .clk_50m(clk_50m),
        .cpu_resetn(cpu_resetn),
        .dcm_locked(dcm_locked),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd));
endmodule
