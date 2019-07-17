`timescale 1ns / 1ps

module udpDetector
    (
        input logic clk,
        input logic rst,

        input logic [15:0] dest_port,
        input logic [7:0] axis_tdata,
        input logic axis_tvalid,
        input logic axis_tlast,
        input logic rd_en,

        output logic data_ready,
        output logic [31:0] data,
        output logic full,
        output logic empty
    );

logic wr_en, full_i;

assign wr_en = axis_tvalid & (dest_port == 16'h1000) & (full_i == 1'b0) ? 1'b1 : 1'b0;
assign full = full_i;

fifo_generator_1 rxData_i
(
    .clk(clk),         // input wire clk
    .srst(rst),        // input wire srst

    .din(axis_tdata),  // input wire [7 : 0] din
    .wr_en(wr_en),     // input wire wr_en

    .rd_en(rd_en),     // input wire rd_en
    .dout(data),       // output wire [31 : 0] dout

    .full(full_i),     // output wire full
    .empty(empty),     // output wire empty
    .valid(data_ready) // output wire valid
);

endmodule