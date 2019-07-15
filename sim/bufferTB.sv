`timescale 1ns / 1ps

module bufferTB( );

    // MMCM signals
    logic clk_100m, clk_50m, clk_125m, clk_125m90, SysRefClk_p, SysRefClk_n;
    logic dcm_locked;

    // ADC Signals
    logic adc_clk, aligned, adc1_valid, adc2_valid, adc3_valid, adc4_valid, adc7_valid, adc8_valid, adc_rst_n;
    logic [15:0] adc1, adc2, adc3, adc4, adc7, adc8;
    logic [15:0] adc1_125m, adc2_125m, adc3_125m, adc4_125m, adc7_125m, adc8_125m;

    // Buffering Signals
    logic rst_125m_n, rst_125m, eth_en, start, tick;
    logic [7:0] eth_data;
    logic [7:0] dout1, dout2, dout3, dout4, dout7, dout8;

    logic [3:0] eth_txd;
    logic ETH_TX_EN;
    logic eth_txck;
    logic ETH_PHYRST_N;

    logic eth_rxck;
    logic eth_rxctl;
    logic [3:0] eth_rxd;

    logic [5:0] rd_en, empty, full;

    // Simulation signals
    logic cpu_resetn;

    logic eth_tready;

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

    rstBridge rst_cross_125m
    (
        .clk(clk_125m),
        .asyncrst_n(cpu_resetn),
        .rst_n(rst_125m_n)
    );

    assign rst_125m = ~rst_125m_n;

    rstBridge writeReset
    (
        .clk(adc_clk),
        .asyncrst_n(cpu_resetn),
        .rst_n(adc_rst_n)
    );

    adc_cdc adc1_cdc
    (
        .wr_clk(adc_clk),
        .rd_clk(clk_125m),
        .wr_rst(!adc_rst_n),
        .rd_rst(rst_125m),

        .din(adc1),
        .din_valid(aligned),

        .dout(adc1_125m),
        .dout_valid(adc1_valid)
    );

    adc_cdc adc2_cdc
    (
        .wr_clk(adc_clk),
        .rd_clk(clk_125m),
        .wr_rst(!adc_rst_n),
        .rd_rst(rst_125m),

        .din(adc2),
        .din_valid(aligned),

        .dout(adc2_125m),
        .dout_valid(adc2_valid)
    );

    adc_cdc adc3_cdc
    (
        .wr_clk(adc_clk),
        .rd_clk(clk_125m),
        .wr_rst(!adc_rst_n),
        .rd_rst(rst_125m),

        .din(adc3),
        .din_valid(aligned),

        .dout(adc3_125m),
        .dout_valid(adc3_valid)
    );

    adc_cdc adc4_cdc
    (
        .wr_clk(adc_clk),
        .rd_clk(clk_125m),
        .wr_rst(!adc_rst_n),
        .rd_rst(rst_125m),

        .din(adc4),
        .din_valid(aligned),

        .dout(adc4_125m),
        .dout_valid(adc4_valid)
    );

    adc_cdc adc7_cdc
    (
        .wr_clk(adc_clk),
        .rd_clk(clk_125m),
        .wr_rst(!adc_rst_n),
        .rd_rst(rst_125m),

        .din(adc7),
        .din_valid(aligned),

        .dout(adc7_125m),
        .dout_valid(adc7_valid)
    );

    adc_cdc adc8_cdc
    (
        .wr_clk(adc_clk),
        .rd_clk(clk_125m),
        .wr_rst(!adc_rst_n),
        .rd_rst(rst_125m),

        .din(adc8),
        .din_valid(aligned),

        .dout(adc8_125m),
        .dout_valid(adc8_valid)
    );

    assign start = aligned & tick;

    logic en_wr;
    logic [2:0] addr;

    writeController writeController
    (
        .rstn(rst_125m_n),
        .clk(adc_clk),
        .full(|full),
        .empty(&empty),
        .start(start),
        .wr_en(en_wr),
        .state()
    );

    widthConverter adc1_buffer
    (
        .clk(clk_125m),
        .rst(rst_125m),

        .wr_en(en_wr & adc1_valid),
        .din(adc1_125m),
        .full(full[0]),

        .rd_en(rd_en[0] & eth_tready),
        .dout(dout1),
        .empty(empty[0])
    );

    widthConverter adc2_buffer
    (
        .clk(clk_125m),
        .rst(rst_125m),

        .wr_en(en_wr & adc2_valid),
        .din(adc2_125m),
        .full(full[1]),

        .rd_en(rd_en[1] & eth_tready),
        .dout(dout2),
        .empty(empty[1])
    );

    widthConverter adc3_buffer
    (
        .clk(clk_125m),
        .rst(rst_125m),

        .wr_en(en_wr & adc3_valid),
        .din(adc3_125m),
        .full(full[2]),

        .rd_en(rd_en[2] & eth_tready),
        .dout(dout3),
        .empty(empty[2])
    );

    widthConverter adc4_buffer
    (
        .clk(clk_125m),
        .rst(rst_125m),

        .wr_en(en_wr & adc4_valid),
        .din(adc4_125m),
        .full(full[3]),

        .rd_en(rd_en[3] & eth_tready),
        .dout(dout4),
        .empty(empty[3])
    );

    widthConverter adc7_buffer
    (
        .clk(clk_125m),
        .rst(rst_125m),

        .wr_en(en_wr & adc7_valid),
        .din(adc7_125m),
        .full(full[4]),

        .rd_en(rd_en[4] & eth_tready),
        .dout(dout7),
        .empty(empty[4])
    );

    widthConverter adc8_buffer
    (
        .clk(clk_125m),
        .rst(rst_125m),

        .wr_en(en_wr & adc8_valid),
        .din(adc8_125m),
        .full(full[5]),

        .rd_en(rd_en[5] & eth_tready),
        .dout(dout8),
        .empty(empty[5])
    );

    logic eth_data_tlast, hdr_tvalid, tx_done;

    readController2 readController
    (
        .clk(clk_125m),
        .rstn(rst_125m_n),

        .full(|full),
        .empty(empty),
        .axis_tvalid(eth_en),
        .rd_en(rd_en),
        .addr(addr),
        .tx_done(tx_done),
        .axis_tlast(eth_data_tlast),
        .axis_tready(eth_tready),
        .axis_tvalid_hdr(hdr_tvalid)
    );

    logic m_udp_hdr_valid, m_udp_payload_axis_tvalid, m_udp_payload_axis_tlast, m_udp_payload_axis_tuser;
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
        .tx_udp_payload_axis_tvalid(eth_en),                 // Input
        .tx_udp_payload_axis_tready(eth_tready),                          // Output
        .tx_udp_payload_axis_tlast(eth_data_tlast),             // Input
        .tx_udp_payload_axis_tuser(1'b0),                       // Input
        .s_udp_hdr_valid(hdr_tvalid),

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
        .rx_udp_payload_axis_tuser(m_udp_payload_axis_tuser),   // Output

        /*
         * TX Debug
         */
        .tx_error_underflow(),
        .tx_fifo_overflow(),
        .tx_fifo_bad_frame(),
        .tx_fifo_good_frame(),
        .tx_done(tx_done)
    );

    always_comb begin
        case(addr)
            0:
            begin
                eth_data = dout1;
            end

            1:
            begin
                eth_data = dout2;
            end

            3'b010:
            begin
                eth_data = dout3;
            end

            3'b011:
            begin
                eth_data = dout4;
            end

            3'b100:
            begin
                eth_data = dout7;
            end

            3'b101:
            begin
                eth_data = dout8;
            end

            default:
            begin
                eth_data = 8'b00000000;
            end
        endcase
    end

    initial begin
        SysRefClk_p = 0;
        SysRefClk_n = 1;

        forever begin
            #2.5
            SysRefClk_p = ~SysRefClk_p;
            SysRefClk_n = ~SysRefClk_n;
        end
    end

    initial begin
        adc_clk = 0;

        #4
        forever begin
            #4
            adc_clk = ~adc_clk;
        end
    end

    initial begin
        adc1 = 0;
        adc2 = 0;
        adc3 = 0;
        adc4 = 0;
        adc7 = 0;
        adc8 = 0;
        forever begin
            @(posedge adc_clk);
            adc1 = adc1 + 1;
            adc2 = adc2 + 1;
            adc3 = adc3 + 1;
            adc4 = adc4 + 1;
            adc7 = adc7 + 1;
            adc8 = adc8 + 1;
        end
    end

    initial begin
        cpu_resetn = 0;
        aligned    = 0;
        tick       = 0;
        #16
        cpu_resetn = 1;
        #250
        aligned = 1;
        #200
        tick = 1;
        #16
        tick = 0;
    end

endmodule
