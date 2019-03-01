`timescale 1ns / 1ps

module shiftReg(
	input clk,
	input D,
	output Q
    );

   logic [9:0] SR = 0;

   always @(posedge clk)
      SR  <= {D, SR[9:1]};

   assign Q = SR[0];

endmodule
