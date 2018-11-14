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
    output logic SCLK
);

    logic AdcFrmSyncWrn, AdcBitClkAlgnWrn, AdcBitClkInvrtd, AdcBitClkDone, AdcIdlyCtrlRdy, dcm_locked;
    logic clk_100m, clk_50m, clk_200m, clk_125m, rst_200m, rst_125m;
    logic [63:0] data;
    logic [15:0] AdcFrmDataOut, AdcMemFlags;
    logic [3:0] AdcMemFull, AdcMemEmpty;

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

    async_input_sync #
    (
        .SYNC_STAGES(3),
        .PIPELINE_STAGES(1),
        .INIT(1'b0)
    )
    reset_sync_200m
    (
        .clk(clk_200m),
        .async_in(~cpu_resetn | ~dcm_locked),
        .sync_out(rst_200m)
    );

    async_input_sync #
    (
        .SYNC_STAGES(3),
        .PIPELINE_STAGES(1),
        .INIT(1'b0)
    )
    reset_sync_125m
    (
        .clk(clk_125m),
        .async_in(~cpu_resetn | ~dcm_locked),
        .sync_out(rst_125m)
    );

    AdcToplevel_Toplevel ADC
    (
        .DCLK_p_pin(DCLK_p_pin),
        .DCLK_n_pin(DCLK_n_pin),
        .FCLK_p_pin(FCLK_p_pin),
        .FCLK_n_pin(FCLK_n_pin),
        .DATA_p_pin(DATA_p_pin),
        .DATA_n_pin(DATA_n_pin),

        .SysRefClk(clk_200m),
        .AdcIntrfcRst(rst_200m),
        .AdcIntrfcEna(dcm_locked),
        .AdcReSync(btnc),
        .AdcFrmSyncWrn(AdcFrmSyncWrn),
        .AdcBitClkAlgnWrn(AdcBitClkAlgnWrn),
        .AdcBitClkInvrtd(AdcBitClkInvrtd),
        .AdcBitClkDone(AdcBitClkDone),
        .AdcIdlyCtrlRdy(AdcIdlyCtrlRdy),

        .AdcFrmDataOut(AdcFrmDataOut),

        .AdcMemClk(clk_125m),
        .AdcMemRst(rst_125m),
        .AdcMemEna(dcm_locked),
        .AdcMemDataOut(data),
        .AdcMemFlags(AdcMemFlags),
        .AdcMemFull(AdcMemFull),
        .AdcMemEmpty(AdcMemEmpty)
    );

    ila_0 ILA
    (
        .clk(clk_125m),
        .probe0(data[15:0]),
        .probe1(data[31:16]),
        .probe2(data[47:32]),
        .probe3(data[63:48]),
        .probe4(AdcFrmSyncWrn),
        .probe5(AdcBitClkAlgnWrn),
        .probe6(AdcBitClkInvrtd),
        .probe7(AdcBitClkDone),
        .probe8(AdcIdlyCtrlRdy),
        .probe9(AdcFrmDataOut),
        .probe10(AdcMemFull),
        .probe11(AdcMemFlags),
        .probe12(AdcMemEmpty) 
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
        .dcm_locked(dcm_locked)
    );
endmodule