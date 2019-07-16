`timescale 1ns / 1ps

module udp_rx
    (
        input logic logic_clk,
        input logic logic_rst,

        /*
         * AXI input
         */
        input logic [7:0]   s_axis_tdata,
        input logic         s_axis_tvalid,
        output logic        s_axis_tready,
        input logic         s_axis_tlast,
        input logic         s_axis_tuser,

        /*
         * IP frame output
         */
        output logic [3:0] ip_version,             // Output [3:0]
        output logic [3:0] ip_ihl,                 // Output [3:0]
        output logic [5:0] ip_dscp,                // Output [5:0]
        output logic [1:0] ip_ecn,                 // Output [1:0]
        output logic [15:0] ip_length,             // Output [15:0]
        output logic [15:0] ip_identification,     // Output [15:0]
        output logic [2:0] ip_flags,               // Output [2:0]
        output logic [12:0] ip_fragment_offset,    // Output [12:0]
        output logic [7:0] ip_ttl,                 // Output [7:0]
        output logic [7:0] ip_protocol,            // Output [7:0]
        output logic [15:0] ip_header_checksum,    // Output [15:0]
        output logic [31:0] ip_source_ip,          // Output [31:0]
        output logic [31:0] ip_dest_ip,            // Output [31:0]

        /*
         * UDP frame output
         */
        input logic udp_rx_ready,
        output logic [15:0] eth_type,              // Output [15:0]
        output logic [47:0] eth_dest_mac,          // Output [47:0]
        output logic [47:0] eth_src_mac,           // Output [47:0]
        output logic udp_hdr_valid,                // Output
        output logic [15:0] udp_source_port,       // Output [15:0]
        output logic [15:0] udp_dest_port,         // Output [15:0]
        output logic [15:0] udp_length,            // Output [15:0]
        output logic [15:0] udp_checksum,          // Output [15:0]
        output logic [7:0] udp_payload_axis_tdata, // Output [7:0]
        output logic udp_payload_axis_tvalid,      // Output
        output logic udp_payload_axis_tlast,       // Output
        output logic udp_payload_axis_tuser,       // Output

        /*
         * Eth debug signals
         */
        output logic eth_busy,
        output logic eth_error_header_early_termination,

        /*
         * IP debug signals
         */
        output logic ip_busy,
        output logic ip_error_header_early_termination,
        output logic ip_error_payload_early_termination,
        output logic ip_error_invalid_header,
        output logic ip_error_invalid_checksum,

        /*
         * UDP debug signals
         */
        output logic udp_busy,
        output logic udp_error_header_early_termination,
        output logic udp_error_payload_early_termination
    );

    logic [47:0] m_eth_dest_mac, m_eth_src_mac;
    logic [15:0] m_eth_type;
    logic [7:0] m_eth_payload_axis_tdata;
    logic m_eth_hdr_valid, s_eth_hdr_ready, m_eth_payload_axis_tvalid, s_eth_payload_axis_tready, m_eth_payload_axis_tlast, m_eth_payload_axis_tuser;

    eth_axis_rx eth_axis_rx_i
    (
        .clk(logic_clk),
        .rst(logic_rst),

        /*
         * AXI input
         */
        .s_axis_tdata(s_axis_tdata),                           // Input [7:0]
        .s_axis_tvalid(s_axis_tvalid),                         // Input
        .s_axis_tready(s_axis_tready),                         // Output
        .s_axis_tlast(s_axis_tlast),                           // Input
        .s_axis_tuser(s_axis_tuser),                           // Input

        /*
         * Ethernet frame output
         */
        .m_eth_hdr_valid(m_eth_hdr_valid),                     // Output
        .m_eth_hdr_ready(s_eth_hdr_ready),                     // Input
        .m_eth_dest_mac(m_eth_dest_mac),                       // Output [47:0]
        .m_eth_src_mac(m_eth_src_mac),                         // Output [47:0]
        .m_eth_type(m_eth_type),                               // Output [15:0]
        .m_eth_payload_axis_tdata(m_eth_payload_axis_tdata),   // Output [7:0]
        .m_eth_payload_axis_tvalid(m_eth_payload_axis_tvalid), // Output
        .m_eth_payload_axis_tready(s_eth_payload_axis_tready), // Input
        .m_eth_payload_axis_tlast(m_eth_payload_axis_tlast),   // Output
        .m_eth_payload_axis_tuser(m_eth_payload_axis_tuser),   // Output

        /*
         * Status signals
         */
        .busy(eth_busy),
        .error_header_early_termination(eth_error_header_early_termination)
    );

    logic m_ip_hdr_valid, m_ip_payload_axis_tvalid, m_ip_payload_axis_tlast, m_ip_payload_axis_tuser, m_ip_hdr_ready, m_ip_payload_axis_tready;
    logic [47:0] m_eth_dest_mac_ip, m_eth_src_mac_ip;
    logic [31:0] m_ip_source_ip, m_ip_dest_ip;
    logic [15:0] m_ip_length, m_ip_identification, m_ip_header_checksum, m_eth_type_ip;
    logic [12:0] m_ip_fragment_offset;
    logic [7:0] m_ip_ttl, m_ip_protocol, m_ip_payload_axis_tdata;
    logic [5:0] m_ip_dscp;
    logic [3:0] m_ip_version, m_ip_ihl;
    logic [2:0] m_ip_flags;
    logic [1:0] m_ip_ecn;

    /*
     * IP ethernet frame receiver (Ethernet frame in, IP frame out)
     */
    ip_eth_rx ip_eth_rx_i
    (
        .clk(logic_clk),
        .rst(logic_rst),

        /*
         * Ethernet frame input
         */
        .s_eth_hdr_valid(m_eth_hdr_valid),                     // Input
        .s_eth_hdr_ready(s_eth_hdr_ready),                     // Output
        .s_eth_dest_mac(m_eth_dest_mac),                       // Input [47:0]
        .s_eth_src_mac(m_eth_src_mac),                         // Input [47:0]
        .s_eth_type(m_eth_type),                               // Input [15:0]
        .s_eth_payload_axis_tdata(m_eth_payload_axis_tdata),   // Input [7:0]
        .s_eth_payload_axis_tvalid(m_eth_payload_axis_tvalid), // Input
        .s_eth_payload_axis_tready(s_eth_payload_axis_tready), // Output
        .s_eth_payload_axis_tlast(m_eth_payload_axis_tlast),   // Input
        .s_eth_payload_axis_tuser(m_eth_payload_axis_tuser),   // Input

        /*
         * IP frame output
         */

        .m_eth_dest_mac(m_eth_dest_mac_ip),                    // Output [47:0]
        .m_eth_src_mac(m_eth_src_mac_ip),                      // Output [47:0]
        .m_eth_type(m_eth_type_ip),                            // Output [15:0]

        .m_ip_hdr_valid(m_ip_hdr_valid),                       // Output
        .m_ip_hdr_ready(m_ip_hdr_ready),                       // Input
        .m_ip_version(m_ip_version),                           // Output [3:0]
        .m_ip_ihl(m_ip_ihl),                                   // Output [3:0]
        .m_ip_dscp(m_ip_dscp),                                 // Output [5:0]
        .m_ip_ecn(m_ip_ecn),                                   // Output [1:0]
        .m_ip_length(m_ip_length),                             // Output [15:0]
        .m_ip_identification(m_ip_identification),             // Output [15:0]
        .m_ip_flags(m_ip_flags),                               // Output [2:0]
        .m_ip_fragment_offset(m_ip_fragment_offset),           // Output [12:0]
        .m_ip_ttl(m_ip_ttl),                                   // Output [7:0]
        .m_ip_protocol(m_ip_protocol),                         // Output [7:0]
        .m_ip_header_checksum(m_ip_header_checksum),           // Output [15:0]
        .m_ip_source_ip(m_ip_source_ip),                       // Output [31:0]
        .m_ip_dest_ip(m_ip_dest_ip),                           // Output [31:0]
        .m_ip_payload_axis_tdata(m_ip_payload_axis_tdata),     // Output [7:0]
        .m_ip_payload_axis_tvalid(m_ip_payload_axis_tvalid),   // Output
        .m_ip_payload_axis_tready(m_ip_payload_axis_tready),   // Input
        .m_ip_payload_axis_tlast(m_ip_payload_axis_tlast),     // Output
        .m_ip_payload_axis_tuser(m_ip_payload_axis_tuser),     // Output

        /*
         * Status signals
         */
        .busy(ip_busy),
        .error_header_early_termination(ip_error_header_early_termination),
        .error_payload_early_termination(ip_error_payload_early_termination),
        .error_invalid_header(ip_error_invalid_header),
        .error_invalid_checksum(ip_error_invalid_checksum)
    );

    udp_ip_rx udp_ip_rx_i
    (
        .clk(logic_clk),
        .rst(logic_rst),

        /*
         * IP frame input
         */
        .s_eth_dest_mac(m_eth_dest_mac_ip),                  // Input [47:0]
        .s_eth_src_mac(m_eth_src_mac_ip),                    // Input [47:0]
        .s_eth_type(m_eth_type_ip),                          // Input [15:0]
        .s_ip_hdr_valid(m_ip_hdr_valid),                     // Input
        .s_ip_hdr_ready(m_ip_hdr_ready),                     // Output
        .s_ip_version(m_ip_version),                         // Input [3:0]
        .s_ip_ihl(m_ip_ihl),                                 // Input [3:0]
        .s_ip_dscp(m_ip_dscp),                               // Input [5:0]
        .s_ip_ecn(m_ip_ecn),                                 // Input [1:0]
        .s_ip_length(m_ip_length),                           // Input [15:0]
        .s_ip_identification(m_ip_identification),           // Input [15:0]
        .s_ip_flags(m_ip_flags),                             // Input [2:0]
        .s_ip_fragment_offset(m_ip_fragment_offset),         // Input [12:0]
        .s_ip_ttl(m_ip_ttl),                                 // Input [7:0]
        .s_ip_protocol(m_ip_protocol),                       // Input [7:0]
        .s_ip_header_checksum(m_ip_header_checksum),         // Input [15:0]
        .s_ip_source_ip(m_ip_source_ip),                     // Input [31:0]
        .s_ip_dest_ip(m_ip_dest_ip),                         // Input [31:0]
        .s_ip_payload_axis_tdata(m_ip_payload_axis_tdata),   // Input [7:0]
        .s_ip_payload_axis_tvalid(m_ip_payload_axis_tvalid), // Input
        .s_ip_payload_axis_tready(m_ip_payload_axis_tready), // Output
        .s_ip_payload_axis_tlast(m_ip_payload_axis_tlast),   // Input
        .s_ip_payload_axis_tuser(m_ip_payload_axis_tuser),   // Input


        /*
         * ETH output
         */
        .m_eth_dest_mac(eth_dest_mac),                       // Output [47:0]
        .m_eth_src_mac(eth_src_mac),                         // Output [47:0]
        .m_eth_type(eth_type),                               // Output [15:0]

        /*
         * IP frame output
         */
        .m_ip_version(ip_version),                           // Output [3:0]
        .m_ip_ihl(ip_ihl),                                   // Output [3:0]
        .m_ip_dscp(ip_dscp),                                 // Output [5:0]
        .m_ip_ecn(ip_ecn),                                   // Output [1:0]
        .m_ip_length(ip_length),                             // Output [15:0]
        .m_ip_identification(ip_identification),             // Output [15:0]
        .m_ip_flags(ip_flags),                               // Output [2:0]
        .m_ip_fragment_offset(ip_fragment_offset),           // Output [12:0]
        .m_ip_ttl(ip_ttl),                                   // Output [7:0]
        .m_ip_protocol(ip_protocol),                         // Output [7:0]
        .m_ip_header_checksum(ip_header_checksum),           // Output [15:0]
        .m_ip_source_ip(ip_source_ip),                       // Output [31:0]
        .m_ip_dest_ip(ip_dest_ip),                           // Output [31:0]

        /*
         * UDP frame output
         */
        .m_udp_hdr_valid(udp_hdr_valid),                     // Output
        .m_udp_hdr_ready(udp_rx_ready),                      // Input
        .m_udp_source_port(udp_source_port),                 // Output [15:0]
        .m_udp_dest_port(udp_dest_port),                     // Output [15:0]
        .m_udp_length(udp_length),                           // Output [15:0]
        .m_udp_checksum(udp_checksum),                       // Output [15:0]
        .m_udp_payload_axis_tdata(udp_payload_axis_tdata),   // Output [7:0]
        .m_udp_payload_axis_tvalid(udp_payload_axis_tvalid), // Output
        .m_udp_payload_axis_tready(udp_rx_ready),            // Input
        .m_udp_payload_axis_tlast(udp_payload_axis_tlast),   // Output
        .m_udp_payload_axis_tuser(udp_payload_axis_tuser),   // Output

        /*
         * Status signals
         */
        .busy(udp_busy),
        .error_header_early_termination(udp_error_header_early_termination),
        .error_payload_early_termination(udp_error_payload_early_termination)
    );

endmodule
