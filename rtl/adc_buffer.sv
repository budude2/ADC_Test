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
    input logic [15:0] adc7,
	input logic [15:0] adc8,

	input logic dout_clk,
	input logic dout_rst_n,

	output logic [7:0] dout,
	output logic dout_valid
);
	// Clock domain crossing
	logic adc1_valid, adc2_valid, adc3_valid, adc4_valid, adc7_valid, adc8_valid;
	logic [15:0] adc1_125m, adc2_125m, adc3_125m, adc4_125m, adc7_125m, adc8_125m;

	// Buffering side
	logic en_wr;
    logic [5:0] empty, rd_en, full;
	logic [2:0] addr;
	logic [7:0] dout1, dout2, dout3, dout4, dout7, dout8;

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

    adc_cdc adc7_cdc
    (
        .wr_clk(din_clk),
        .wr_rst(!din_rst_n),
        .rd_clk(dout_clk),
        .rd_rst(!dout_rst_n),

        .din(adc7),
        .din_valid(din_valid),

        .dout(adc7_125m),
        .dout_valid(adc7_valid)
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

        .full(|full),
        .empty(&empty),
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
        .full(full[0]),

        .rd_en(rd_en[0]),
        .dout(dout1),
        .empty(empty[0])
    );

    widthConverter adc2_buffer
    (
    	.clk(dout_clk),
        .rst(!dout_rst_n),

        .wr_en(en_wr & adc2_valid),
        .din(adc2_125m),
        .full(full[1]),

        .rd_en(rd_en[1]),
        .dout(dout2),
        .empty(empty[1])
    );

    widthConverter adc3_buffer
    (
        .clk(dout_clk),
        .rst(!dout_rst_n),

        .wr_en(en_wr & adc3_valid),
        .din(adc3_125m),
        .full(full[2]),

        .rd_en(rd_en[2]),
        .dout(dout3),
        .empty(empty[2])
    );

    widthConverter adc4_buffer
    (
        .clk(dout_clk),
        .rst(!dout_rst_n),

        .wr_en(en_wr & adc4_valid),
        .din(adc4_125m),
        .full(full[3]),

        .rd_en(rd_en[3]),
        .dout(dout4),
        .empty(empty[3])
    );

    widthConverter adc7_buffer
    (
        .clk(dout_clk),
        .rst(!dout_rst_n),

        .wr_en(en_wr & adc7_valid),
        .din(adc7_125m),
        .full(full[4]),

        .rd_en(rd_en[4]),
        .dout(dout7),
        .empty(empty[4])
    );

    widthConverter adc8_buffer
    (
        .clk(dout_clk),
        .rst(!dout_rst_n),

        .wr_en(en_wr & adc8_valid),
        .din(adc8_125m),
        .full(full[5]),

        .rd_en(rd_en[5]),
        .dout(dout8),
        .empty(empty[5])
    );

    readController readController
    (
        .clk(dout_clk),
        .rstn(dout_rst_n),

        .full(|full),

        .empty(empty),

        .eth_en(dout_valid),
        .rd_en(rd_en),

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
                dout = dout7;
            end

            3'b101:
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