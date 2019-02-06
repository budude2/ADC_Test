#--------------------------------------------------------------------------------------------
#-   ____  ____
#-  /   /\/   /
#- /___/  \  /
#- \   \   \/    © Copyright 2016 - 2018 Xilinx, Inc. All rights reserved.
#-  \   \        This file contains confidential and proprietary information of Xilinx, Inc.
#-  /   /        and is protected under U.S. and international copyright and other
#- /___/   /\    intellectual property laws.
#- \   \  /
#-  \___\/\___
#-
#--------------------------------------------------------------------------------------------
#- Device:              Ultrascale
#- Author:              Defossez
#- Entity Name:         KC705_AdcToplevel_Toplevel
#- Purpose:             Constraint file for for testing of the Apps hierarchical level
#-                      of design.
#- Tools:               Vivado_2017.3
#- Limitations:         none
#-
#- Vendor:              Xilinx Inc.
#- Version:
#- Filename:            KC705_AdcToplevel_Toplevel.xdc
#- Date Created:        Jan 2016
#- Date Last Modified:  Jan 2016
#--------------------------------------------------------------------------------------------
#- Disclaimer:
#-		This disclaimer is not a license and does not grant any rights to the materials
#-		distributed herewith. Except as otherwise provided in a valid license issued to you
#-		by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE MATERIALS
#-		ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL
#-		WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED
#-		TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR
#-		PURPOSE; and (2) Xilinx shall not be liable (whether in contract or tort, including
#-		negligence, or under any other theory of liability) for any loss or damage of any
#-		kind or nature related to, arising under or in connection with these materials,
#-		including for any direct, or any indirect, special, incidental, or consequential
#-		loss or damage (including loss of data, profits, goodwill, or any type of loss or
#-		damage suffered as a result of any action brought by a third party) even if such
#-		damage or loss was reasonably foreseeable or Xilinx had been advised of the
#-		possibility of the same.
#-
#- CRITICAL APPLICATIONS
#-		Xilinx products are not designed or intended to be fail-safe, or for use in any
#-		application requiring fail-safe performance, such as life-support or safety devices
#-		or systems, Class III medical devices, nuclear facilities, applications related to
#-		the deployment of airbags, or any other applications that could lead to death,
#-		personal injury, or severe property or environmental damage (individually and
#-		collectively, "Critical Applications"). Customer assumes the sole risk and
#-		liability of any use of Xilinx products in Critical Applications, subject only to
#-		applicable laws and regulations governing limitations on product liability.
#-
#- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
#-
#- Contact:    e-mail  hotline@xilinx.com        phone   + 1 800 255 7778
#--------------------------------------------------------------------------------------------
#- Revision History:
#-  Rev. 10 Jan 2016
#-      Changed the original UCF file into an XDC file for use with Vivado.
#--------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
# Timing constraints
#-------------------------------------------------------------------------------------------
# ADC Bit clock input is as sample taken at the FPGA pin as 750MHz.
# 700MHz = 1.333ns = ISERDES.CLK and ISERDES.CLKDIV = 5.333ns = 4xCLK
# For the test application only 2-channels are implemented -- > Reason = Loopback hardware
# testing on Xilinx development board .
# Bit clock input passed though a BUFIO ==> direct/dedicated routing to ISERDES.CLK inputs.
# This path from the package pin to the ISERDES.CLK inputs is routed through an IDELAY,
# BUFIO on dedicated clock nets. Timing cannot improve this and thus this path chould be
# excluded from timing checks.
# Bit clock input passed though BUFR(divide) ==> normal clock routing to ISERDES.CLKDIV.
# This path must be under timing control because the clock is not only used for ISERDES.CLKDIV
# but also for normal clocked logic.
#
#
# Create a clock path for all that has to do with timing of IDELAY updating.
#create_clock -period 5.000 -name SysRefClk -waveform {0.000 2.500} [get_ports SysRefClk_p]
#
# Remove the path from the ADC forwarded clock package pin to all ISERDES.CLK pins from the timing
# engine and timing checking for place&route.
#set_false_path -from [get_ports DCLK_p_pin] -through [get_cells ADC/AdcToplevel_Toplevel_I_AdcToplevel/AdcToplevel_I_AdcClock/AdcClock_I_Isrds_Master] -through [get_cells ADC/AdcToplevel_Toplevel_I_AdcToplevel/AdcToplevel_I_AdcClock/AdcClock_I_Bufio] -to [get_cells -hierarchical *Isrds*]
#
# Create a clock path for the timing engine from the BUFR output to all elements using this clock.
#
#set_false_path -from [get_clocks AdcBitClkDiv] -to [get_clocks AdcBitClk]
#set_false_path -from [get_clocks AdcBitClk] -to [get_clocks AdcBitClk]
#set_false_path -from [get_clocks clk_125m_clk_wiz_0] -to [get_clocks AdcBitClkDiv]
#set_false_path -from [get_clocks AdcBitClkDiv] -to [get_clocks clk_125m_clk_wiz_0]
#set_false_path -from [get_clocks clk_200m_clk_wiz_0] -to [get_clocks AdcBitClkDiv]
#set_false_path -from [get_clocks AdcBitClkDiv] -to [get_clocks clk_200m_clk_wiz_0]
#


create_clock -period 2.000 -name AdcBitClk -waveform {0.000 1.000} [get_ports DCLK_p_pin]
#create_generated_clock -add -name Div -source [get_pins adc_inst/BUFR_inst/O] -divide_by 4 [get_nets -hierarchical *divclk_o*]

