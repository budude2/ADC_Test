//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_d414_wrapper.bd
//Design : bd_d414_wrapper
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module bd_d414_wrapper
   (clk,
    probe0);
  input clk;
  input [0:0]probe0;

  wire clk;
  wire [0:0]probe0;

  bd_d414 bd_d414_i
       (.clk(clk),
        .probe0(probe0));
endmodule
