`timescale 1ns / 1ps

module top
( 
    input logic DCLK_p_pin,
    input logic DCLK_n_pin,
    input logic FCLK_p_pin,
    input logic FCLK_n_pin,
    input logic SysRefClk_p,
    input logic SysRefClk_n,
    input logic [7:0] DATA_p_pin,
    input logic [7:0] DATA_n_pin,
    input logic cpu_resetn,
    input logic btnc,
    input logic usb_uart_rxd,
    output logic usb_uart_txd,
    output logic CSB1,
    output logic CSB2,
    inout  logic SDIO,
    output logic SCLK,
    output logic led0,
    output logic led1,
    output logic led2,
    output logic led3
);

    logic dcm_locked, bitslip;
    logic clk_100m, clk_50m, clk_200m, clk_125m, rst_200m, rst_125m, adc_clk;
    logic [13:0] adc2, adc4, adc8;
    logic [31:0] MB_O;
    logic [7:0] frmData;

    assign led0 = dcm_locked;
    assign led1 = rst_200m;
    assign led2 = MB_O[0];
    assign led3 = MB_O[1];

    clk_wiz_0 MMCM
    (
        // Clock out ports
        .clk_100m(clk_100m),     // output clk_100m
        .clk_50m(clk_50m),       // output clk_50m
        .clk_200m(clk_200m),     // output clk_200m
        .clk_125m(clk_125m),     // output clk_125m
        // Status and control signals
        .resetn(cpu_resetn),     // input resetn
        .locked(dcm_locked),     // output locked
        // Clock in ports
        .clk_in1_p(SysRefClk_p), // input clk_in1_p
        .clk_in1_n(SysRefClk_n)  // input clk_in1_n
    );

    adc adc_inst
    ( 
        .DCLK_p_pin(DCLK_p_pin),
        .DCLK_n_pin(DCLK_n_pin),
        .FCLK_p_pin(FCLK_p_pin),
        .FCLK_n_pin(FCLK_n_pin),
        .cpu_resetn(cpu_resetn),
        .d0a2_p(DATA_p_pin[0]),
        .d0a2_n(DATA_n_pin[0]),
        .d1a2_p(DATA_p_pin[1]),
        .d1a2_n(DATA_n_pin[1]),
        .d0b2_p(DATA_p_pin[2]),
        .d0b2_n(DATA_n_pin[2]),
        .d1b2_p(DATA_p_pin[3]),
        .d1b2_n(DATA_n_pin[3]),
        .d0d2_p(DATA_p_pin[4]),
        .d0d2_n(DATA_n_pin[4]),
        .d1d2_p(DATA_p_pin[5]),
        .d1d2_n(DATA_n_pin[5]),
        .adc2(adc2),
        .adc4(adc4),
        .adc8(adc8),
        .divclk_o(adc_clk),
        .frmData(frmData),
        .adc_en(MB_O[0])
    );

    ila_0 ILA
    (
        .clk(adc_clk),
        .probe0(adc2),
        .probe1(adc4),
        .probe2(adc8),
        .probe3(frmData)
    );

    ADC_Control_wrapper MB
   (
        .ADC_CSB1(CSB1),
        .ADC_CSB2(CSB2),
        .ADC_SCLK(SCLK),
        .ADC_SDIO(SDIO),
        .cpu_resetn(cpu_resetn),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd),
        .clk_100m(clk_100m),
        .clk_50m(clk_50m),
        .dcm_locked(dcm_locked),
        .O(MB_O)
    );
endmodule