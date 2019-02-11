`timescale 1ns / 1ps

module bufferTB( );

    logic clk_125m, clk_125m90, adc_clk, cpu_resetn, aligned, tx_valid, udp_busy;
	logic full_wr, empty_wr, en_wr, en_rd, empty_rd, full_rd, eth_en, wr_rst_n, rd_rst_n;
    logic ETH_PHYRST_N, eth_txck, ETH_TX_EN;
    logic [15:0] adc1;
    logic [7:0] eth_data;
    logic [3:0] eth_txd;

    rstBridge writeReset
    (
        .clk(adc_clk),
        .asyncrst_n(cpu_resetn),
        .rst_n(wr_rst_n)
    );

    rstBridge readReset
    (
        .clk(clk_125m),
        .asyncrst_n(cpu_resetn),
        .rst_n(rd_rst_n)
    );

    writeController writeController
    (
        .clk(adc_clk),
        .rstn(wr_rst_n),
        .full(full_wr),
        .empty(empty_wr),
        .start(aligned),
        .wr_en(en_wr),
        .state()
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
        .rd_en(en_rd & !udp_busy),
        .dout(eth_data),
        .empty(empty_rd),
        .rd_full(full_rd),    // Full flag in rd_clk domain
        .valid(tx_valid)
    );

    readController readController
    (
        .clk(clk_125m),
        .rstn(rd_rst_n),
        .full(full_rd),
        .empty(empty_rd),
        .eth_en(eth_en),
        .rd_en(en_rd),
        .state()
    );

    udp_tx_top udp_tx
    (
        .clk_125m(clk_125m),
        .clk_125m90(clk_125m90),

        .udp_tx_valid(tx_valid & eth_en & !udp_busy),
        .udp_tx_data(eth_data),
        .udp_tx_busy(udp_busy),

        .eth_txd(eth_txd),
        .ETH_TX_EN(ETH_TX_EN),
        .eth_txck(eth_txck),
        .ETH_PHYRST_N(ETH_PHYRST_N)
    );


    initial begin
        clk_125m = 0;

        forever begin
            #4
            clk_125m = ~clk_125m;
        end
    end

    initial begin
        clk_125m90 = 0;
        #2

        forever begin
            #4
            clk_125m90 = ~clk_125m90;
        end
    end

    initial begin
        adc_clk = 0;
        #1.5

        forever begin
            #4
            adc_clk = ~adc_clk;
        end
    end

    initial begin
        adc1 = 0;

        #32
        forever begin
            #8
            adc1 = adc1 + 1;
        end
    end

    initial begin
        cpu_resetn = 0;
        aligned    = 0;
        #16

        cpu_resetn = 1;

        #16

        aligned = 1;
    end

endmodule
