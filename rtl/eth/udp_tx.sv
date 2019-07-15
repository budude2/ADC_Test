`timescale 1ns / 1ps

module udp_tx
    (
        input logic logic_clk,
        input logic logic_rst,

        /*
         * UDP frame input
         */
        input  wire        s_udp_hdr_valid,
        output wire        s_udp_hdr_ready,
        input  wire [47:0] s_eth_dest_mac,
        input  wire [47:0] s_eth_src_mac,
        input  wire [15:0] s_eth_type,
        input  wire [3:0]  s_ip_version,
        input  wire [3:0]  s_ip_ihl,
        input  wire [5:0]  s_ip_dscp,
        input  wire [1:0]  s_ip_ecn,
        input  wire [15:0] s_ip_identification,
        input  wire [2:0]  s_ip_flags,
        input  wire [12:0] s_ip_fragment_offset,
        input  wire [7:0]  s_ip_ttl,
        input  wire [7:0]  s_ip_protocol,
        input  wire [15:0] s_ip_header_checksum,
        input  wire [31:0] s_ip_source_ip,
        input  wire [31:0] s_ip_dest_ip,
        input  wire [15:0] s_udp_source_port,
        input  wire [15:0] s_udp_dest_port,
        input  wire [15:0] s_udp_length,
        input  wire [15:0] s_udp_checksum,

        input  wire [7:0]  s_udp_payload_axis_tdata,
        input  wire        s_udp_payload_axis_tvalid,
        output wire        s_udp_payload_axis_tready,
        input  wire        s_udp_payload_axis_tlast,
        input  wire        s_udp_payload_axis_tuser,

        /*
         * AXI output
         */
        output wire [7:0]  m_axis_tdata,
        output wire        m_axis_tvalid,
        input  wire        m_axis_tready,
        output wire        m_axis_tlast,
        output wire        m_axis_tuser,

        /*
         * Status signals
         */
        output wire        busy
    );

    /*

    UDP Frame

     Field                       Length
     Destination MAC address     6 octets
     Source MAC address          6 octets
     Ethertype (0x0800)          2 octets
     Version (4)                 4 bits
     IHL (5-15)                  4 bits
     DSCP (0)                    6 bits
     ECN (0)                     2 bits
     length                      2 octets
     identification (0?)         2 octets
     flags (010)                 3 bits
     fragment offset (0)         13 bits
     time to live (64?)          1 octet
     protocol                    1 octet
     header checksum             2 octets
     source IP                   4 octets
     destination IP              4 octets
     options                     (IHL-5)*4 octets

     source port                 2 octets
     desination port             2 octets
     length                      2 octets
     checksum                    2 octets

     payload                     length octets

    This module receives a UDP frame with header fields in parallel along with the
    payload in an AXI stream, combines the header with the payload, passes through
    the IP headers, and transmits the complete IP payload on an AXI interface.

    */

    logic [47:0] m_eth_dest_mac_udp, m_eth_src_mac_udp;
    logic [31:0] m_ip_source_ip, m_ip_dest_ip;
    logic [15:0] m_ip_length, m_ip_identification, m_eth_type_udp, m_ip_header_checksum;
    logic [12:0] m_ip_fragment_offset;
    logic [7:0] m_ip_ttl, m_ip_protocol, m_ip_payload_axis_tdata;
    logic [5:0] m_ip_dscp;
    logic [3:0] m_ip_version, m_ip_ihl;
    logic [2:0] m_ip_flags;
    logic [1:0] m_ip_ecn;
    logic m_ip_hdr_valid, m_ip_hdr_ready, m_ip_payload_axis_tvalid, m_ip_payload_axis_tready, m_ip_payload_axis_tlast, m_ip_payload_axis_tuser;

    udp_ip_tx udp_ip_tx_i
    (
        .clk(logic_clk),
        .rst(logic_rst),

        /*
         * UDP frame input
         */
        .s_udp_hdr_valid(s_udp_hdr_valid),                     // Input
        .s_udp_hdr_ready(s_udp_hdr_ready),                     // Output
        .s_eth_dest_mac(s_eth_dest_mac),                       // Input [47:0]
        .s_eth_src_mac(s_eth_src_mac),                         // Input [47:0]
        .s_eth_type(s_eth_type),                               // Input [15:0]
        .s_ip_version(s_ip_version),                           // Input [3:0]
        .s_ip_ihl(s_ip_ihl),                                   // Input [3:0]
        .s_ip_dscp(s_ip_dscp),                                 // Input [5:0]
        .s_ip_ecn(s_ip_ecn),                                   // Input [1:0]
        .s_ip_identification(s_ip_identification),             // Input [15:0]
        .s_ip_flags(s_ip_flags),                               // Input [2:0]
        .s_ip_fragment_offset(s_ip_fragment_offset),           // Input [12:0]
        .s_ip_ttl(s_ip_ttl),                                   // Input [7:0]
        .s_ip_protocol(s_ip_protocol),                         // Input [7:0]
        .s_ip_header_checksum(s_ip_header_checksum),           // Input [15:0]
        .s_ip_source_ip(s_ip_source_ip),                       // Input [31:0]
        .s_ip_dest_ip(s_ip_dest_ip),                           // Input [31:0]
        .s_udp_source_port(s_udp_source_port),                 // Input [15:0]
        .s_udp_dest_port(s_udp_dest_port),                     // Input [15:0]
        .s_udp_length(s_udp_length),                           // Input [15:0]
        .s_udp_checksum(s_udp_checksum),                       // Input [15:0]

        .s_udp_payload_axis_tdata(s_udp_payload_axis_tdata),   // Input [7:0]
        .s_udp_payload_axis_tvalid(s_udp_payload_axis_tvalid), // Input
        .s_udp_payload_axis_tready(s_udp_payload_axis_tready), // Output
        .s_udp_payload_axis_tlast(s_udp_payload_axis_tlast),   // Input
        .s_udp_payload_axis_tuser(s_udp_payload_axis_tuser),   // Input

        /*
         * IP frame output
         */
        .m_ip_hdr_valid(m_ip_hdr_valid),                       // Output
        .m_ip_hdr_ready(m_ip_hdr_ready),                       // Input
        .m_eth_dest_mac(m_eth_dest_mac_udp),                   // Output [47:0]
        .m_eth_src_mac(m_eth_src_mac_udp),                     // Output [47:0]
        .m_eth_type(m_eth_type_udp),                           // Output [15:0]
        .m_ip_version(),                                       // Output [3:0]
        .m_ip_ihl(),                                           // Output [3:0]
        .m_ip_dscp(m_ip_dscp),                                 // Output [5:0]
        .m_ip_ecn(m_ip_ecn),                                   // Output [1:0]
        .m_ip_length(m_ip_length),                             // Output [15:0]
        .m_ip_identification(m_ip_identification),             // Output [15:0]
        .m_ip_flags(m_ip_flags),                               // Output [2:0]
        .m_ip_fragment_offset(m_ip_fragment_offset),           // Output [12:0]
        .m_ip_ttl(m_ip_ttl),                                   // Output [7:0]
        .m_ip_protocol(m_ip_protocol),                         // Output [7:0]
        .m_ip_header_checksum(),                               // Output [15:0]
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
        .busy(),
        .error_payload_early_termination()
    );

    /*

    IP Frame

     Field                       Length
     Destination MAC address     6 octets
     Source MAC address          6 octets
     Ethertype (0x0800)          2 octets
     Version (4)                 4 bits
     IHL (5-15)                  4 bits
     DSCP (0)                    6 bits
     ECN (0)                     2 bits
     length                      2 octets
     identification (0?)         2 octets
     flags (010)                 3 bits
     fragment offset (0)         13 bits
     time to live (64?)          1 octet
     protocol                    1 octet
     header checksum             2 octets
     source IP                   4 octets
     destination IP              4 octets
     options                     (IHL-5)*4 octets
     payload                     length octets

    This module receives an IP frame with header fields in parallel along with the
    payload in an AXI stream, combines the header with the payload, passes through
    the Ethernet headers, and transmits the complete Ethernet payload on an AXI
    interface.

    */

    logic [47:0] m_eth_dest_mac, m_eth_src_mac;
    logic [15:0] m_eth_type;
    logic [7:0] m_eth_payload_axis_tdata;
    logic m_eth_hdr_valid, m_eth_hdr_ready, m_eth_payload_axis_tvalid, m_eth_payload_axis_tready, m_eth_payload_axis_tlast, m_eth_payload_axis_tuser;

    ip_eth_tx ip_eth_tx_i
    (
        .clk(logic_clk),
        .rst(logic_rst),

        /*
         * IP frame input
         */
        .s_ip_hdr_valid(m_ip_hdr_valid),                       // Input
        .s_ip_hdr_ready(m_ip_hdr_ready),                       // Output
        .s_eth_dest_mac(m_eth_dest_mac_udp),                   // Input [47:0]
        .s_eth_src_mac(m_eth_src_mac_udp),                     // Input [47:0]
        .s_eth_type(m_eth_type_udp),                           // Input [15:0]
        .s_ip_dscp(m_ip_dscp),                                 // Input [5:0]
        .s_ip_ecn(m_ip_ecn),                                   // Input [1:0]
        .s_ip_length(m_ip_length),                             // Input [15:0]
        .s_ip_identification(m_ip_identification),             // Input [15:0]
        .s_ip_flags(m_ip_flags),                               // Input [2:0]
        .s_ip_fragment_offset(m_ip_fragment_offset),           // Input [12:0]
        .s_ip_ttl(m_ip_ttl),                                   // Input [7:0]
        .s_ip_protocol(m_ip_protocol),                         // Input [7:0]
        .s_ip_source_ip(m_ip_source_ip),                       // Input [31:0]
        .s_ip_dest_ip(m_ip_dest_ip),                           // Input [31:0]

        .s_ip_payload_axis_tdata(m_ip_payload_axis_tdata),     // Input [7:0]
        .s_ip_payload_axis_tvalid(m_ip_payload_axis_tvalid),   // Input
        .s_ip_payload_axis_tready(m_ip_payload_axis_tready),   // Output
        .s_ip_payload_axis_tlast(m_ip_payload_axis_tlast),     // Input
        .s_ip_payload_axis_tuser(m_ip_payload_axis_tuser),     // Input

        /*
         * Ethernet frame output
         */
        .m_eth_hdr_valid(m_eth_hdr_valid),                     // Output
        .m_eth_hdr_ready(m_eth_hdr_ready),                     // Input
        .m_eth_dest_mac(m_eth_dest_mac),                       // Output [47:0]
        .m_eth_src_mac(m_eth_src_mac),                         // Output [47:0]
        .m_eth_type(m_eth_type),                               // Output [15:0]
        .m_eth_payload_axis_tdata(m_eth_payload_axis_tdata),   // Output [7:0]
        .m_eth_payload_axis_tvalid(m_eth_payload_axis_tvalid), // Output
        .m_eth_payload_axis_tready(m_eth_payload_axis_tready), // Input
        .m_eth_payload_axis_tlast(m_eth_payload_axis_tlast),   // Output
        .m_eth_payload_axis_tuser(m_eth_payload_axis_tuser),   // Output

        /*
         * Status signals
         */
        .busy(),
        .error_payload_early_termination()
    );

    /*

    Ethernet frame

     Field                       Length
     Destination MAC address     6 octets
     Source MAC address          6 octets
     Ethertype                   2 octets

    This module receives an Ethernet frame with header fields in parallel along
    with the payload in an AXI stream, combines the header with the payload, and
    transmits the complete Ethernet frame on the output AXI stream interface.

    */

    eth_axis_tx eth_axis_tx_i
    (
        .clk(logic_clk),
        .rst(logic_rst),

        /*
         * Ethernet frame input
         */
        .s_eth_hdr_valid(m_eth_hdr_valid),                     // Input
        .s_eth_hdr_ready(m_eth_hdr_ready),                     // Output
        .s_eth_dest_mac(m_eth_dest_mac),                       // Input [47:0]
        .s_eth_src_mac(m_eth_src_mac),                         // Input [47:0]
        .s_eth_type(m_eth_type),                               // Input [15:0]
        .s_eth_payload_axis_tdata(m_eth_payload_axis_tdata),   // Input [7:0]
        .s_eth_payload_axis_tvalid(m_eth_payload_axis_tvalid), // Input
        .s_eth_payload_axis_tready(m_eth_payload_axis_tready), // Output
        .s_eth_payload_axis_tlast(m_eth_payload_axis_tlast),   // Input
        .s_eth_payload_axis_tuser(m_eth_payload_axis_tuser),   // Input

        /*
         * AXI output
         */
        .m_axis_tdata(m_axis_tdata),                           // Output [7:0]
        .m_axis_tvalid(m_axis_tvalid),                         // Output
        .m_axis_tready(m_axis_tready),                         // Input
        .m_axis_tlast(m_axis_tlast),                           // Output
        .m_axis_tuser(m_axis_tuser),                           // Output

        /*
         * Status signals
         */
        .busy(busy)
    );

endmodule
