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

        input logic [7:0]   tx_udp_payload_axis_tdata,
        input logic         tx_udp_payload_axis_tvalid,
        output logic        tx_udp_payload_axis_tready,
        input logic         tx_udp_payload_axis_tlast,
        input logic         tx_udp_payload_axis_tuser,

        /*
         * UDP frame output
         */
        input logic             udp_rx_ready,
        output logic            udp_hdr_valid,
        output logic [15:0]     udp_source_port,
        output logic [15:0]     udp_dest_port,
        output logic [15:0]     udp_length,
        output logic [15:0]     udp_checksum,
        output logic [7:0]      rx_udp_payload_axis_tdata,
        output logic            rx_udp_payload_axis_tvalid,
        output logic            rx_udp_payload_axis_tlast,
        output logic            rx_udp_payload_axis_tuser
    );

    logic [7:0] rx_axis_tdata;
    logic rx_axis_tvalid, rx_axis_tlast, rx_axis_tuser, rx_error_bad_frame, rx_axis_tready;
    logic [7:0] tx_axis_tdata;
    logic tx_axis_tvalid, tx_axis_tlast, tx_axis_tuser, tx_error_bad_frame, tx_axis_tready;
    logic [1:0] speed;

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
        .TX_FIFO_ADDR_WIDTH(12),
        .TX_FRAME_FIFO(1),
        .TX_DROP_BAD_FRAME(1),
        .TX_DROP_WHEN_FULL(0),
        .RX_FIFO_ADDR_WIDTH(12),
        .RX_FRAME_FIFO(1),
        .RX_DROP_BAD_FRAME(1),
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
         * Status
         */
        .tx_error_underflow(),
        .tx_fifo_overflow(),
        .tx_fifo_bad_frame(),
        .tx_fifo_good_frame(),
        .rx_error_bad_frame(rx_error_bad_frame),
        .rx_error_bad_fcs(),
        .rx_fifo_overflow(),
        .rx_fifo_bad_frame(),
        .rx_fifo_good_frame(),
        .speed(speed),

        /*
         * Configuration
         */
        .ifg_delay(1)
    );

    assign ETH_PHYRST_N = 1'b1;

    logic m_eth_hdr_valid, m_eth_payload_axis_tvalid, m_eth_payload_axis_tlast, m_eth_payload_axis_tuser;
    logic [47:0] m_eth_dest_mac, m_eth_src_mac;
    logic [15:0] m_eth_type;
    logic [7:0] m_eth_payload_axis_tdata;

    logic s_eth_hdr_ready, s_eth_payload_axis_tready;

    udp_rx udp_rx_i
    (
        .logic_clk(logic_clk),
        .logic_rst(logic_rst),

        .s_axis_tdata(rx_axis_tdata),
        .s_axis_tvalid(rx_axis_tvalid),
        .s_axis_tready(rx_axis_tready),
        .s_axis_tlast(rx_axis_tlast),
        .s_axis_tuser(rx_axis_tuser),

        /*
         * IP frame output
         */
        .ip_version(),                                        // Output [3:0]
        .ip_ihl(),                                            // Output [3:0]
        .ip_dscp(),                                           // Output [5:0]
        .ip_ecn(),                                            // Output [1:0]
        .ip_length(),                                         // Output [15:0]
        .ip_identification(),                                 // Output [15:0]
        .ip_flags(),                                          // Output [2:0]
        .ip_fragment_offset(),                                // Output [12:0]
        .ip_ttl(),                                            // Output [7:0]
        .ip_protocol(),                                       // Output [7:0]
        .ip_header_checksum(),                                // Output [15:0]
        .ip_source_ip(),                                      // Output [31:0]
        .ip_dest_ip(),                                        // Output [31:0]

        /*
         * UDP frame output
         */
        .udp_rx_ready(udp_rx_ready),
        .eth_type(),                                          // Output [15:0]
        .eth_dest_mac(),                                      // Output [47:0]
        .eth_src_mac(),                                       // Output [47:0]

        .udp_hdr_valid(udp_hdr_valid),                        // Output
        .udp_source_port(udp_source_port),                    // Output [15:0]
        .udp_dest_port(udp_dest_port),                        // Output [15:0]
        .udp_length(udp_length),                              // Output [15:0]
        .udp_checksum(udp_checksum),                          // Output [15:0]

        .udp_payload_axis_tdata(rx_udp_payload_axis_tdata),   // Output [7:0]
        .udp_payload_axis_tvalid(rx_udp_payload_axis_tvalid), // Output
        .udp_payload_axis_tlast(rx_udp_payload_axis_tlast),   // Output
        .udp_payload_axis_tuser(rx_udp_payload_axis_tuser),   // Output

        /*
         * Status signals
         */
        .busy(),
        .error_header_early_termination(),
        .error_payload_early_termination()
    );

    udp_tx udp_tx_i
    (
        .logic_clk(logic_clk),
        .logic_rst(logic_rst),

        /*
         * UDP frame input
         */
        .s_udp_hdr_valid(1'b1),                                 // Input
        .s_udp_hdr_ready(),                                     // Output
        .s_eth_dest_mac(48'hFFFFFFFFFFFF),                      // Input [47:0]
        .s_eth_src_mac(48'hDEADBEEF0123),                       // Input [47:0]
        .s_eth_type(16'h0800),                                  // Input [15:0]
        .s_ip_version(4'h4),                                    // Input [3:0]
        .s_ip_ihl(4'h0),                                        // Input [3:0]
        .s_ip_dscp(6'b001110),                                  // Input [5:0]
        .s_ip_ecn(2'b00),                                       // Input [1:0]
        .s_ip_identification(16'h0001),                         // Input [15:0]
        .s_ip_flags(3'b000),                                    // Input [2:0]
        .s_ip_fragment_offset(13'h000),                         // Input [12:0]
        .s_ip_ttl(8'h40),                                       // Input [7:0]
        .s_ip_protocol(8'h11),                                  // Input [7:0]
        .s_ip_header_checksum(16'h0000),                        // Input [15:0]
        .s_ip_source_ip(32'h7F000001),                          // Input [31:0]
        .s_ip_dest_ip(32'hFFFFFFFF),                            // Input [31:0]
        .s_udp_source_port(16'h1000),                           // Input [15:0]
        .s_udp_dest_port(16'h1000),                             // Input [15:0]
        .s_udp_length(16'h0200),                                // Input [15:0]
        .s_udp_checksum(16'h0000),                              // Input [15:0]

        .s_udp_payload_axis_tdata(tx_udp_payload_axis_tdata),   // Input [7:0]
        .s_udp_payload_axis_tvalid(tx_udp_payload_axis_tvalid), // Input
        .s_udp_payload_axis_tready(tx_udp_payload_axis_tready), // Output
        .s_udp_payload_axis_tlast(tx_udp_payload_axis_tlast),   // Input
        .s_udp_payload_axis_tuser(tx_udp_payload_axis_tuser),   // Input

        /*
         * AXI output
         */
        .m_axis_tdata(tx_axis_tdata),                           // Output [7:0]
        .m_axis_tvalid(tx_axis_tvalid),                         // Output
        .m_axis_tready(tx_axis_tready),                         // Input
        .m_axis_tlast(tx_axis_tlast),                           // Output
        .m_axis_tuser(tx_axis_tuser),                           // Output

        /*
         * Status signals
         */
        .busy()
    );

endmodule
