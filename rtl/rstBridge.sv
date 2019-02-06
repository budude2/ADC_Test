`timescale 1ns / 1ps

module rstBridge(
	input logic asyncrst_n,
	input logic clk,
	output logic rst_n
	);

logic rff1;

always_ff@(posedge clk, posedge asyncrst_n) begin
	if (asyncrst_n == 0) begin
    	rff1  <= 0;
    	rst_n <= 0;
    end
  	else begin
    	rff1  <= 1;
    	rst_n <= rff1;
  	end
end
endmodule