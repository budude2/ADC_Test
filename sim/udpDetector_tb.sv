`timescale 1ns / 1ps

module udpDetector_tb
    (

    );

    logic clk_125m, rst_125m;
    logic [15:0] dest_port = 0;
    logic [7:0] axis_tdata = 0;
    logic axis_tvalid = 0;
    logic axis_tlast = 0;;
    logic rd_en = 0;
    logic data_ready;
    logic [31:0] data;
    logic full;
    logic empty;

    udpDetector udpDetector_i
    (
        .clk(clk_125m),
        .rst(rst_125m),

        .dest_port(dest_port),
        .axis_tdata(axis_tdata),
        .axis_tvalid(axis_tvalid),
        .axis_tlast(axis_tlast),
        .rd_en(rd_en),

        .data_ready(data_ready),
        .data(data),
        .full(full),
        .empty(empty)
    );

    initial begin
        clk_125m = 0;

        forever begin
            #4
            clk_125m = ~clk_125m;
        end
    end

    initial begin
        rst_125m = 1;
        repeat(15) @(posedge clk_125m);
        rst_125m = 0;
        repeat(15) @(posedge clk_125m);
        dest_port   = 16'h1000;
        axis_tvalid = 1'b1;
        axis_tdata  = 8'hde;
        #8
        axis_tdata  = 8'had;
        #8
        axis_tdata  = 8'hbe;
        #8
        axis_tdata  = 8'hef;
        axis_tlast  = 1'b1;
        #8
        axis_tdata  = 8'h00;
        axis_tvalid = 1'b0;
        axis_tlast  = 1'b0;
        #32
        rd_en = 1'b1;
        #8
        rd_en = 1'b0;
    end

endmodule
