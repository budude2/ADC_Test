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
    logic clk_100m, clk_50m, clk_200m, clk_125m;
    logic fifo0_full, fifo0_empty, fifo0_valid, fifo0_re, fifo_we, fifo0_underflow, fifo0_overflow;
    logic [63:0] data;
    logic [15:0] AdcFrmDataOut, AdcMemFlags, fifo0_data;
    logic [3:0] AdcMemFull, AdcMemEmpty;

    //IBUFDS #(
    //    .DIFF_TERM("TRUE"),       // Differential Termination
    //    .IBUF_LOW_PWR("FALSE"),     // Low power="TRUE", Highest performance="FALSE" 
    //    .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
    //) IBUFDS_inst (
    //    .O(SysRefClk),  // Buffer output
    //    .I(SysRefClk_p),  // Diff_p buffer input (connect directly to top-level port)
    //    .IB(SysRefClk_n) // Diff_n buffer input (connect directly to top-level port)
    //);
//
    //BUFG BUFG_inst (
    //    .O(SysRefClk_g), // 1-bit output: Clock output
    //    .I(SysRefClk)  // 1-bit input: Clock input
    //);

    AdcToplevel_Toplevel ADC
    (
        .DCLK_p_pin(DCLK_p_pin),
        .DCLK_n_pin(DCLK_n_pin),
        .FCLK_p_pin(FCLK_p_pin),
        .FCLK_n_pin(FCLK_n_pin),
        .DATA_p_pin(DATA_p_pin),
        .DATA_n_pin(DATA_n_pin),

        .SysRefClk(clk_200m),
        .AdcIntrfcRst(~cpu_resetn),
        .AdcIntrfcEna(dcm_locked),
        .AdcReSync(btnc),
        .AdcFrmSyncWrn(AdcFrmSyncWrn),
        .AdcBitClkAlgnWrn(AdcBitClkAlgnWrn),
        .AdcBitClkInvrtd(AdcBitClkInvrtd),
        .AdcBitClkDone(AdcBitClkDone),
        .AdcIdlyCtrlRdy(AdcIdlyCtrlRdy),

        .AdcFrmDataOut(AdcFrmDataOut),

        .AdcMemClk(clk_125m),
        .AdcMemRst(~cpu_resetn),
        .AdcMemEna(fifo_we),
        .AdcMemDataOut(data),
        .AdcMemFlags(AdcMemFlags),
        .AdcMemFull(AdcMemFull),
        .AdcMemEmpty(AdcMemEmpty)
    );

    ila_0 ILA
    (
        .clk(clk_125m),
        .probe0(fifo0_data),
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
        .probe12(AdcMemEmpty),
        .probe13(fifo_we),
        .probe14(fifo0_valid), // input wire [0:0]  probe14 
        .probe15(fifo0_underflow), // input wire [0:0]  probe15 
        .probe16(fifo0_overflow) // input wire [0:0]  probe16

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


  clk_wiz_0 MMCM
   (
        // Clock out ports
        .clk_100m(clk_100m),      // output clk_100m
        .clk_50m(clk_50m),        // output clk_50m
        .clk_200m(clk_200m),      // output clk_200m
        .clk_125m(clk_125m),      // output clk_125m
        // Status and control signals
        .resetn(cpu_resetn),      // input resetn
        .locked(dcm_locked),      // output locked
        // Clock in ports
        .clk_in1_p(SysRefClk_p),  // input clk_in1_p
        .clk_in1_n(SysRefClk_n)   // input clk_in1_n
    ); 

   fifo_generator_0 fifo0
   (
        .clk(clk_125m),                                                     // input wire clk
        .rst(~cpu_resetn),                                                  // input wire rst
        .din(data[15:0]),                                                   // input wire [15 : 0] din
        .wr_en(fifo_we), // input wire wr_en
        .rd_en(fifo0_re & dcm_locked),                                      // input wire rd_en
        .dout(fifo0_data),                                                  // output wire [15 : 0] dout
        .full(fifo0_full),                                                  // output wire full
        .empty(fifo0_empty),                                                // output wire empty
        .valid(fifo0_valid),                                                 // output wire valid
        .overflow(fifo0_overflow),    // output wire overflow
        .underflow(fifo0_underflow)  // output wire underflow
);

   assign fifo_we = dcm_locked & AdcMemEmpty[0] & ~AdcMemFull[0] & ~fifo0_full;

   Fdrse fifo0_control
    (.S(fifo0_full), .D(0), .CE(0), .C(clk_125m), .R(fifo0_empty), .Q(fifo0_re));
endmodule // top