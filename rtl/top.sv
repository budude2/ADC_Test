`timescale 1ns / 1ps

module top
(
    input  logic SysRefClk_p,
    input  logic SysRefClk_n,
    input  logic cpu_resetn,
    input  logic btnc,

    output logic led0,
    output logic led1,
    output logic led2,
    output logic led3,

    // ADC Data Interface
    input  logic DCLK_p_pin,
    input  logic DCLK_n_pin,
    input  logic FCLK_p_pin,
    input  logic FCLK_n_pin,
    input  logic [7:0] DATA_p_pin,
    input  logic [7:0] DATA_n_pin,

    // UART
    input  logic usb_uart_rxd,
    output logic usb_uart_txd,

    // SPI
    output logic CSB1,
    output logic CSB2,
    inout  logic SDIO,
    output logic SCLK,

    // Gigabit Ethernet
    output logic [3:0] eth_txd,
    output logic ETH_TX_EN,
    output logic eth_txck,
    output logic ETH_PHYRST_N
);

    // MMCM signals
    logic clk_100m, clk_50m, clk_125m, clk_125m90;
    logic dcm_locked;

    // ADC Signals
    logic adc_clk, aligned, en_synced;
    logic [15:0] adc1, adc2, adc4, adc8;
    logic [7:0] frmData;

    // Microblaze Signals
    logic [31:0] MB_O;

    // Buffering Signals
    logic adc_rst_n, rst_125m_n, eth_valid, tick;
    logic [7:0] eth_data;

    // Input signals
    logic btnc_db;

    assign led0 = dcm_locked;
    assign led1 = 0;
    assign led2 = MB_O[0];
    assign led3 = MB_O[1];

    clk_wiz_0 MMCM
    (
        // Clock out ports
        .clk_100m(clk_100m),        // output clk_100m
        .clk_50m(clk_50m),          // output clk_50m
        .clk_125m(clk_125m),        // output clk_125m
        .clk_125m90(clk_125m90),    // output clk_125m90

        // Status signal
        .locked(dcm_locked),        // output locked

        // Clock in ports
        .clk_in1_p(SysRefClk_p),    // input clk_in1_p
        .clk_in1_n(SysRefClk_n)     // input clk_in1_n
    );

    db_fsm debouncer
    (
        .clk(clk_125m),
        .reset(!rst_125m_n),
        .sw(btnc),
        .db(btnc_db)
    );

    edge_detect_moore edge_detector
    (
        .clk(clk_125m),
        .reset(!rst_125m_n),
        .level(btnc_db),
        .tick(tick)
    );

    simpleCDC enCDC
    (
        .sourceClk(clk_100m),
        .destClk(adc_clk),
        .d_in(MB_O[0]),
        .d_out(en_synced)
    );

    rstBridge cdcReset
    (
        .clk(adc_clk),
        .asyncrst_n(cpu_resetn),
        .rst_n(adc_rst_n)
    );

    rstBridge rst_125m
    (
        .clk(clk_125m),
        .asyncrst_n(cpu_resetn),
        .rst_n(rst_125m_n)
    );

    ADC_Control_wrapper MB
    (
        .clk_100m(clk_100m),
        .clk_50m(clk_50m),
        .dcm_locked(dcm_locked),
        .cpu_resetn(cpu_resetn),

        .ADC_CSB1(CSB1),
        .ADC_CSB2(CSB2),
        .ADC_SCLK(SCLK),
        .ADC_SDIO(SDIO),
        
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd),
        
        .O(MB_O)
    );

    adc_interface adc_inst
    ( 
        .DCLK_p_pin(DCLK_p_pin),
        .DCLK_n_pin(DCLK_n_pin),
        .FCLK_p_pin(FCLK_p_pin),
        .FCLK_n_pin(FCLK_n_pin),

        .rst_n(cpu_resetn),
        .adc_en(en_synced),

        // ADC 1
        .d0a1_p(DATA_p_pin[6]),
        .d0a1_n(DATA_n_pin[6]),
        .d1a1_p(DATA_p_pin[7]),
        .d1a1_n(DATA_n_pin[7]),

        // ADC 2
        .d0a2_p(DATA_p_pin[0]),
        .d0a2_n(DATA_n_pin[0]),
        .d1a2_p(DATA_p_pin[1]),
        .d1a2_n(DATA_n_pin[1]),

        // ADC 4
        .d0b2_p(DATA_p_pin[2]),
        .d0b2_n(DATA_n_pin[2]),
        .d1b2_p(DATA_p_pin[3]),
        .d1b2_n(DATA_n_pin[3]),

        // ADC 8
        .d0d2_p(DATA_p_pin[4]),
        .d0d2_n(DATA_n_pin[4]),
        .d1d2_p(DATA_p_pin[5]),
        .d1d2_n(DATA_n_pin[5]),

        // Deserialized output
        .adc1(adc1),
        .adc2(adc2),
        .adc4(adc4),
        .adc8(adc8),

        // Clocks and Status Outputs
        .divclk_o(adc_clk),
        .frmData(frmData),
        
        .aligned(aligned)
    );

    adc_buffer adc_buffer (
        .start_buff(aligned & tick),

        .din_clk   (adc_clk   ),
        .din_rst_n (adc_rst_n ),
        .din_valid (aligned   ),

        .adc1      (adc1      ),
        .adc2      (adc2      ),
        .adc4      (adc4      ),
        .adc8      (adc8      ),

        .dout_clk  (clk_125m  ),
        .dout_rst_n(rst_125m_n),

        .dout      (eth_data  ),
        .dout_valid(eth_valid )
    );


    udp_tx_top udp_tx
    (
        .clk_125m(clk_125m),
        .clk_125m90(clk_125m90),

        .udp_tx_data(eth_data),
        .udp_tx_valid(eth_valid),
        .udp_tx_busy(),

        .eth_txd(eth_txd),
        .ETH_TX_EN(ETH_TX_EN),
        .eth_txck(eth_txck),
        .ETH_PHYRST_N(ETH_PHYRST_N)
    );

    // ila_0 ila (
    //     .clk(clk_125m), // input wire clk

    //     .probe0(start), // input wire [0:0]  probe0  
    //     .probe1(adc1_valid), // input wire [0:0]  probe1 
    //     .probe2(adc2_valid), // input wire [0:0]  probe2 
    //     .probe3(empty_adc1), // input wire [0:0]  probe3 
    //     .probe4(empty_adc2), // input wire [0:0]  probe4 
    //     .probe5(en_rd1), // input wire [0:0]  probe5 
    //     .probe6(en_rd2), // input wire [0:0]  probe6
    //     .probe7(full_adc1),
    //     .probe8(full_adc2)
    // );

endmodule