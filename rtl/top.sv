`timescale 1ns / 1ps

module top
( 
    input  logic DCLK_p_pin,
    input  logic DCLK_n_pin,
    input  logic FCLK_p_pin,
    input  logic FCLK_n_pin,
    input  logic SysRefClk_p,
    input  logic SysRefClk_n,
    input  logic [7:0] DATA_p_pin,
    input  logic [7:0] DATA_n_pin,
    input  logic cpu_resetn,
    input  logic btnc,
    input  logic usb_uart_rxd,
    output logic usb_uart_txd,
    output logic CSB1,
    output logic CSB2,
    inout  logic SDIO,
    output logic SCLK,
    output logic led0,
    output logic led1,
    output logic led2,
    output logic led3,
    output logic eth_mdc,
    inout  logic eth_mdio,
    input  logic [3:0] eth_rxd,
    input  logic eth_rxck,
    input  logic eth_rxctl,
    output logic [3:0] eth_txd,
    output logic ETH_TX_EN,
    output logic eth_txck,
    output logic ETH_PHYRST_N,
    input  logic eth_int_b,
    input  logic eth_pme_b,
    output logic [3:0] eth_leds
);

    logic dcm_locked, bitslip;
    logic clk_100m, clk_50m, clk_200m, clk_125m, rst_125m, adc_clk, aligned;
    logic [13:0] adc2, adc4, adc8;
    logic [15:0] adc1;
    logic [31:0] MB_O;
    logic [7:0] frmData;

    assign led0 = dcm_locked;
    assign led2 = MB_O[0];
    assign led3 = MB_O[1];

    clk_wiz_0 MMCM
    (
        // Clock out ports
        .clk_100m(clk_100m),     // output clk_100m
        .clk_50m(clk_50m),       // output clk_50m
        .clk_125m(clk_125m),     // output clk_200m
        .clk_125m90(clk_125m90),     // output clk_125m
        // Status and control signals
        //.resetn(cpu_resetn),     // input resetn
        .locked(dcm_locked),     // output locked
        // Clock in ports
        .clk_in1_p(SysRefClk_p), // input clk_in1_p
        .clk_in1_n(SysRefClk_n)  // input clk_in1_n
    );


    (* ASYNC_REG="TRUE" *) logic meta0, en_synced;

    always_ff @(posedge adc_clk) begin
         meta0 <= MB_O[0];
         en_synced <= meta0;
    end

    adc adc_inst
    ( 
        .DCLK_p_pin(DCLK_p_pin),
        .DCLK_n_pin(DCLK_n_pin),
        .FCLK_p_pin(FCLK_p_pin),
        .FCLK_n_pin(FCLK_n_pin),
        .cpu_resetn(cpu_resetn),
        .d0a1_p(DATA_p_pin[6]),
        .d0a1_n(DATA_n_pin[6]),
        .d1a1_p(DATA_p_pin[7]),
        .d1a1_n(DATA_n_pin[7]),
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
        .adc1(adc1),
        .adc2(adc2),
        .adc4(adc4),
        .adc8(adc8),
        .divclk_o(adc_clk),
        .frmData(frmData),
        .adc_en(en_synced),
        .aligned(aligned),
        .RstOut()
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


    logic wr_rst_n, rd_rst_n, full_wr, empty_wr, en_wr, en_rd, empty_rd, full_rd, eth_en, wr_rst_busy, rd_rst_busy, din_rdy, start, fifo_rst_state;
    logic [7:0] eth_data;
    logic [3:0] wrstate;
    logic [1:0] rdstate;

    assign start = aligned & btnc;
    assign fifo_rst_state = wr_rst_busy | rd_rst_busy;

    rstBridge writeReset
    (
    	.clk(adc_clk),
    	.asyncrst_n(cpu_resetn),
    	.rst_n(wr_rst_n)
    );

    writeController writeController
    (
        .rstn(wr_rst_n),
        .clk(adc_clk),
        .full(full_wr),
        .empty(empty_wr),
        .start(start),
        .wr_en(en_wr),
        .state(wrstate)
    );

    widthConverter adc1_buffer
    (
        .wr_rst(!wr_rst_n),
        .rd_rst(!rd_rst_n),

        .wr_clk(adc_clk),
        .wr_en(en_wr),
        .din(adc1),
        .full(full_wr),
        .wr_empty(empty_wr),    // Empty flag in wr_clk domain

        .rd_clk(clk_125m),
        .rd_en(en_rd & din_rdy),
        .dout(eth_data),
        .empty(empty_rd),
        .rd_full(full_rd)     // Full flag in rd_clk domain
    );

    rstBridge readReset
    (
    	.clk(clk_125m),
    	.asyncrst_n(cpu_resetn),
    	.rst_n(rd_rst_n)
    );

    readController readController
    (
        .clk(clk_125m),
        .rstn(rd_rst_n),
        .full(full_rd),
        .empty(empty_rd),
        .eth_en(eth_en),
        .rd_en(en_rd),
        .state(rdstate)
    );

    gigabit_test gigabit_tx
    (
        .clk125MHz(clk_125m),
        .clk125MHz90(clk_125m90),
        .switches(),
        .leds(eth_leds),
        .en(eth_en),
        .data_in(eth_data),
        .din_rdy(din_rdy),
       
        // Ethernet control signals   
        .eth_int_b(eth_int_b),
        .eth_pme_b(eth_pme_b),
        .eth_rst_b(ETH_PHYRST_N),

        // Ethernet management interface
        .eth_mdc(eth_mdc),
        .eth_mdio(eth_mdio),

        // Ethernet RX interface
        .eth_rxck(eth_rxck),
        .eth_rxctl(eth_rxctl),
        .eth_rxd(eth_rxd),

        // Ethernet TX interface
        .eth_txck(eth_txck),
        .eth_txctl(ETH_TX_EN),
        .eth_txd(eth_txd)
    );

    ila_0 ILA
    (
        .clk(clk_125m),
        .probe0(adc2),
        .probe1(adc4),
        .probe2(adc8),
        .probe3(frmData),
        .probe4(en_synced),
        .probe5(wr_rst), // input wire [0:0]  probe5 
        .probe6(aligned), // input wire [0:0]  probe6 
        .probe7(adc_clk), // input wire [0:0]  probe7 
        .probe8(en_rd), // input wire [0:0]  probe8 
        .probe9(din_rdy), // input wire [0:0]  probe9 
        .probe10(eth_en), // input wire [0:0]  probe10
        .probe11(wrstate), // input wire [0:0]  probe11 
        .probe12(fifo_rst_state), // input wire [0:0]  probe13
        .probe13(full_rd),
        .probe14(empty_rd),
        .probe15(rdstate)
    );

endmodule