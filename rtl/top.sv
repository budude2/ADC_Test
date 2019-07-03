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
    input  logic [11:0] DATA_p_pin,
    input  logic [11:0] DATA_n_pin,

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
    output logic ETH_PHYRST_N,

    input logic eth_rxck,
    input logic eth_rxctl,
    input logic [3:0] eth_rxd
);

    // MMCM signals
    logic clk_100m, clk_50m, clk_125m, clk_125m90;
    logic dcm_locked;

    // ADC Signals
    logic adc_clk, aligned, en_synced;
    logic [15:0] adc1, adc2, adc3, adc4, adc7, adc8;
    logic [7:0] frmData;

    // Microblaze Signals
    logic [31:0] MB_O;

    // Buffering Signals
    logic  eth_valid, tick, eth_data_tlast;
    logic [7:0] eth_data;

    // Input signals
    logic btnc_db;

    // Reset Signals
    logic adc_rst_n, rst_125m_n, rst_125m;

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
        .reset(rst_125m),
        .sw(btnc),
        .db(btnc_db)
    );

    edge_detect_moore edge_detector
    (
        .clk(clk_125m),
        .reset(rst_125m),
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

    rstBridge rst_cross_125m
    (
        .clk(clk_125m),
        .asyncrst_n(cpu_resetn),
        .rst_n(rst_125m_n)
    );

    assign rst_125m = ~rst_125m_n;

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

        // ADC 3
        .d0b1_p(DATA_p_pin[8]),
        .d0b1_n(DATA_n_pin[8]),
        .d1b1_p(DATA_p_pin[9]),
        .d1b1_n(DATA_n_pin[9]),

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

        // ADC 7
        .d0d1_p(DATA_p_pin[10]),
        .d0d1_n(DATA_n_pin[10]),
        .d1d1_p(DATA_p_pin[11]),
        .d1d1_n(DATA_n_pin[11]),

        // ADC 8
        .d0d2_p(DATA_p_pin[4]),
        .d0d2_n(DATA_n_pin[4]),
        .d1d2_p(DATA_p_pin[5]),
        .d1d2_n(DATA_n_pin[5]),

        // Deserialized output
        .adc1(adc1),
        .adc2(adc2),
        .adc3(adc3),
        .adc4(adc4),
        .adc7(adc7),
        .adc8(adc8),

        // Clocks and Status Outputs
        .divclk_o(adc_clk),
        .frmData(frmData),

        .aligned(aligned)
    );

    adc_buffer adc_buffer (
        .start_buff(aligned & tick),
        //.start_buff(aligned),

        .din_clk(adc_clk),
        .din_rst_n(adc_rst_n),
        .din_valid(aligned),

        .adc1(adc1),
        .adc2(adc2),
        .adc3(adc3),
        .adc4(adc4),
        .adc7(adc7),
        .adc8(adc8),

        .dout_clk(clk_125m),
        .dout_rst_n(rst_125m_n),

        .dout(eth_data),
        .dout_valid(eth_valid),
        .axis_tlast(eth_data_tlast)
    );

    logic m_udp_hdr_valid, m_udp_payload_axis_tvalid, m_udp_payload_axis_tlast, m_udp_payload_axis_tuser, eth_tready;
    logic [15:0] m_udp_source_port, m_udp_dest_port, m_udp_length, m_udp_checksum;
    logic [7:0] m_udp_payload_axis_tdata;

    eth eth_i
    (
        .gtx_clk(clk_125m),
        .gtx_clk90(clk_125m90),
        .gtx_rst(rst_125m),
        .logic_clk(clk_125m),
        .logic_rst(rst_125m),

        /*
         * RGMII interface
         */
        .rgmii_rx_clk(eth_rxck),                                // Input
        .rgmii_rxd(eth_rxd),                                    // Input [3:0]
        .rgmii_rx_ctl(eth_rxctl),                               // Input

        .rgmii_tx_clk(eth_txck),                                // Output
        .rgmii_txd(eth_txd),                                    // Output [3:0]
        .rgmii_tx_ctl(ETH_TX_EN),                               // Output

        .tx_udp_payload_axis_tdata(eth_data),                   // Input [7:0]
        .tx_udp_payload_axis_tvalid(eth_valid),                 // Input
        .tx_udp_payload_axis_tready(eth_tready),                          // Output
        .tx_udp_payload_axis_tlast(eth_data_tlast),             // Input
        .tx_udp_payload_axis_tuser(1'b0),                       // Input

        /*
         * UDP frame output
         */
        .udp_rx_ready(1'b1),                                    // Input
        .udp_hdr_valid(m_udp_hdr_valid),                        // Output
        .udp_source_port(m_udp_source_port),                    // Output [15:0]
        .udp_dest_port(m_udp_dest_port),                        // Output [15:0]
        .udp_length(m_udp_length),                              // Output [15:0]
        .udp_checksum(m_udp_checksum),                          // Output [15:0]
        .rx_udp_payload_axis_tdata(m_udp_payload_axis_tdata),   // Output [7:0]
        .rx_udp_payload_axis_tvalid(m_udp_payload_axis_tvalid), // Output
        .rx_udp_payload_axis_tlast(m_udp_payload_axis_tlast),   // Output
        .rx_udp_payload_axis_tuser(m_udp_payload_axis_tuser)    // Output
    );

    assign ETH_PHYRST_N = 1'b1;

    ila_0 ila
    (
        .clk(clk_125m),                     // input wire clk

        .probe0(eth_data),  // input wire [7:0]  probe5
        .probe1(eth_valid), // input wire [0:0]  probe6
        .probe2(eth_tready),  // input wire [0:0]  probe7
        .probe3(eth_data_tlast)   // input wire [0:0]  probe8
);


endmodule