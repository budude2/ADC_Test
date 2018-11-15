---------------------------------------------------------------------------------------------
-- © Copyright 2012, Xilinx, Inc. All rights reserved.
-- This file contains confidential and proprietary information of Xilinx, Inc. and is
-- protected under U.S. and international copyright and other intellectual property laws.
---------------------------------------------------------------------------------------------
--
-- Disclaimer:
--		This disclaimer is not a license and does not grant any rights to the materials
--		distributed herewith. Except as otherwise provided in a valid license issued to you
--		by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE MATERIALS
--		ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL
--		WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED
--		TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR
--		PURPOSE; and (2) Xilinx shall not be liable (whether in contract or tort, including
--		negligence, or under any other theory of liability) for any loss or damage of any
--		kind or nature related to, arising under or in connection with these materials,
--		including for any direct, or any indirect, special, incidental, or consequential
--		loss or damage (including loss of data, profits, goodwill, or any type of loss or
--		damage suffered as a result of any action brought by a third party) even if such
--		damage or loss was reasonably foreseeable or Xilinx had been advised of the
--		possibility of the same.
--
-- CRITICAL APPLICATIONS
--		Xilinx products are not designed or intended to be fail-safe, or for use in any
--		application requiring fail-safe performance, such as life-support or safety devices
--		or systems, Class III medical devices, nuclear facilities, applications related to
--		the deployment of airbags, or any other applications that could lead to death,
--		personal injury, or severe property or environmental damage (individually and
--		collectively, "Critical Applications"). Customer assumes the sole risk and
--		liability of any use of Xilinx products in Critical Applications, subject only to
--		applicable laws and regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
--
--		Contact:    e-mail  hotline@xilinx.com        phone   + 1 800 255 7778
--   ____  ____
--  /   /\/   /
-- /___/  \  / 			Vendor:              Xilinx Inc.
-- \   \   \/ 			Version:             V0.02
--  \   \        		Filename:            AdcToplevel_Toplevel.vhd
--  /   /        		Date Created:        18 February, 2011
-- /___/   /\    		Date Last Modified:  24 July, 2012
-- \   \  /  \
--  \___\/\___\
--
-- Device:          7-Series
-- Author:          defossez
-- Entity Name:     AdcToplevel_Toplevel
-- Purpose:         File for implementation test purposes of teh AdcToplevel design.
-- Tools:           Vivado_2017.3 or later
-- Limitations:     none
--
-- Revision History:
--	Rev.
--
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
---------------------------------------------------------------------------------------------
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_UNSIGNED.all;
library UNISIM;
	use UNISIM.vcomponents.all;
library xil_defaultlib;
    use xil_defaultlib.all;
---------------------------------------------------------------------------------------------
-- Entity pin description
---------------------------------------------------------------------------------------------
entity AdcToplevel_Toplevel is
    generic (
        C_OnChipLvdsTerm        : integer := 1;     -- 0 = No Term, 1 - Termination ON.
        C_AdcChnls              : integer := 4;     -- Number of ADC in a package
        C_AdcWireInt            : integer := 2;     -- 2 = 2-wire, 1 = 1-wire interface
        C_BufioLoc              : string := "BUFIO_X0Y16";
        C_BufrLoc               : string := "BUFR_X0Y16";
        C_AdcBits               : integer := 16;
        C_StatTaps              : integer := 16;
        C_AdcUseIdlyCtrl        : integer := 1;      -- 0 = No, 1 = Yes
        C_AdcIdlyCtrlLoc        : string  := "IDELAYCTRL_X0Y4";
        C_FrmPattern            : string  := "0000000011110000"  -- "1111111100000000"
                                          -- 2-Wire, 16-bit      -- 1-wire, 16-bit
                                          --
                                          -- "111111000000"      -- "000000111000"
    );                                    -- 1-wire, 12-bit      -- 2-wire, 12-bit
    port (
        DCLK_p_pin              : in std_logic;
        DCLK_n_pin              : in std_logic;
        FCLK_p_pin              : in std_logic;
        FCLK_n_pin              : in std_logic;
        DATA_p_pin              : in std_logic_vector((C_AdcChnls*C_AdcWireInt)-1 downto 0);
        DATA_n_pin              : in std_logic_vector((C_AdcChnls*C_AdcWireInt)-1 downto 0);
        -- application connections
        SysRefClk               : in std_logic;      -- 200 MHz for IODELAYCTRL from application
        AdcIntrfcRst            : in std_logic;
        AdcIntrfcEna            : in std_logic;
        AdcReSync               : in std_logic;
        AdcFrmSyncWrn           : out std_logic;
        AdcBitClkAlgnWrn        : out std_logic;
        AdcBitClkInvrtd         : out std_logic;
        AdcBitClkDone           : out std_logic;
        AdcIdlyCtrlRdy          : out std_logic;
            -- Data from the frame clock
        AdcFrmDataOut           : out std_logic_vector(15 downto 0);
            -- ADC memory data output
        AdcMemClk               : in std_logic; -- Application clock
        AdcMemRst               : in std_logic; -- Application reset
        AdcMemEna               : in std_logic; -- Application Enable
        AdcMemDataOut           : out std_logic_vector(((32/C_AdcWireInt)*((C_AdcChnls/2)*C_AdcWireInt))-1 downto 0);
        AdcMemFlags             : out std_logic_vector((4*((C_AdcChnls/2)*C_AdcWireInt))-1 downto 0);
        AdcMemFull              : out std_logic_vector(((C_AdcChnls/2)*C_AdcWireInt)-1 downto 0);
        AdcMemEmpty             : out std_logic_vector(((C_AdcChnls/2)*C_AdcWireInt)-1 downto 0);
        debug_bitslip_p         : out std_logic;
        debug_bitslip_n         : out std_logic
	);
