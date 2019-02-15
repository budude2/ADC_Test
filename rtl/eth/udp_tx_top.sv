`timescale 1ns / 1ps

module udp_tx_top
(
    input logic clk_125m,
    input logic clk_125m90,

    input logic udp_tx_valid,
    input logic [7:0] udp_tx_data,
    output logic udp_tx_busy,

    output logic [3:0] eth_txd,
    output logic ETH_TX_EN,
    output logic eth_txck,
    output logic ETH_PHYRST_N
);

logic packet_valid, phy_ready;
logic [7:0] packet_data;

udp_tx_packet #(
        .our_ip(32'h4001A4C0),
        .our_mac(48'h2301EFBEADDE)
    ) udp_generator (
        .clk(clk_125m),
        .udp_tx_busy(udp_tx_busy),
        .udp_tx_valid(udp_tx_valid),
        .udp_tx_data(udp_tx_data),

        .udp_tx_src_port(16'h1000),
        .udp_tx_dst_mac(48'hFFFFFFFFFFFF),
        .udp_tx_dst_ip(32'hFFFFFFFF),
        .udp_tx_dst_port(16'h1000),

        .packet_out_request(),
        .packet_out_granted(1'b1),
        .packet_out_valid(packet_valid),
        .packet_out_data(packet_data)
    );

tx_interface RGMII_TX
(
    .clk125MHz(clk_125m),
    .clk125Mhz90(clk_125m90),

    .phy_ready(phy_ready),

    .udp_valid(packet_valid),
    .udp_data(packet_data),

    .eth_txck(eth_txck),
    .eth_txctl(ETH_TX_EN),
    .eth_txd(eth_txd)
    );

reset_controller phy_rst
(
    .clk125mhz(clk_125m),
    .phy_ready(phy_ready),
    .eth_rst_b(ETH_PHYRST_N)
);

endmodule
