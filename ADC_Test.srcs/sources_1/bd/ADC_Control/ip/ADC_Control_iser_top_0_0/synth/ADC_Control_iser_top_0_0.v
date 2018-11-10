// (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:iser_top:1.0
// IP Revision: 1

(* X_CORE_INFO = "iser_top,Vivado 2018.2" *)
(* CHECK_LICENSE_TYPE = "ADC_Control_iser_top_0_0,iser_top,{}" *)
(* CORE_GENERATION_INFO = "ADC_Control_iser_top_0_0,iser_top,{x_ipProduct=Vivado 2018.2,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=iser_top,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED}" *)
(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module ADC_Control_iser_top_0_0 (
  iser_chan_a,
  iser_chan_c,
  iser_chan_e,
  iser_chan_g,
  fco_clk,
  fco_clk_rdy,
  data_clk,
  data_clk_rdy,
  din_fco_p,
  din_fco_n,
  din_a_p,
  din_a_n,
  din_b_p,
  din_b_n,
  din_c_p,
  din_c_n,
  din_d_p,
  din_d_n,
  din_e_p,
  din_e_n,
  din_f_p,
  din_f_n,
  din_g_p,
  din_g_n,
  din_h_p,
  din_h_n,
  din_rst_n,
  sel_2lane,
  sel_num_bits
);

output wire [15 : 0] iser_chan_a;
output wire [15 : 0] iser_chan_c;
output wire [15 : 0] iser_chan_e;
output wire [15 : 0] iser_chan_g;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME fco_clk, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN ADC_Control_iser_top_0_0_fco_clk" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 fco_clk CLK" *)
output wire fco_clk;
output wire fco_clk_rdy;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME data_clk, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN ADC_Control_data_clock_ctrl_0_0_data_clk" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 data_clk CLK" *)
input wire data_clk;
input wire data_clk_rdy;
input wire din_fco_p;
input wire din_fco_n;
input wire din_a_p;
input wire din_a_n;
input wire din_b_p;
input wire din_b_n;
input wire din_c_p;
input wire din_c_n;
input wire din_d_p;
input wire din_d_n;
input wire din_e_p;
input wire din_e_n;
input wire din_f_p;
input wire din_f_n;
input wire din_g_p;
input wire din_g_n;
input wire din_h_p;
input wire din_h_n;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME din_rst_n, POLARITY ACTIVE_LOW" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 din_rst_n RST" *)
input wire din_rst_n;
input wire sel_2lane;
input wire sel_num_bits;

  iser_top inst (
    .iser_chan_a(iser_chan_a),
    .iser_chan_c(iser_chan_c),
    .iser_chan_e(iser_chan_e),
    .iser_chan_g(iser_chan_g),
    .fco_clk(fco_clk),
    .fco_clk_rdy(fco_clk_rdy),
    .data_clk(data_clk),
    .data_clk_rdy(data_clk_rdy),
    .din_fco_p(din_fco_p),
    .din_fco_n(din_fco_n),
    .din_a_p(din_a_p),
    .din_a_n(din_a_n),
    .din_b_p(din_b_p),
    .din_b_n(din_b_n),
    .din_c_p(din_c_p),
    .din_c_n(din_c_n),
    .din_d_p(din_d_p),
    .din_d_n(din_d_n),
    .din_e_p(din_e_p),
    .din_e_n(din_e_n),
    .din_f_p(din_f_p),
    .din_f_n(din_f_n),
    .din_g_p(din_g_p),
    .din_g_n(din_g_n),
    .din_h_p(din_h_p),
    .din_h_n(din_h_n),
    .din_rst_n(din_rst_n),
    .sel_2lane(sel_2lane),
    .sel_num_bits(sel_num_bits)
  );
endmodule