end AdcToplevel_Toplevel;
---------------------------------------------------------------------------------------------
-- Architecture section
---------------------------------------------------------------------------------------------
architecture AdcToplevel_Toplevel_struct of AdcToplevel_Toplevel is
---------------------------------------------------------------------------------------------
-- Component Instantiation
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- Constants, Signals and Attributes Declarations
---------------------------------------------------------------------------------------------
-- Functions
function ConvTrueFalse (Term : integer) return boolean is
begin
    if (Term = 0) then
        return FALSE;
    else
        return TRUE;
    end if;
end ConvTrueFalse;
-- Constants
constant Low  : std_logic	:= '0';
constant High : std_logic	:= '1';
-- Signals
signal IntDCLK_p : std_logic;
signal IntDCLK_n : std_logic;
signal IntFCLK_p : std_logic;
signal IntFCLK_n : std_logic;
signal IntDATA_p : std_logic_vector((C_AdcChnls*C_AdcWireInt)-1 downto 0);
signal IntDATA_n : std_logic_vector((C_AdcChnls*C_AdcWireInt)-1 downto 0);
-- Attributes
---------------------------------------------------------------------------------------------
begin
--
AdcToplevel_Toplevel_I_Ibufgds_BitClk : IBUFGDS
    generic map (DIFF_TERM  => ConvTrueFalse(C_OnChipLvdsTerm), IOSTANDARD  => "LVDS_25")
    port map (I => DCLK_p_pin, IB => DCLK_n_pin, O => IntDCLK_p);
IntDCLK_n <= Low;
--
AdcToplevel_Toplevel_I_Ibufds_FrmClk : IBUFDS_DIFF_OUT
    generic map (IOSTANDARD => "LVDS_25", DIFF_TERM => ConvTrueFalse(C_OnChipLvdsTerm))
    port map (I => FCLK_p_pin, IB => FCLK_n_pin, O => IntFCLK_p, OB => IntFCLK_n);
--
Gen_1 : for n in (C_AdcChnls*C_AdcWireInt)-1 downto 0 generate
    AdcToplevel_Toplevel_I_Ibufds_DI_0_0 : IBUFDS_DIFF_OUT
        generic map (IOSTANDARD => "LVDS_25", DIFF_TERM => ConvTrueFalse(C_OnChipLvdsTerm))
        port map (I => DATA_p_pin(n), IB => DATA_n_pin(n), O => IntDATA_p(n), OB => IntDATA_n(n));
end generate Gen_1;
---------------------------------------------------------------------------------------------
AdcToplevel_Toplevel_I_AdcToplevel : entity xil_defaultlib.AdcToplevel
    generic map(
        C_AdcChnls          => C_AdcChnls,
        C_AdcWireInt        => C_AdcWireInt,
        C_BufioLoc          => C_BufioLoc,
        C_BufrLoc           => C_BufrLoc,
        C_AdcBits           => C_AdcBits,
        C_StatTaps          => C_StatTaps,
        C_AdcUseIdlyCtrl    => C_AdcUseIdlyCtrl,
        C_AdcIdlyCtrlLoc    => C_AdcIdlyCtrlLoc,
		C_FrmPattern	    => C_FrmPattern
    )
    port map (
        DCLK_p             => IntDCLK_p, -- in
        DCLK_n             => IntDCLK_n, -- in
        FCLK_p             => IntFCLK_p, -- in
        FCLK_n             => IntFCLK_n, -- in
        DATA_p             => IntDATA_p, -- in
        DATA_n             => IntDATA_n, -- in
        -- application connections
        SysRefClk          => SysRefClk, -- in
        AdcIntrfcRst       => AdcIntrfcRst, -- in
        AdcIntrfcEna       => AdcIntrfcEna, -- in
        AdcReSync          => AdcReSync, -- in
        AdcFrmSyncWrn      => AdcFrmSyncWrn, -- out
        AdcBitClkAlgnWrn   => AdcBitClkAlgnWrn, -- out
        AdcBitClkInvrtd    => AdcBitClkInvrtd, -- out
        AdcBitClkDone      => AdcBitClkDone, -- out
        AdcIdlyCtrlRdy     => AdcIdlyCtrlRdy, -- out
            -- Data from the frame clock
        AdcFrmDataOut      => AdcFrmDataOut, -- out
            -- ADC memory data output
        AdcMemClk          => AdcMemClk, -- in
        AdcMemRst          => AdcMemRst, -- in
        AdcMemEna          => AdcMemEna, -- in
        AdcMemDataOut      => AdcMemDataOut, -- out
        AdcMemFlags        => AdcMemFlags, -- out
        AdcMemFull         => AdcMemFull, -- out
        AdcMemEmpty        => AdcMemEmpty, -- out
        debug_bitslip_n    => debug_bitslip_n,
        debug_bitslip_p    => debug_bitslip_p
    );
---------------------------------------------------------------------------------------------
--
---------------------------------------------------------------------------------------------
end AdcToplevel_Toplevel_struct;
