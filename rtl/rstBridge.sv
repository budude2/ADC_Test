`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/05/2019 02:28:33 PM
// Design Name: 
// Module Name: rstBridge
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rstBridge(
	input logic asyncrst_n,
	input logic clk,
	output logic rst_n
	);

logic asyncrst_n, rst_n, rff1;

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