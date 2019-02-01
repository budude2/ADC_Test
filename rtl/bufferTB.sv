`timescale 1ns / 1ps

module bufferTB( );

    logic clk_125m, adc_clk, cpu_resetn, aligned, wr_rst_busy, rd_rst_busy;
	logic full_wr, empty_wr, en_wr, en_rd, empty_rd, full_rd, eth_en;
    logic [15:0] adc1;
    logic [7:0] eth_data;

    controller writeController
    (
        .clk(adc_clk),
        .rstn(cpu_resetn),
        .full(full_wr),
        .empty(empty_wr),
        .start(aligned),
        .fifo_rst(wr_rst_busy | rd_rst_busy),
        .wr_en(en_wr)
    );

    widthConverter adc1_buffer
    (
        .rst(!cpu_resetn),

        .wr_clk(adc_clk),
        .wr_en(en_wr),
        .din(adc1),
        .full(full_wr),
        .wr_empty(empty_wr),    // Empty flag in wr_clk domain
        .wr_rst_busy(wr_rst_busy),

        .rd_clk(clk_125m),
        .rd_en(en_rd),
        .dout(eth_data),
        .empty(empty_rd),
        .rd_full(full_rd),     // Full flag in rd_clk domain
        .rd_rst_busy(rd_rst_busy)
    );

    readController readController
    (
        .clk(clk_125m),
        .rstn(cpu_resetn),
        .full(full_rd),
        .empty(empty_rd),
        .fifo_rst(wr_rst_busy | rd_rst_busy),
        .eth_en(eth_en),
        .rd_en(en_rd)
    );


    initial begin
        clk_125m = 0;

        forever begin
            #4
            clk_125m = ~clk_125m;
        end
    end

    initial begin
        adc_clk = 1;

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
