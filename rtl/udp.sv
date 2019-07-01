`timescale 1ns / 1ps

module udp
    (
        input logic clk_125m,
        input logic clk_250m,
        input logic rstn,

        input logic [3:0] rgmii_rxd,
        input logic rgmii_rx_ctl,
        input logic rgmii_rxc,

        output logic [3:0] rgmii_txd,
        output logic rgmii_tx_ctl,
        output logic rgmii_txc,

        input logic [7:0] tx_axis_mac_tdata,
        input logic tx_axis_mac_tvalid,
        input logic tx_axis_mac_tlast,
        input logic tx_axis_mac_tuser,
        output logic tx_axis_mac_tready,

        output logic [7:0] rx_axis_mac_tdata,
        output logic rx_axis_mac_tvalid,
        output logic rx_axis_mac_tlast,
        output logic rx_axis_mac_tuser,

        //debug
        output logic [27:0] rx_statistics_vector,
        output logic rx_statistics_valid,
        output logic rx_reset,
        output logic rx_enable,
        output logic [31:0] tx_statistics_vector,
        output logic tx_statistics_valid,
        output logic tx_reset,
        output logic tx_enable,
        output logic speedis100,
        output logic speedis10100
    );

tri_mode_ethernet_mac_0 mac
(
    .gtx_clk(clk_125m), // input  wire gtx_clk
    .gtx_clk_out(),     // output wire gtx_clk_out
    .gtx_clk90_out(),   // output wire gtx_clk90_out

    .glbl_rstn(rstn),   // input  wire glbl_rstn
    .rx_axi_rstn(rstn), // input  wire rx_axi_rstn
    .tx_axi_rstn(rstn), // input  wire tx_axi_rstn

    .rx_statistics_vector(rx_statistics_vector), // output wire [27 : 0] rx_statistics_vector
    .rx_statistics_valid(rx_statistics_valid),   // output wire rx_statistics_valid
    .rx_mac_aclk(),                   // output wire rx_mac_aclk
    .rx_reset(rx_reset),                         // output wire rx_reset
    .rx_enable(rx_enable),                       // output wire rx_enable
    .rx_axis_mac_tdata(rx_axis_mac_tdata),       // output wire [7 : 0] rx_axis_mac_tdata
    .rx_axis_mac_tvalid(rx_axis_mac_tvalid),     // output wire rx_axis_mac_tvalid
    .rx_axis_mac_tlast(rx_axis_mac_tlast),       // output wire rx_axis_mac_tlast
    .rx_axis_mac_tuser(rx_axis_mac_tuser),       // output wire rx_axis_mac_tuser

    .tx_ifg_delay(8'h00),                        // input  wire [7 : 0] tx_ifg_delay
    .tx_statistics_vector(tx_statistics_vector), // output wire [31 : 0] tx_statistics_vector
    .tx_statistics_valid(tx_statistics_valid),   // output wire tx_statistics_valid
    .tx_mac_aclk(),                   // output wire tx_mac_aclk
    .tx_reset(tx_reset),                         // output wire tx_reset
    .tx_enable(tx_enable),                       // output wire tx_enable
    .tx_axis_mac_tdata(tx_axis_mac_tdata),       // input  wire [7 : 0] tx_axis_mac_tdata
    .tx_axis_mac_tvalid(tx_axis_mac_tvalid),     // input  wire tx_axis_mac_tvalid
    .tx_axis_mac_tlast(tx_axis_mac_tlast),       // input  wire tx_axis_mac_tlast
    .tx_axis_mac_tuser(tx_axis_mac_tuser),       // input  wire [0 : 0] tx_axis_mac_tuser
    .tx_axis_mac_tready(tx_axis_mac_tready),     // output wire tx_axis_mac_tready

    .pause_req(0),        // input wire pause_req
    .pause_val(16'h0000), // input wire [15 : 0] pause_val
    .refclk(clk_250m),    // input wire refclk

    .speedis100(speedis100),     // output wire speedis100
    .speedis10100(speedis10100), // output wire speedis10100

    .rgmii_txd(rgmii_txd),       // output wire [3 : 0] rgmii_txd
    .rgmii_tx_ctl(rgmii_tx_ctl), // output wire rgmii_tx_ctl
    .rgmii_txc(rgmii_txc),       // output wire rgmii_txc
    .rgmii_rxd(rgmii_rxd),       // input  wire [3 : 0] rgmii_rxd
    .rgmii_rx_ctl(rgmii_rx_ctl), // input  wire rgmii_rx_ctl
    .rgmii_rxc(rgmii_rxc),       // input  wire rgmii_rxc

    .inband_link_status(),            // output wire inband_link_status
    .inband_clock_speed(),            // output wire [1 : 0] inband_clock_speed
    .inband_duplex_status(),        // output wire inband_duplex_status
    .rx_configuration_vector(80'hFFFFFFFFFFFF10002822),  // input wire [79 : 0] rx_configuration_vector
    .tx_configuration_vector(80'hFFFFFFFFFFFF10002002)   // input wire [79 : 0] tx_configuration_vector
);

endmodule
