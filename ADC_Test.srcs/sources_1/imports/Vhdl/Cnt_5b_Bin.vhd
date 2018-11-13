-----------------------------------------------------------------------------------------------
-- © Copyright 2009 - 2010, Xilinx, Inc. All rights reserved.
-- This file contains confidential and proprietary information of Xilinx, Inc. and is
-- protected under U.S. and international copyright and other intellectual property laws.
-----------------------------------------------------------------------------------------------
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
-- \   \   \/ 			Version:              
--  \   \        		
--  /   /        		Filename:            Cnt_5b_Bin.vhd
-- /___/   /\    		Date Created:        24 Mar, 2009  
-- \   \  /  \          Date Last Modified:  08 Feb, 2010
--  \___\/\___\
-- 
-- Device:          Virtex-6
-- Author:          defossez
-- Entity Name:     Cnt_5b_Bin
-- Purpose:         Addres counter for a 32-bit LUT memory.
-- Tools:           ISE_11.2.03
-- Limitations:     none
--
-- Revision History:
--	Rev. 08 Feb 2010 
--		File renamed for "AddrCnt_5b_Bin" to "Cnt-5b_Bin" 
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
--
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_UNSIGNED.all;
library UNISIM;
	use UNISIM.vcomponents.all;
---------------------------------------------------------------------------------------------
-- Entity pin description
---------------------------------------------------------------------------------------------
--
---------------------------------------------------------------------------------------------
entity Cnt_5b_Bin is
	port(
		CntClk	: in std_logic;
		CntEna	: in std_logic;
		CntRst	: in std_logic;
		CntOut	: out std_logic_vector(4 downto 0);
		CntTc	: out std_logic
	);
end Cnt_5b_Bin;
---------------------------------------------------------------------------------------------
-- Architecture section
---------------------------------------------------------------------------------------------
architecture Cnt_5b_Bin_struct of Cnt_5b_Bin is
---------------------------------------------------------------------------------------------
-- Component Instantiation
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- Constants, Signals and Attributes Declarations
---------------------------------------------------------------------------------------------
-- Functions
-- Constants
constant Low  : std_logic	:= '0';
constant High : std_logic	:= '1';
-- Signals
signal IntCnt		: std_logic_vector(4 downto 0);
signal IntCntLog	: std_logic_vector(4 downto 0);
signal IntCntTc		: std_logic;
-- Attributes
---------------------------------------------------------------------------------------------
--
begin
-- The FFs of the counter and its logic are written as separate processes.
-- The FFs use now their dedicated inputs for reset and enable (before only the reset
-- was used).
-- The counter process is described as a ROM kind of logic.
-- This could eventually be replaced by instantiating LUT primitives.
-- The counter runs at a speed of: 708 MHz in Virtex-5
--
Cnt_Lut_PROCESS : process (IntCnt)
begin
    BinLog : case IntCnt(4 downto 0) is
        when "00000" => IntCntLog <= "00001";
        when "00001" => IntCntLog <= "00010";
        when "00010" => IntCntLog <= "00011";
        when "00011" => IntCntLog <= "00100";
        when "00100" => IntCntLog <= "00101";
        when "00101" => IntCntLog <= "00110";
        when "00110" => IntCntLog <= "00111";
        when "00111" => IntCntLog <= "01000";
        when "01000" => IntCntLog <= "01001";
        when "01001" => IntCntLog <= "01010";
        when "01010" => IntCntLog <= "01011";
        when "01011" => IntCntLog <= "01100";
        when "01100" => IntCntLog <= "01101";
        when "01101" => IntCntLog <= "01110";
        when "01110" => IntCntLog <= "01111";
        when "01111" => IntCntLog <= "10000";
        when "10000" => IntCntLog <= "10001";
        when "10001" => IntCntLog <= "10010";
        when "10010" => IntCntLog <= "10011";
        when "10011" => IntCntLog <= "10100";
        when "10100" => IntCntLog <= "10101";
        when "10101" => IntCntLog <= "10110";
        when "10110" => IntCntLog <= "10111";
        when "10111" => IntCntLog <= "11000";
        when "11000" => IntCntLog <= "11001";
        when "11001" => IntCntLog <= "11010";
        when "11010" => IntCntLog <= "11011";
        when "11011" => IntCntLog <= "11100";
        when "11100" => IntCntLog <= "11101";
        when "11101" => IntCntLog <= "11110";
        when "11110" => IntCntLog <= "11111";
        -- when "11111" => IntCntLog <= "00000";
		when others => IntCntLog <= "00000";
    end case;
end process;
--
Cnt_Ffs_PROCESS : process (CntClk, CntRst, CntEna)
begin
    if (CntClk'EVENT and CntClk = '1') then
        if (CntRst = '1') then
            IntCnt <= (others => '0');
            CntTc <= '0';
        elsif (CntEna = '1') then
            IntCnt <= IntCntLog;
            CntTc <= IntCntTc;
        end if; 
   	end if;
end process;
--
IntCntTc <= '1' when (IntCnt(4 downto 0) = "11110") else '0';
CntOut <= IntCnt;
--
---------------------------------------------------------------------------------------------
end Cnt_5b_Bin_struct;
