`timescale 1ns / 1ps

module adc_cdc(
    input logic wr_clk,
    input logic rd_clk,
    input logic wr_rst,
    input logic rd_rst,

    input logic [15:0] din,
    input logic din_valid,

    output logic [15:0] dout,
    output logic dout_valid
    );

logic valid;

adc_fifo FIFO (
    .wr_clk(wr_clk),  // input wire wr_clk
    .wr_rst(wr_rst),  // input wire wr_rst
    .rd_clk(rd_clk),  // input wire rd_clk
    .rd_rst(rd_rst),  // input wire rd_rst
    .din(din),        // input wire [15 : 0] din
    .wr_en(din_valid),    // input wire wr_en
    .rd_en(valid),    // input wire rd_en
    .dout(dout),      // output wire [15 : 0] dout
    .full(full),      // output wire full
    .empty(empty),    // output wire empty
    .valid(valid)
);

assign dout_valid = valid;

endmodule
