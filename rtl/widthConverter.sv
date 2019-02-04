`timescale 1ns / 1ps

module widthConverter
    (
        input  logic        rst,

        input  logic        wr_clk,
        input  logic        wr_en,
        input  logic [15:0] din,
        output logic        full,
        output logic        wr_empty,
        output logic        wr_rst_busy,

        input  logic        rd_clk,
        input  logic        rd_en,
        output logic [7:0]  dout,
        output logic        empty,
        output logic        rd_full,
        output logic        rd_rst_busy
    );

    fifo_generator_0 fifo
    (
      .rst(rst),                  // input wire rst
      .wr_clk(wr_clk),            // input wire wr_clk
      .rd_clk(rd_clk),            // input wire rd_clk
      .din(din),                  // input wire [15 : 0] din
      .wr_en(wr_en),              // input wire wr_en
      .rd_en(rd_en),              // input wire rd_en
      .dout(dout),                // output wire [7 : 0] dout
      .full(full),                // output wire full
      .empty(empty),              // output wire empty
      .wr_rst_busy(wr_rst_busy),  // output wire wr_rst_busy
      .rd_rst_busy(rd_rst_busy)   // output wire rd_rst_busy
    );

    (* ASYNC_REG="TRUE" *) logic wr_empty0, wr_empty1;

    always_ff @(posedge wr_clk) begin
        wr_empty0 <= empty;
        wr_empty1 <= wr_empty0;
    end

    assign wr_empty = wr_empty1;

    (* ASYNC_REG="TRUE" *) logic rd_full0, rd_full1;

    always_ff @(posedge rd_clk) begin
         rd_full0 <= full;
         rd_full1 <= rd_full0;
    end
    
    assign rd_full = rd_full1;

endmodule
