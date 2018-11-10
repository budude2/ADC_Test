//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
//Date        : Wed Oct 31 12:00:58 2018
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
    cpu_resetn,
    d0_a1_n,
    d0_a1_p,
    d0_b1_n,
    d0_b1_p,
    d0_c1_n,
    d0_c1_p,
    d0_d1_n,
    d0_d1_p,
    d1_a1_n,
    d1_a1_p,
    d1_b1_n,
    d1_b1_p,
    d1_c1_n,
    d1_c1_p,
    d1_d1_n,
    d1_d1_p,
    dco1_n,
    dco1_p,
    fco1_n,
    fco1_p,
    sysclk_n,
    sysclk_p,
    usb_uart_rxd,
    usb_uart_txd);
  output [0:0]ADC_CSB1;
  output [0:0]ADC_CSB2;
  output ADC_SCLK;
  inout ADC_SDIO;
  input cpu_resetn;
  input d0_a1_n;
  input d0_a1_p;
  input d0_b1_n;
  input d0_b1_p;
  input d0_c1_n;
  input d0_c1_p;
  input d0_d1_n;
  input d0_d1_p;
  input d1_a1_n;
  input d1_a1_p;
  input d1_b1_n;
  input d1_b1_p;
  input d1_c1_n;
  input d1_c1_p;
  input d1_d1_n;
  input d1_d1_p;
  input dco1_n;
  input dco1_p;
  input fco1_n;
  input fco1_p;
  input sysclk_n;
  input sysclk_p;
  input usb_uart_rxd;
  output usb_uart_txd;

  wire [0:0]ADC_CSB1;
  wire [0:0]ADC_CSB2;
  wire ADC_SCLK;
  wire ADC_SDIO;
  wire cpu_resetn;
  wire d0_a1_n;
  wire d0_a1_p;
  wire d0_b1_n;
  wire d0_b1_p;
  wire d0_c1_n;
  wire d0_c1_p;
  wire d0_d1_n;
  wire d0_d1_p;
  wire d1_a1_n;
  wire d1_a1_p;
  wire d1_b1_n;
  wire d1_b1_p;
  wire d1_c1_n;
  wire d1_c1_p;
  wire d1_d1_n;
  wire d1_d1_p;
  wire dco1_n;
  wire dco1_p;
  wire fco1_n;
  wire fco1_p;
  wire sysclk_n;
  wire sysclk_p;
  wire usb_uart_rxd;
  wire usb_uart_txd;

  ADC_Control ADC_Control_i
       (.ADC_CSB1(ADC_CSB1),
        .ADC_CSB2(ADC_CSB2),
        .ADC_SCLK(ADC_SCLK),
        .ADC_SDIO(ADC_SDIO),
        .cpu_resetn(cpu_resetn),
        .d0_a1_n(d0_a1_n),
        .d0_a1_p(d0_a1_p),
        .d0_b1_n(d0_b1_n),
        .d0_b1_p(d0_b1_p),
        .d0_c1_n(d0_c1_n),
        .d0_c1_p(d0_c1_p),
        .d0_d1_n(d0_d1_n),
        .d0_d1_p(d0_d1_p),
        .d1_a1_n(d1_a1_n),
        .d1_a1_p(d1_a1_p),
        .d1_b1_n(d1_b1_n),
        .d1_b1_p(d1_b1_p),
        .d1_c1_n(d1_c1_n),
        .d1_c1_p(d1_c1_p),
        .d1_d1_n(d1_d1_n),
        .d1_d1_p(d1_d1_p),
        .dco1_n(dco1_n),
        .dco1_p(dco1_p),
        .fco1_n(fco1_n),
        .fco1_p(fco1_p),
        .sysclk_n(sysclk_n),
        .sysclk_p(sysclk_p),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd));
endmodule
