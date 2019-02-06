`timescale 1ns / 1ps

module simpleCDC(
	input logic sourceClk,
	input logic destClk,
	input logic d_in,
	output logic d_out
    );

	logic Q_a;
    (* ASYNC_REG="TRUE" *) logic D_a, D_b;

    always_ff @(posedge sourceClk) begin
    	Q_a <= d_in;
    end

    always_ff @(posedge destClk) begin
         D_a <= Q_a;
         D_b <= D_a;
    end

    assign d_out = D_b;
endmodule
