`timescale 1ns / 1ps

module eth
    (
        input logic gtx_clk,
        input logic gtx_clk90,
        input logic gtx_rst,
        input logic logic_clk,
        input logic logic_rst,

        /*
         * RGMII interface
         */
        input logic         rgmii_rx_clk,
        input logic [3:0]   rgmii_rxd,
        input logic         rgmii_rx_ctl,

        output logic        rgmii_tx_clk,
        output logic [3:0]  rgmii_txd,
        output logic        rgmii_tx_ctl,

        output logic [1:0]  link_speed,

        /*
         *  Network config
         */

        input logic [47:0] local_mac,
        input logic [31:0] local_ip,
        input logic [31:0] gateway_ip,
        input logic [31:0] subnet_mask,
        input logic clear_arp_cache,

        /*
         * UDP TX input
         */

        input  logic tx_udp_hdr_valid,
        output logic tx_udp_hdr_ready,
        input  logic [5:0] tx_udp_ip_dscp,
        input  logic [1:0] tx_udp_ip_ecn,
        input  logic [7:0] tx_udp_ip_ttl,
        input  logic [31:0] tx_udp_ip_source_ip,
        input  logic [31:0] tx_udp_ip_dest_ip,
        input  logic [15:0] tx_udp_source_port,
        input  logic [15:0] tx_udp_dest_port,
        input  logic tx_udp_length,
        input  logic [15:0] tx_udp_checksum,
        input  logic [7:0] tx_udp_payload_axis_tdata,
        input  logic tx_udp_payload_axis_tvalid,
        output logic tx_udp_payload_axis_tready,
        input  logic tx_udp_payload_axis_tlast,
        input  logic tx_udp_payload_axis_tuser,

        /*
         * RX output
         */
        input logic         udp_rx_ready,
        output logic        udp_hdr_valid,
        output logic [15:0] udp_source_port,
        output logic [15:0] udp_dest_port,
        output logic [15:0] udp_length,
        output logic [15:0] udp_checksum,

        output logic [7:0]  rx_udp_payload_axis_tdata,
        output logic        rx_udp_payload_axis_tvalid,
        output logic        rx_udp_payload_axis_tlast,
        output logic        rx_udp_payload_axis_tuser,

        /*
         * TX Debug
         */
        output logic tx_error_underflow,
        output logic tx_fifo_overflow,
        output logic tx_fifo_bad_frame,
        output logic tx_fifo_good_frame,
        output logic tx_done,

        /*
         * RX Debug
         */
        output logic rx_error_bad_frame,
        output logic rx_error_bad_fcs,
        output logic rx_fifo_overflow,
        output logic rx_fifo_bad_frame,
        output logic rx_fifo_good_frame,

        /*
         * Eth debug signals
         */
        output logic tx_eth_busy,
        output logic rx_eth_busy
    );

    logic [7:0] rx_axis_tdata;
    logic rx_axis_tvalid, rx_axis_tlast, rx_axis_tuser, rx_axis_tready;
    logic [7:0] tx_axis_tdata;
    logic tx_axis_tvalid, tx_axis_tlast, tx_axis_tuser, tx_axis_tready;

    logic m_eth_hdr_valid;
    logic m_eth_hdr_ready;
    logic [47:0] m_eth_dest_mac;
    logic [47:0] m_eth_src_mac;
    logic [15:0] m_eth_type;
    logic [7:0] m_eth_payload_axis_tdata;
    logic m_eth_payload_axis_tvalid;
    logic m_eth_payload_axis_tready;
    logic m_eth_payload_axis_tlast;
    logic m_eth_payload_axis_tuser;

    logic s_eth_hdr_valid;
    logic s_eth_hdr_ready;
    logic [47:0] s_eth_dest_mac;
    logic [47:0] s_eth_src_mac;
    logic [15:0] s_eth_type;
    logic [7:0] s_eth_payload_axis_tdata;
    logic s_eth_payload_axis_tvalid;
    logic s_eth_payload_axis_tready;
    logic s_eth_payload_axis_tlast;
    logic s_eth_payload_axis_tuser;


    logic s_ip_hdr_valid;
    logic s_ip_hdr_ready;
    logic [5:0] s_ip_dscp;
    logic [1:0] s_ip_ecn;
    logic [15:0] s_ip_length;
    logic [7:0] s_ip_ttl;
    logic [7:0] s_ip_protocol;
    logic [31:0] s_ip_source_ip;
    logic [31:0] s_ip_dest_ip;
    logic [7:0] s_ip_payload_axis_tdata;
    logic s_ip_payload_axis_tvalid;
    logic s_ip_payload_axis_tready;
    logic s_ip_payload_axis_tlast;
    logic s_ip_payload_axis_tuser;
    logic m_ip_hdr_valid;
    logic m_ip_hdr_ready;
    logic [47:0] m_ip_eth_dest_mac;
    logic [47:0] m_ip_eth_src_mac;
    logic [15:0] m_ip_eth_type;
    logic [3:0] m_ip_version;
    logic [3:0] m_ip_ihl;
    logic [5:0] m_ip_dscp;
    logic [1:0] m_ip_ecn;
    logic [15:0] m_ip_length;
    logic [15:0] m_ip_identification;
    logic [2:0] m_ip_flags;
    logic [12:0] m_ip_fragment_offset;
    logic [7:0] m_ip_ttl;
    logic [7:0] m_ip_protocol;
    logic [15:0] m_ip_header_checksum;
    logic [31:0] m_ip_source_ip;
    logic [31:0] m_ip_dest_ip;
    logic [7:0] m_ip_payload_axis_tdata;
    logic m_ip_payload_axis_tvalid;
    logic m_ip_payload_axis_tready;
    logic m_ip_payload_axis_tlast;
    logic m_ip_payload_axis_tuser;
    logic s_udp_hdr_ready;
    logic [5:0] s_udp_ip_dscp;
    logic [1:0] s_udp_ip_ecn;
    logic [7:0] s_udp_ip_ttl;
    logic [31:0] s_udp_ip_source_ip;
    logic [31:0] s_udp_ip_dest_ip;
    logic [15:0] s_udp_source_port;
    logic [15:0] s_udp_dest_port;
    logic [15:0] s_udp_length;
    logic [15:0] s_udp_checksum;
    logic [7:0] s_udp_payload_axis_tdata;
    logic s_udp_payload_axis_tvalid;
    logic s_udp_payload_axis_tready;
    logic s_udp_payload_axis_tlast;
    logic s_udp_payload_axis_tuser;
    logic m_udp_hdr_valid;
    logic m_udp_hdr_ready;
    logic [47:0] m_udp_eth_dest_mac;
    logic [47:0] m_udp_eth_src_mac;
    logic [15:0] m_udp_eth_type;
    logic [3:0] m_udp_ip_version;
    logic [3:0] m_udp_ip_ihl;
    logic [5:0] m_udp_ip_dscp;
    logic [1:0] m_udp_ip_ecn;
    logic [15:0] m_udp_ip_length;
    logic [15:0] m_udp_ip_identification;
    logic [2:0] m_udp_ip_flags;
    logic [12:0] m_udp_ip_fragment_offset;
    logic [7:0] m_udp_ip_ttl;
    logic [7:0] m_udp_ip_protocol;
    logic [15:0] m_udp_ip_header_checksum;
    logic [31:0] m_udp_ip_source_ip;
    logic [31:0] m_udp_ip_dest_ip;
    logic [15:0] m_udp_source_port;
    logic [15:0] m_udp_dest_port;
    logic [15:0] m_udp_length;
    logic [15:0] m_udp_checksum;
    logic [7:0] m_udp_payload_axis_tdata;
    logic m_udp_payload_axis_tvalid;
    logic m_udp_payload_axis_tready;
    logic m_udp_payload_axis_tlast;
    logic m_udp_payload_axis_tuser;
    logic ip_rx_busy;
    logic ip_tx_busy;
    logic udp_rx_busy;
    logic udp_tx_busy;
    logic ip_rx_error_header_early_termination;
    logic ip_rx_error_payload_early_termination;
    logic ip_rx_error_invalid_header;
    logic ip_rx_error_invalid_checksum;
    logic ip_tx_error_payload_early_termination;
    logic ip_tx_error_arp_failed;
    logic udp_rx_error_header_early_termination;
    logic udp_rx_error_payload_early_termination;
    logic udp_tx_error_payload_early_termination;

    eth_mac_1g_rgmii_fifo #
    (
        // target ("SIM", "GENERIC", "XILINX", "ALTERA")
        .TARGET("XILINX"),
        // IODDR style ("IODDR", "IODDR2")
        // Use IODDR for Virtex-4, Virtex-5, Virtex-6, 7 Series, Ultrascale
        // Use IODDR2 for Spartan-6
        .IODDR_STYLE("IODDR"),
        // Clock input style ("BUFG", "BUFR", "BUFIO", "BUFIO2")
        // Use BUFR for Virtex-5, Virtex-6, 7-series
        // Use BUFG for Ultrascale
        // Use BUFIO2 for Spartan-6
        .CLOCK_INPUT_STYLE("BUFR"),
        // Use 90 degree clock for RGMII transmit ("TRUE", "FALSE")
        .USE_CLK90("TRUE"),
        .ENABLE_PADDING(1),
        .MIN_FRAME_LENGTH(8),
        .TX_FIFO_ADDR_WIDTH(15),
        .TX_FRAME_FIFO(1),
        .TX_DROP_BAD_FRAME(1),
        .TX_DROP_WHEN_FULL(0),
        .RX_FIFO_ADDR_WIDTH(12),
        .RX_FRAME_FIFO(1),
        .RX_DROP_BAD_FRAME(0),
        .RX_DROP_WHEN_FULL(1)
    ) eth_mac_1g_rgmii_fifo_i (
        .gtx_clk(gtx_clk),
        .gtx_clk90(gtx_clk90),
        .gtx_rst(gtx_rst),
        .logic_clk(logic_clk),
        .logic_rst(logic_rst),

        /*
         * RGMII interface
         */
        .rgmii_rx_clk(rgmii_rx_clk),
        .rgmii_rxd(rgmii_rxd),
        .rgmii_rx_ctl(rgmii_rx_ctl),
        .rgmii_tx_clk(rgmii_tx_clk),
        .rgmii_txd(rgmii_txd),
        .rgmii_tx_ctl(rgmii_tx_ctl),

        /*
         * AXI input
         */
        .tx_axis_tdata(tx_axis_tdata),  // [7:0]
        .tx_axis_tvalid(tx_axis_tvalid),
        .tx_axis_tready(tx_axis_tready),
        .tx_axis_tlast(tx_axis_tlast),
        .tx_axis_tuser(tx_axis_tuser),

        /*
         * AXI output
         */
        .rx_axis_tdata(rx_axis_tdata),   // [7:0]
        .rx_axis_tvalid(rx_axis_tvalid),
        .rx_axis_tready(rx_axis_tready),
        .rx_axis_tlast(rx_axis_tlast),
        .rx_axis_tuser(rx_axis_tuser),

        /*
         * TX Status
         */
        .tx_error_underflow(tx_error_underflow),
        .tx_fifo_overflow(tx_fifo_overflow),
        .tx_fifo_bad_frame(tx_fifo_bad_frame),
        .tx_fifo_good_frame(tx_fifo_good_frame),
        .tx_done(tx_done),

        /*
         * RX Status
         */
        .rx_error_bad_frame(rx_error_bad_frame),
        .rx_error_bad_fcs(rx_error_bad_fcs),
        .rx_fifo_overflow(rx_fifo_overflow),
        .rx_fifo_bad_frame(rx_fifo_bad_frame),
        .rx_fifo_good_frame(rx_fifo_good_frame),
        .speed(link_speed),

        /*
         * Configuration
         */
        .ifg_delay(8'h01)
    );

    assign ETH_PHYRST_N = 1'b1;

eth_axis_tx i_eth_axis_tx (
    .clk                      (logic_clk                ),
    .rst                      (logic_rst                  ),

    .s_eth_hdr_valid          (s_eth_hdr_valid          ),
    .s_eth_hdr_ready          (s_eth_hdr_ready          ),
    .s_eth_dest_mac           (s_eth_dest_mac           ),
    .s_eth_src_mac            (s_eth_src_mac            ),
    .s_eth_type               (s_eth_type               ),

    .s_eth_payload_axis_tdata (s_eth_payload_axis_tdata ),
    .s_eth_payload_axis_tvalid(s_eth_payload_axis_tvalid),
    .s_eth_payload_axis_tready(s_eth_payload_axis_tready),
    .s_eth_payload_axis_tlast (s_eth_payload_axis_tlast ),
    .s_eth_payload_axis_tuser (s_eth_payload_axis_tuser ),

    .m_axis_tdata             (tx_axis_tdata             ),
    .m_axis_tvalid            (tx_axis_tvalid            ),
    .m_axis_tready            (tx_axis_tready            ),
    .m_axis_tlast             (tx_axis_tlast             ),
    .m_axis_tuser             (tx_axis_tuser             ),
    .busy                     (tx_eth_busy                 )
);

eth_axis_rx i_eth_axis_rx (
    .clk                           (logic_clk                        ),
    .rst                           (logic_rst                          ),

    .s_axis_tdata                  (rx_axis_tdata                     ),
    .s_axis_tvalid                 (rx_axis_tvalid                    ),
    .s_axis_tready                 (rx_axis_tready                    ),
    .s_axis_tlast                  (rx_axis_tlast                     ),
    .s_axis_tuser                  (rx_axis_tuser                     ),

    .m_eth_hdr_valid               (m_eth_hdr_valid                  ),
    .m_eth_hdr_ready               (m_eth_hdr_ready                  ),
    .m_eth_dest_mac                (m_eth_dest_mac                   ),
    .m_eth_src_mac                 (m_eth_src_mac                    ),
    .m_eth_type                    (m_eth_type                       ),
    .m_eth_payload_axis_tdata      (m_eth_payload_axis_tdata         ),
    .m_eth_payload_axis_tvalid     (m_eth_payload_axis_tvalid        ),
    .m_eth_payload_axis_tready     (m_eth_payload_axis_tready        ),
    .m_eth_payload_axis_tlast      (m_eth_payload_axis_tlast         ),
    .m_eth_payload_axis_tuser      (m_eth_payload_axis_tuser         ),

    .busy                          (rx_eth_busy                         ),
    .error_header_early_termination(ip_error_header_early_termination)
);

// IP ports not used
assign rx_ip_hdr_ready           = 1;
assign rx_ip_payload_axis_tready = 1;

assign tx_ip_hdr_valid           = 0;
assign tx_ip_dscp                = 0;
assign tx_ip_ecn                 = 0;
assign tx_ip_length              = 0;
assign tx_ip_ttl                 = 0;
assign tx_ip_protocol            = 0;
assign tx_ip_source_ip           = 0;
assign tx_ip_dest_ip             = 0;
assign tx_ip_payload_axis_tdata  = 0;
assign tx_ip_payload_axis_tvalid = 0;
assign tx_ip_payload_axis_tlast  = 0;
assign tx_ip_payload_axis_tuser  = 0;

udp_complete i_udp_complete (
    .clk                                   (logic_clk                             ),
    .rst                                   (logic_rst                             ),

    // Ethernet frame input
    .s_eth_hdr_valid                       (m_eth_hdr_valid                       ), // input
    .s_eth_hdr_ready                       (m_eth_hdr_ready                       ), // output
    .s_eth_dest_mac                        (m_eth_dest_mac                        ), // input
    .s_eth_src_mac                         (m_eth_src_mac                         ), // input
    .s_eth_type                            (m_eth_type                            ), // input
    .s_eth_payload_axis_tdata              (m_eth_payload_axis_tdata              ), // input
    .s_eth_payload_axis_tvalid             (m_eth_payload_axis_tvalid             ), // input
    .s_eth_payload_axis_tready             (m_eth_payload_axis_tready             ), // output
    .s_eth_payload_axis_tlast              (m_eth_payload_axis_tlast              ), // input
    .s_eth_payload_axis_tuser              (m_eth_payload_axis_tuser              ), // input

    // Ethernet frame output
    .m_eth_hdr_valid                       (s_eth_hdr_valid                       ), // output
    .m_eth_hdr_ready                       (s_eth_hdr_ready                       ), // input
    .m_eth_dest_mac                        (s_eth_dest_mac                        ), // output
    .m_eth_src_mac                         (s_eth_src_mac                         ), // output
    .m_eth_type                            (s_eth_type                            ), // output
    .m_eth_payload_axis_tdata              (s_eth_payload_axis_tdata              ), // output
    .m_eth_payload_axis_tvalid             (s_eth_payload_axis_tvalid             ), // output
    .m_eth_payload_axis_tready             (s_eth_payload_axis_tready             ), // input
    .m_eth_payload_axis_tlast              (s_eth_payload_axis_tlast              ), // output
    .m_eth_payload_axis_tuser              (s_eth_payload_axis_tuser              ), // output

    // IP frame input
    .s_ip_hdr_valid                        (tx_ip_hdr_valid                        ), // input
    .s_ip_hdr_ready                        (), // output
    .s_ip_dscp                             (tx_ip_dscp                             ), // input
    .s_ip_ecn                              (tx_ip_ecn                              ), // input
    .s_ip_length                           (tx_ip_length                           ), // input
    .s_ip_ttl                              (tx_ip_ttl                              ), // input
    .s_ip_protocol                         (tx_ip_protocol                         ), // input
    .s_ip_source_ip                        (tx_ip_source_ip                        ), // input
    .s_ip_dest_ip                          (tx_ip_dest_ip                          ), // input
    .s_ip_payload_axis_tdata               (tx_ip_payload_axis_tdata               ), // input
    .s_ip_payload_axis_tvalid              (tx_ip_payload_axis_tvalid              ), // input
    .s_ip_payload_axis_tready              (), // output
    .s_ip_payload_axis_tlast               (tx_ip_payload_axis_tlast               ), // input
    .s_ip_payload_axis_tuser               (tx_ip_payload_axis_tuser               ), // input

    // IP frame output
    .m_ip_hdr_valid                        (m_ip_hdr_valid                        ), // output
    .m_ip_hdr_ready                        (rx_ip_hdr_ready                        ), // input
    .m_ip_eth_dest_mac                     (m_ip_eth_dest_mac                     ), // output
    .m_ip_eth_src_mac                      (m_ip_eth_src_mac                      ), // output
    .m_ip_eth_type                         (m_ip_eth_type                         ), // output
    .m_ip_version                          (m_ip_version                          ), // output
    .m_ip_ihl                              (m_ip_ihl                              ), // output
    .m_ip_dscp                             (m_ip_dscp                             ), // output
    .m_ip_ecn                              (m_ip_ecn                              ), // output
    .m_ip_length                           (m_ip_length                           ), // output
    .m_ip_identification                   (m_ip_identification                   ), // output
    .m_ip_flags                            (m_ip_flags                            ), // output
    .m_ip_fragment_offset                  (m_ip_fragment_offset                  ), // output
    .m_ip_ttl                              (m_ip_ttl                              ), // output
    .m_ip_protocol                         (m_ip_protocol                         ), // output
    .m_ip_header_checksum                  (m_ip_header_checksum                  ), // output
    .m_ip_source_ip                        (m_ip_source_ip                        ), // output
    .m_ip_dest_ip                          (m_ip_dest_ip                          ), // output
    .m_ip_payload_axis_tdata               (m_ip_payload_axis_tdata               ), // output
    .m_ip_payload_axis_tvalid              (m_ip_payload_axis_tvalid              ), // output
    .m_ip_payload_axis_tready              (rx_ip_payload_axis_tready              ), // input
    .m_ip_payload_axis_tlast               (m_ip_payload_axis_tlast               ), // output
    .m_ip_payload_axis_tuser               (m_ip_payload_axis_tuser               ), // output

    // UDP frame input
    .s_udp_hdr_valid                       (tx_udp_hdr_valid                       ), // input
    .s_udp_hdr_ready                       (tx_udp_hdr_ready                       ), // output
    .s_udp_ip_dscp                         (tx_udp_ip_dscp                         ), // input
    .s_udp_ip_ecn                          (tx_udp_ip_ecn                          ), // input
    .s_udp_ip_ttl                          (tx_udp_ip_ttl                          ), // input
    .s_udp_ip_source_ip                    (tx_udp_ip_source_ip                    ), // input
    .s_udp_ip_dest_ip                      (tx_udp_ip_dest_ip                      ), // input
    .s_udp_source_port                     (tx_udp_source_port                     ), // input
    .s_udp_dest_port                       (tx_udp_dest_port                       ), // input
    .s_udp_length                          (tx_udp_length                          ), // input
    .s_udp_checksum                        (tx_udp_checksum                        ), // input
    .s_udp_payload_axis_tdata              (tx_udp_payload_axis_tdata             ), // input
    .s_udp_payload_axis_tvalid             (tx_udp_payload_axis_tvalid            ), // input
    .s_udp_payload_axis_tready             (tx_udp_payload_axis_tready            ), // output
    .s_udp_payload_axis_tlast              (tx_udp_payload_axis_tlast             ), // input
    .s_udp_payload_axis_tuser              (tx_udp_payload_axis_tuser             ), // input

    // UDP frame output
    .m_udp_hdr_valid                       (udp_hdr_valid                         ), // output
    .m_udp_hdr_ready                       (udp_rx_ready                       ), // input
    .m_udp_eth_dest_mac                    (m_udp_eth_dest_mac                    ), // output
    .m_udp_eth_src_mac                     (m_udp_eth_src_mac                     ), // output
    .m_udp_eth_type                        (m_udp_eth_type                        ), // output
    .m_udp_ip_version                      (m_udp_ip_version                      ), // output
    .m_udp_ip_ihl                          (m_udp_ip_ihl                          ), // output
    .m_udp_ip_dscp                         (m_udp_ip_dscp                         ), // output
    .m_udp_ip_ecn                          (m_udp_ip_ecn                          ), // output
    .m_udp_ip_length                       (m_udp_ip_length                       ), // output
    .m_udp_ip_identification               (m_udp_ip_identification               ), // output
    .m_udp_ip_flags                        (m_udp_ip_flags                        ), // output
    .m_udp_ip_fragment_offset              (m_udp_ip_fragment_offset              ), // output
    .m_udp_ip_ttl                          (m_udp_ip_ttl                          ), // output
    .m_udp_ip_protocol                     (m_udp_ip_protocol                     ), // output
    .m_udp_ip_header_checksum              (m_udp_ip_header_checksum              ), // output
    .m_udp_ip_source_ip                    (m_udp_ip_source_ip                    ), // output
    .m_udp_ip_dest_ip                      (m_udp_ip_dest_ip                      ), // output
    .m_udp_source_port                     (udp_source_port                       ), // output
    .m_udp_dest_port                       (udp_dest_port                         ), // output
    .m_udp_length                          (udp_length                            ), // output
    .m_udp_checksum                        (udp_checksum                          ), // output
    .m_udp_payload_axis_tdata              (rx_udp_payload_axis_tdata             ), // output
    .m_udp_payload_axis_tvalid             (rx_udp_payload_axis_tvalid            ), // output
    .m_udp_payload_axis_tready             (udp_rx_ready                          ), // input
    .m_udp_payload_axis_tlast              (rx_udp_payload_axis_tlast             ), // output
    .m_udp_payload_axis_tuser              (rx_udp_payload_axis_tuser             ), // output

    // Status signals
    .ip_rx_busy                            (ip_rx_busy                            ), // output
    .ip_tx_busy                            (ip_tx_busy                            ), // output

    .udp_rx_busy                           (udp_rx_busy                           ), // output
    .udp_tx_busy                           (udp_tx_busy                           ), // output

    .ip_rx_error_header_early_termination  (ip_rx_error_header_early_termination  ), // output
    .ip_rx_error_payload_early_termination (ip_rx_error_payload_early_termination ), // output
    .ip_rx_error_invalid_header            (ip_rx_error_invalid_header            ), // output
    .ip_rx_error_invalid_checksum          (ip_rx_error_invalid_checksum          ), // output
    .ip_tx_error_payload_early_termination (ip_tx_error_payload_early_termination ), // output
    .ip_tx_error_arp_failed                (ip_tx_error_arp_failed                ), // output

    .udp_rx_error_header_early_termination (udp_rx_error_header_early_termination ), // output
    .udp_rx_error_payload_early_termination(udp_rx_error_payload_early_termination), // output
    .udp_tx_error_payload_early_termination(udp_tx_error_payload_early_termination), // output

    // Configuration
    .local_mac                             (local_mac                             ), // input 48
    .local_ip                              (local_ip                              ), // input 32
    .gateway_ip                            (gateway_ip                            ), // input 32
    .subnet_mask                           (subnet_mask                           ), // input 32
    .clear_arp_cache                       (clear_arp_cache                       )  // input
);


endmodule