#-------------------------------------------------------------------------------------------
# Create and area for the out_of_context design block.
#-------------------------------------------------------------------------------------------
# Command for logic placed with IO_Bank
#
create_pblock Apps_AdcToplevel
add_cells_to_pblock [get_pblocks Apps_AdcToplevel] [get_cells -quiet [list adc_inst]]
resize_pblock [get_pblocks Apps_AdcToplevel] -add {SLICE_X0Y200:SLICE_X7Y249}
#
#-------------------------------------------------------------------------------------------
# Pin LOC constraints

#-------------------------------------------------------------------------------------------
# FMC_LPC_LA28_P   IOSTANDARD=LVCMOS25  VCCO - VADJ_FPGA - IO_L16P_T2_13
# FMC_LPC_LA28_N   IOSTANDARD=LVCMOS25  VCCO - VADJ_FPGA - IO_L16N_T2_13
# FMC_LPC_LA27_P   IOSTANDARD=LVCMOS25  VCCO - VADJ_FPGA - IO_L17P_T2_13
# FMC_LPC_LA27_N   IOSTANDARD=LVCMOS25  VCCO - VADJ_FPGA - IO_L17N_T2_13

#A2
set_property -dict {PACKAGE_pin D29 IOSTANDARD LVDS_25} [get_ports {DATA_p_pin[0]}]
set_property -dict {PACKAGE_pin C30 IOSTANDARD LVDS_25} [get_ports {DATA_n_pin[0]}]
set_property -dict {PACKAGE_pin H30 IOSTANDARD LVDS_25} [get_ports {DATA_p_pin[1]}]
set_property -dict {PACKAGE_pin G30 IOSTANDARD LVDS_25} [get_ports {DATA_n_pin[1]}]

#B2
set_property -dict {PACKAGE_pin F26 IOSTANDARD LVDS_25} [get_ports {DATA_p_pin[2]}]
set_property -dict {PACKAGE_pin E26 IOSTANDARD LVDS_25} [get_ports {DATA_n_pin[2]}]
set_property -dict {PACKAGE_pin A25 IOSTANDARD LVDS_25} [get_ports {DATA_p_pin[3]}]
set_property -dict {PACKAGE_pin A26 IOSTANDARD LVDS_25} [get_ports {DATA_n_pin[3]}]

#D2
set_property -dict {PACKAGE_pin B28 IOSTANDARD LVDS_25} [get_ports {DATA_p_pin[4]}]
set_property -dict {PACKAGE_pin A28 IOSTANDARD LVDS_25} [get_ports {DATA_n_pin[4]}]
set_property -dict {PACKAGE_pin B23 IOSTANDARD LVDS_25} [get_ports {DATA_p_pin[5]}]
set_property -dict {PACKAGE_pin A23 IOSTANDARD LVDS_25} [get_ports {DATA_n_pin[5]}]

#A1
set_property -dict {PACKAGE_pin D26 IOSTANDARD LVDS_25} [get_ports {DATA_p_pin[6]}]
set_property -dict {PACKAGE_pin C26 IOSTANDARD LVDS_25} [get_ports {DATA_n_pin[6]}]
set_property -dict {PACKAGE_pin E29 IOSTANDARD LVDS_25} [get_ports {DATA_p_pin[7]}]
set_property -dict {PACKAGE_pin E30 IOSTANDARD LVDS_25} [get_ports {DATA_n_pin[7]}]

#
# FMC_LPC_LA18_CC_P   IOSTANDARD=LVCMOS25  VCCO - VADJ_FPGA - IO_L11P_T1_SRCC_13
# FMC_LPC_LA18_CC_N   IOSTANDARD=LVCMOS25  VCCO - VADJ_FPGA - IO_L11N_T1_SRCC_13
# FMC_LPC_LA17_CC_P   IOSTANDARD=LVCMOS25  VCCO - VADJ_FPGA - IO_L12P_T1_MRCC_13
# FMC_LPC_LA17_CC_N   IOSTANDARD=LVCMOS25  VCCO - VADJ_FPGA - IO_L12N_T1_MRCC_13
set_property -dict {PACKAGE_pin B30 IOSTANDARD LVDS_25} [get_ports FCLK_p_pin]
set_property -dict {PACKAGE_pin A30 IOSTANDARD LVDS_25} [get_ports FCLK_n_pin]
set_property -dict {PACKAGE_pin D27 IOSTANDARD LVDS_25} [get_ports DCLK_p_pin]
set_property -dict {PACKAGE_pin C27 IOSTANDARD LVDS_25} [get_ports DCLK_n_pin]

## Clock Signal
set_property -dict {PACKAGE_PIN AD11 IOSTANDARD LVDS} [get_ports SysRefClk_n]
set_property -dict {PACKAGE_PIN AD12 IOSTANDARD LVDS} [get_ports SysRefClk_p]

#set_property LOC BUFIO_X0Y17 [get_cells ADC/AdcToplevel_Toplevel_I_AdcToplevel/AdcToplevel_I_AdcClock/AdcClock_I_Bufio]
#set_property LOC ILOGIC_X0Y224 [get_cells ADC/AdcToplevel_Toplevel_I_AdcToplevel/AdcToplevel_I_AdcClock/AdcClock_I_Isrds_Master]
#set_property LOC IDELAY_X0Y224 [get_cells ADC/AdcToplevel_Toplevel_I_AdcToplevel/AdcToplevel_I_AdcClock/AdcClock_I_Iodly]
#
#-------------------------------------------------------------------------------------------
# The end

set_max_delay -datapath_only -from [get_pins enCDC/Q_a_reg/C] -to [get_pins enCDC/D_a_reg/D] 8.000
# set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
# set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
# set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
# connect_debug_port dbg_hub/clk [get_nets adc_clk]
