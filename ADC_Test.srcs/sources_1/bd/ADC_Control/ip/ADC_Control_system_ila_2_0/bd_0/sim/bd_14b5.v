//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_14b5.bd
//Design : bd_14b5
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "bd_14b5,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=bd_14b5,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=SBD,synth_mode=Global}" *) (* HW_HANDOFF = "ADC_Control_system_ila_2_0.hwdef" *) 
module bd_14b5
   (clk,
    probe0);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK, CLK_DOMAIN ADC_Control_clk_wiz_1_0_clk_out1, FREQ_HZ 100000000, PHASE 0.0" *) input clk;
  input [15:0]probe0;

  wire clk_1;
  wire [15:0]probe0_1;

  assign clk_1 = clk;
  assign probe0_1 = probe0[15:0];
  bd_14b5_ila_lib_0 ila_lib
       (.clk(clk_1),
        .probe0(probe0_1));
endmodule
