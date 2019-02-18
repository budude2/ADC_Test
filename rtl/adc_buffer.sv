`timescale 1ns / 1ps

module adc_buffer (
	input logic start_buff,

	input logic din_clk,
	input logic din_rst_n,
	input logic din_valid,

	input logic [15:0] adc1,
	input logic	[15:0] adc2,
    input logic [15:0] adc3,
	input logic [15:0] adc4,
	input logic [15:0] adc8,

	input logic dout_clk,
	input logic dout_rst_n,

	output logic [7:0] dout,
	output logic dout_valid
);
	// Clock domain crossing
	logic adc1_valid, adc2_valid, adc3_valid, adc4_valid, adc8_valid;
	logic [15:0] adc1_125m, adc2_125m, adc3_125m, adc4_125m, adc8_125m;

	// Buffering side
	logic en_wr;
	logic full_adc1, empty_adc1, en_rd1;
	logic full_adc2, empty_adc2, en_rd2;
    logic full_adc3, empty_adc3, en_rd3;
	logic full_adc4, empty_adc4, en_rd4;
	logic full_adc8, empty_adc8, en_rd8;
	logic [2:0] addr;
	logic [7:0] dout1, dout2, dout3, dout4, dout8;

	adc_cdc adc1_cdc
    (
		.wr_clk(din_clk),
		.wr_rst(!din_rst_n),
		.rd_clk(dout_clk),
		.rd_rst(!dout_rst_n),

		.din(adc1),
		.din_valid(din_valid),

		.dout(adc1_125m),
		.dout_valid(adc1_valid)
    );

    adc_cdc adc2_cdc
    (
		.wr_clk(din_clk),
		.wr_rst(!din_rst_n),
		.rd_clk(dout_clk),
		.rd_rst(!dout_rst_n),

		.din(adc2),
		.din_valid(din_valid),

		.dout(adc2_125m),
		.dout_valid(adc2_valid)
    );

    adc_cdc adc3_cdc
    (
        .wr_clk(din_clk),
        .wr_rst(!din_rst_n),
        .rd_clk(dout_clk),
        .rd_rst(!dout_rst_n),

        .din(adc3),
        .din_valid(din_valid),

        .dout(adc3_125m),
        .dout_valid(adc3_valid)
    );

    adc_cdc adc4_cdc
    (
        .wr_clk(din_clk),
        .wr_rst(!din_rst_n),
        .rd_clk(dout_clk),
        .rd_rst(!dout_rst_n),

        .din(adc4),
        .din_valid(din_valid),

        .dout(adc4_125m),
        .dout_valid(adc4_valid)
    );

    adc_cdc adc8_cdc
    (
        .wr_clk(din_clk),
        .wr_rst(!din_rst_n),
        .rd_clk(dout_clk),
        .rd_rst(!dout_rst_n),

        .din(adc8),
        .din_valid(din_valid),

        .dout(adc8_125m),
        .dout_valid(adc8_valid)
    );

    writeController writeController
    (
    	.clk(dout_clk),
        .rstn(dout_rst_n),
        
        .full(full_adc1 | full_adc2 | full_adc2 | full_adc4 | full_adc8),
        .empty(empty_adc1 & empty_adc2 & empty_adc3 & empty_adc4 & empty_adc8),
        .start(start_buff),

        .wr_en(en_wr),
        .state()
    );

    widthConverter adc1_buffer
    (
    	.clk(dout_clk),
        .rst(!dout_rst_n),
        
        .wr_en(en_wr & adc1_valid),
        .din(adc1_125m),
        .full(full_adc1),

        .rd_en(en_rd1),
        .dout(dout1),
        .empty(empty_adc1)
    );

    widthConverter adc2_buffer
    (
    	.clk(dout_clk),
        .rst(!dout_rst_n),

        .wr_en(en_wr & adc2_valid),
        .din(adc2_125m),
        .full(full_adc2),

        .rd_en(en_rd2),
        .dout(dout2),
        .empty(empty_adc2)
    );

    widthConverter adc3_buffer
    (
        .clk(dout_clk),
        .rst(!dout_rst_n),

        .wr_en(en_wr & adc3_valid),
        .din(adc3_125m),
        .full(full_adc3),

        .rd_en(en_rd3),
        .dout(dout3),
        .empty(empty_adc3)
    );

    widthConverter adc4_buffer
    (
        .clk(dout_clk),
        .rst(!dout_rst_n),

        .wr_en(en_wr & adc4_valid),
        .din(adc4_125m),
        .full(full_adc4),

        .rd_en(en_rd4),
        .dout(dout4),
        .empty(empty_adc4)
    );

    widthConverter adc8_buffer
    (
        .clk(dout_clk),
        .rst(!dout_rst_n),

        .wr_en(en_wr & adc8_valid),
        .din(adc8_125m),
        .full(full_adc8),

        .rd_en(en_rd8),
        .dout(dout8),
        .empty(empty_adc8)
    );
    
    readController readController
    (
        .clk(dout_clk),
        .rstn(dout_rst_n),
        
        .full(full_adc1 | full_adc2 | full_adc3 | full_adc4 | full_adc8),

        .empty1(empty_adc1),
        .empty2(empty_adc2),
        .empty3(empty_adc3),
        .empty4(empty_adc4),
        .empty8(empty_adc8),

        .eth_en(dout_valid),
        .rd_en1(en_rd1),
        .rd_en2(en_rd2),
        .rd_en3(en_rd3),
        .rd_en4(en_rd4),
        .rd_en8(en_rd8),

        .addr(addr)
    );

    always_comb begin
    	case(addr)
    		3'b000:
    		begin
    			dout = dout1;
    		end

    		3'b001:
    		begin
    			dout = dout2;
    		end

            3'b010:
            begin
                dout = dout3;
            end

            3'b011:
            begin
                dout = dout4;
            end

            3'b100:
            begin
                dout = dout8;
            end

            default:
            begin
                dout = 8'b00000000;
            end
    	endcase
    end

endmodule