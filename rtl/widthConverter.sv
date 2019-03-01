`timescale 1ns / 1ps

module widthConverter
    (
        input logic         clk,
        input  logic        rst,

        input  logic        wr_en,
        input  logic [15:0] din,
        output logic        full,

        input  logic        rd_en,
        output logic [7:0]  dout,
        output logic        empty
    );

fifo_generator_0 fifo (
  .clk(clk),      // input wire clk
  .srst(rst),    // input wire srst
  .din(din),      // input wire [15 : 0] din
  .wr_en(wr_en),  // input wire wr_en
  .rd_en(rd_en),  // input wire rd_en
  .dout(dout),    // output wire [7 : 0] dout
  .full(full),    // output wire full
  .empty(empty)  // output wire empty
);

endmodule
