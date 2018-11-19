-----------------------------------------------------------------------------------------------
-- � Copyright 2012, Xilinx, Inc. All rights reserved.
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
-- /___/  \  /   Vendor:    Xilinx
-- \   \   \/    Version:   V0.02
--  \   \        Filename:  AdcFrame.vhd
--  /   /        Date Last Modified:	25 May 18
-- /___/   /\    Date Created: 			05 Oct 07
-- \   \  /  \
--  \___\/\___\
--
-- Device:		7-Series
-- Author:		Marc Defossez
-- Entity Name: AdcFrame
-- Purpose:		This file is part of an FPGA interface for a Texas Instruments ADC.
-- Tools:		Vivado_2017.3 or later or later
-- Limitations: none
--
-- Revision History:
--  Jan  2016
--      Adapted for 12-bit, 1-wire.
--      Double nibble detect was only suitable for 14 and 16 bits.
--      Made it work for 12-bits too.
-- May 2018
--      - Changed the bitslip counter limit.
--      - Made it really slip 8-bits, before it could only slip 7-bits due to slip counter
--      - limitations.
--      - Changed behavior of re-sync after bitslip counter went out of range.
--      - Resync is now a full reset of the design.
--      - This makes the design clean and robust.
---------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------------
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_UNSIGNED.all;
	use IEEE.std_logic_textio.all;
	use std.textio.all;
library UNISIM;
	use UNISIM.VCOMPONENTS.all;
library Common;
    use Common.all;
library AdcFrame_lib;
    use AdcFrame_lib.all;
-----------------------------------------------------------------------------------------------
-- Entity pin description
-----------------------------------------------------------------------------------------------
entity AdcFrame is
	generic (
		C_AdcBits			: integer;
		C_AdcWireInt		: integer;
		C_FrmPattern		: string
	);
    port (
        FrmClk_n		: in std_logic;		-- input n from IBUFDS_DIFF_OUT
        FrmClk_p		: in std_logic;		-- input p from IBUFDS_DIFF_OUT
        FrmClkRst		: in std_logic;
        FrmClkEna		: in std_logic;
        FrmClk			: in std_logic;
        FrmClkDiv		: in std_logic;
        FrmClkDone		: in std_logic;		-- Input from clock syncronisation.
        FrmClkReSync	: in std_logic;
        FrmClkBitSlip_p	: out std_logic;
        FrmClkBitSlip_n	: out std_logic;
        FrmClkSwapMux	: out std_logic;
        FrmClkMsbRegEna	: out std_logic;
        FrmClkLsbRegEna	: out std_logic;
        FrmClkReSyncOut	: out std_logic;
		FrmClkDat		: out std_logic_vector(15 downto 0);
        FrmClkSyncWarn	: out std_logic
    );
end AdcFrame;
-----------------------------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------------------------
architecture AdcFrame_struct of AdcFrame  is
-----------------------------------------------------------------------------------------------
-- Component Instantiation
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- Constants, Signals and Attributes Declarations
-----------------------------------------------------------------------------------------------
-- Functions
-- A std_logic_vector is converted to a string.
	function stdlvec_to_str(inp: std_logic_vector) return string is
	variable temp: string(inp'left+1 downto 1) := (others => 'X');
	begin
		for i in inp'reverse_range loop
			if (inp(i) = '1') then
				temp(i+1) := '1';
			elsif (inp(i) = '0') then
				temp(i+1) := '0';
			end if;
		end loop;
	return temp;
	end function stdlvec_to_str;
--
-- A string is converted to a std_logic_vector.
	function str_to_stdlvec(Inp: string) return std_logic_vector is
	variable Temp : std_logic_vector(Inp'range) := (others => 'X');
	begin
		for i in Inp'range loop
			if (Inp(i) = '1') then
				Temp(i) := '1';
			elsif (Inp(i) = '0') then
				Temp(i) := '0';
			end if;
		end loop;
	return Temp;
	end function str_to_stdlvec;
--
-- In two wire mode a 12 bit ADC has 2 channels of 6 bits. The AdcBits stay at 12.
-- In two wire mode a 14 bit ADC has 2 channels of 8 bits. The AdcBits is set at 16.
-- In two wire mode a 16 bit ADC has 2 channels of 8 bits. The AdcBits stay at 16.
	function FrmBits (Bits : integer) return integer is
	variable Temp : integer;
	begin
		if (Bits = 12) then
			Temp := 12;
		elsif (Bits = 14) then
			Temp := 16;
		elsif (Bits = 16) then
			Temp := 16;
		end if;
	return Temp;
	end function FrmBits;
--
-- Word symmetry check
-- A word (16-bit) is checked for bit pair symmetry
-- Example: In one byte there are 16 possible symmetry positions.
-- 			00000000, 00000011, 00001100, 00001111,
-- 			00110000, 00110011, 00111100, 00111111,
-- 			11000000, 11000011, 11001100, 11001111,
-- 			11110000, 11110011, 11111100, 11111111,
-- Bit_7=Bit_6, Bit_5=Bit_4, Bit_3=Bit_2, and Bit_1=Bit_0
	function SymChck (Inp: std_logic_vector) return std_logic is
	variable Temp : std_logic_vector((Inp'left-1)/2 downto 0) := (others => '0');
	variable Sym : std_logic := '0';
	begin
		for n in (Inp'left-1)/2 downto 0 loop
			Temp(n) := Inp((n*2)+1) xor Inp(n*2);
			Sym := Temp(n) or Sym;
		end loop;
		assert false
		report CR & " Pattern XORed/ORed = " & stdlvec_to_str(Temp) & CR
		severity note;
	return Sym;
	end function SymChck;
--
-- When a symmetric byte, bit pattern is found, make the requested pattern rotate
-- by one bit to become a non-symmetric pattern.
	function BitShft(Inp: std_logic_vector; Wire: integer) return std_logic_vector is
	variable Temp : std_logic_vector(Inp'range):= (others => '0');
	begin
-- Bit shift all bits.
-- Example: 16-bit frame word = 11111111_00000000 or 00000000_11110000
-- After shifting the word returned looks as: 11111110_00000001 and 00000000_01111000
		if (SymChck(Inp) = '0') then
			if (Wire = 1 ) then		-- 1-wire, shift 15-bits
				for n in Inp'left downto 0 loop
					if (n /= 0) then
						Temp(n) := Inp(n-1);
					elsif (n = 0) then
						Temp(Temp'right) := Inp(Inp'left);
					end if;
				end loop;
			else -- (Wire = 2)		-- 2-wire, shift 8-bits
				for n in (Inp'left-8) downto 0 loop
					if (n /= 0) then
						Temp(n) := Inp(n-1);
					elsif (n = 0) then
						Temp(Temp'right) := Inp(Inp'left-8);
					end if;
				end loop;
			end if;
		elsif (SymChck(Inp) = '1') then
		-- Don't do anything, return the word as it came in.
			Temp := Inp;
		end if;
		--
		assert false
		report	CR &
				" Pattern Shifted = " & stdlvec_to_str(Temp) & CR &
				" Comparator Value A = " & stdlvec_to_str(Temp(15 downto 8)) & CR &
				" Comparator Value B = " & stdlvec_to_str(Temp(7 downto 0)) & CR
		severity note;
	return Temp;
	end function BitShft;
--
-- Bit swap operation:
-- Bit n of the output string gets bit n-1 of the input. ex: out(7) <= In(6).
-- Bit n-1 of the output string gets bit n of the input. ex: out(6) <= In(7).
-- Bit n-2 of the output string gets bit n-3 of the input. ex: out(5) <= In(4).
-- Bit n-3 of the output string gets bit n-2 of the input. ex: out(4) <= In(5).
-- and etcetera....
-- This:		Bit_7, Bit_6, Bit_5, Bit_4, Bit_3, Bit_2, Bit_1, Bit_0.
-- Results in:	Bit_6, Bit_7, Bit-4, Bit_5, Bit_2, Bit_3, Bit_0, Bit_1.
	function BitSwap(Inp: std_logic_vector) return std_logic_vector is
	variable Temp : std_logic_vector(Inp'range);
	begin
		for n in (Inp'left-1)/2 downto 0 loop
			Temp((n*2)+1) := Inp(n*2);
			Temp(n*2) := Inp((n*2)+1);
		end loop;
		assert false
		report CR &
				" Pattern Bit Swapped = " & stdlvec_to_str(Temp) & CR &
				" Comparator Value C = " & stdlvec_to_str(Temp(15 downto 8)) & CR &
				" Comparator Value D = " & stdlvec_to_str(Temp(7 downto 0))	& CR
		severity note;
	return Temp;
	end function BitSwap;
--
	function ConvTrueFalse (Term : integer) return boolean is
	begin
		if (Term = 0) then
			return FALSE;
		else
			return TRUE;
		end if;
	end ConvTrueFalse;
--
-- Constants
-- Transform the pattern STRING into a std_logic_vector.
constant IntPattern	:
		std_logic_vector(FrmBits(C_AdcBits)-1 downto 0)	:= str_to_stdlvec(C_FrmPattern);
-- Shift the pattern for one bit.
constant IntPatternBitShifted :
		std_logic_vector(FrmBits(C_AdcBits)-1 downto 0)	:= BitShft(IntPattern, C_AdcWireInt);
-- Bit swap the by one bit shifted pattern.
constant IntPatternBitSwapped :
		std_logic_vector(FrmBits(C_AdcBits)-1 downto 0)	:= BitSwap(IntPatternBitShifted);
--
-- This is what all the above stuff does:
-- The C_FrmPattern string given at the entity level is transformed into a std_logic_vector.
-- This is done by a function std_tostdvec and the result is a constant IntPattern.
--
-- The IntPattern and given wire interface are then passed to a function Bitshift en result
-- in a constant IntPatternBitShifted.
-- Bitshift shifts the given, transformed to std_logic_vector, one bit to the right.
-- Example: 16-bit frame word = 11111111_00000000 or 00000000_11110000
-- After shifting the word returned looks as: 11111110_00000001 and 00000000_01111000.
--
-- IntPatternBitSwapped is the result of a function called BitSwap.
-- BitSwap swaps every pair of bits of the IntPatternBitShifted constant
-- Like this:
-- This:		Bit_7, Bit_6, Bit_5, Bit_4, Bit_3, Bit_2, Bit_1, Bit_0.
-- Results in:	Bit_6, Bit_7, Bit-4, Bit_5, Bit_2, Bit_3, Bit_0, Bit_1.
--
-- If this is given at the entity level:
--		C_AdcBits			: 12
--		C_AdcWireInt		: 1
--		C_FrmPattern		: 111111000000
-- Thus from the above we have:
--      IntPattern:             111111000000 (nothing displayed in log file)
--      IntPatternBitShifted:   111110000001
--                                  Things displayed in log file
--                                  Pattern XORed/ORed (from a function called SymCheck)
--                                  Pattern Shifted
--                                  Comparator Value A
--                                  Comparator Value B
--       IntPatternBitSwapped:  111101000010
--                                  Things displayed in log file:
--                                  Pattern Bit Swapped
--                                  Comparator Value C
--                                  Comparator Value D
--
-- Then the constants "IntPatternA, B, C, D" are created.
-- Define the bytes for pattern comparison.
constant IntPatternA : std_logic_vector((FrmBits(C_AdcBits)/2)-1 downto 0) :=
		IntPatternBitShifted(FrmBits(C_AdcBits)-1 downto FrmBits(C_AdcBits)/2);
constant IntPatternB : std_logic_vector((FrmBits(C_AdcBits)/2)-1 downto 0) :=
		IntPatternBitShifted((FrmBits(C_AdcBits)/2)-1 downto 0);
constant IntPatternC : std_logic_vector((FrmBits(C_AdcBits)/2)-1 downto 0) :=
		IntPatternBitSwapped(FrmBits(C_AdcBits)-1 downto FrmBits(C_AdcBits)/2);
constant IntPatternD : std_logic_vector((FrmBits(C_AdcBits)/2)-1 downto 0) :=
		IntPatternBitSwapped((FrmBits(C_AdcBits)/2)-1 downto 0);
-- IntPatternA[5:0] = IntPatternBitShifted[11:6]
-- IntPatternB(5:0) = IntPatternBitShifted[5:0]
-- IntPatternC[5:0] = IntPatternBitSwapped[11:6]
-- IntPatternD[5:0] = IntPatternBitSwapped[5:0]
--
-- This constant is the output of the function FrmBits.
-- Its 12 when C_AdcBits is set to 12 and it is 16 when C_AdcBits is 14 or 16.
constant Cnst_C_AdcBits : integer := FrmBits(C_AdcBits);
--
-- Calculate the data width for a ISERDES.
-- The function FrmBits returns 12 when the ADC is set the 12 bit (C_AdcBits)
-- The function FrmBits returns 16 when the ADC is set to 14 or 16 bit resolution.
-- The constant "IntIsrdsDataWidth" gets the value 3 when ADC resolution is 12 and
-- gets 4 when the ADC resolution is set, output of FrmBits function) to 16.
--
constant IntIsrdsDataWidth : integer := FrmBits(C_AdcBits)/4;
constant Low : std_logic := '0';
constant High : std_logic := '1';
-- Signals
signal IntFrmClk			        : std_logic;
signal IntFrmClk_n			        : std_logic;
signal IntFrmClkRst			        : std_logic;
signal IntFrmSrdsOut		        : std_logic_vector(7 downto 0);
--
signal IntFrmSrdsDatEvn		        : std_logic_vector((FrmBits(C_AdcBits)/4)-1 downto 0);
signal IntFrmSrdsDatOdd             : std_logic_vector((FrmBits(C_AdcBits)/4)-1 downto 0);
signal IntFrmSrdsDatEvn_d           : std_logic_vector((FrmBits(C_AdcBits)/4)-1 downto 0);
signal IntFrmSrdsDatOdd_d           : std_logic_vector((FrmBits(C_AdcBits)/4)-1 downto 0);
signal IntFrmSrdsDat                : std_logic_vector((FrmBits(C_AdcBits)/2)-1 downto 0);
signal IntFrmDat			        : std_logic_vector((FrmBits(C_AdcBits)/2)-1 downto 0);
signal IntFrmDatMux                 : std_logic_vector((FrmBits(C_AdcBits)/2)-1 downto 0);
signal IntFrmDatSwp			        : std_logic_vector((FrmBits(C_AdcBits)/2)-1 downto 0);
signal IntFrmDatSwpBus              : std_logic_vector(15 downto 0);
signal IntFrmClkDat			        : std_logic_vector(15 downto 0);
--
signal IntFrmDbleNibFnlEvn          : std_logic;
signal IntFrmDbleNibFnlEvn_d        : std_logic;
signal IntFrmDbleNibFnlOdd          : std_logic;
signal IntFrmDbleNibFnlOdd_d        : std_logic;
signal IntFrmDbleNibFnl		        : std_logic;
--
signal IntFrmEna			        : std_logic;
signal IntFrmCmp			        : std_logic_vector(3 downto 0);
signal IntFrmEquGte			        : std_logic;
signal IntFrmEqu_d			        : std_logic;
signal IntFrmSwapMux_d		        : std_logic;
signal IntFrmSwapMux_d_Ena          : std_logic;
signal IntFrmLsbMsb_d 		        : std_logic;
signal IntFrmLsbMsb_d_Ena           : std_logic;
signal IntFrmMsbAllZero_d 	        : std_logic;
signal IntFrmMsbAllZero_d_Ena       : std_logic;
--
signal IntFrmRegEna_d		        : std_logic;
signal IntFrmMsbRegEna_d	        : std_logic;
signal IntFrmLsbRegEna_d	        : std_logic;
--
signal IntFrmEvntCnt		        : std_logic_vector(3 downto 0); -- count event counter
signal IntFrmEvntCntTc		        : std_logic;
signal IntFrmEvntCntTc_d	        : std_logic;
signal IntFrmSlipCnt		        : std_logic_vector(4 downto 0); -- count to 32
signal IntFrmSlipCntTc		        : std_logic;
signal IntFrmSlipCntTc_d1           : std_logic;
signal IntFrmSlipCntTc_d	        : std_logic;
signal IntFrmSlipCntTc_d2Ena        : std_logic;
signal IntFrmSlipCntTc_d2           : std_logic;
signal IntFrmWarnCnt		        : std_logic_vector(2 downto 0);
signal IntFrmWarnCntTc		        : std_logic;
signal IntFrmWarnCntTc_d	        : std_logic;
signal IntFrmClkReSync              : std_logic;
signal IntFrmReSyncOut  		    : std_logic;
signal IntFrmReSyncOut_d		    : std_logic;
--
signal IntFrmBitSlip		        : std_logic_vector(5 downto 0);
signal IntFrmEquSet_d		        : std_Logic;
-- Attributes
attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of AdcFrame_struct : architecture is "YES";
-----------------------------------------------------------------------------------------------
begin
-----------------------------------------------------------------------------------------------
-- ISERDES FOR FRAME CAPTURE
-----------------------------------------------------------------------------------------------
IntFrmClk <= FrmClk;
--IntFrmClk_n <= not FrmClk;
-- Above is commented because the ISERDESE2 has a generic IS_CLK_INVERTED set to '1'.
-- The CLK clock is inverted inside the ISERDESE2.
--
AdcFrame_I_Isrds_p : ISERDESE2
	generic map (
		SERDES_MODE         => "MASTER",            -- string
        INTERFACE_TYPE      => "NETWORKING",        -- string
        IOBDELAY            => "NONE",              -- string
        DATA_RATE           => "SDR",               -- string
        DATA_WIDTH          => IntIsrdsDataWidth,   -- integer <-- Number of bits
        DYN_CLKDIV_INV_EN   => "FALSE",             -- string
        DYN_CLK_INV_EN      => "FALSE",             -- string
        NUM_CE              => 1,                   -- integer
        OFB_USED            => "FALSE",             -- string
        INIT_Q1             => '0',                 -- bit;
        INIT_Q2             => '0',                 -- bit;
        INIT_Q3             => '0',                 -- bit;
        INIT_Q4             => '0',                 -- bit;
        SRVAL_Q1            => '0',                 -- bit;
        SRVAL_Q2            => '0',                 -- bit;
        SRVAL_Q3            => '0',                 -- bit;
        SRVAL_Q4            => '0',                 -- bit
        IS_CLKB_INVERTED    => '0',                 -- CLKB clock input is NOT inverted
        IS_CLKDIVP_INVERTED => '0',                 -- CLKDIVP input is NOT inverted
        IS_CLKDIV_INVERTED  => '0',                 -- CLKDIV clock input is NOT inverted
        IS_CLK_INVERTED     => '0',                 -- CLK clock input is NOT inverted
        IS_D_INVERTED       => '0',                 -- D (data) input is NOT inverted
        IS_OCLKB_INVERTED   => '0',                 -- OCLKB clock input is NOT inverted
        IS_OCLK_INVERTED    => '0'                  -- OCLK clock input is NOT inverted
	)
	port map (
		D				    => FrmClk_p,		    -- in
		DDLY			    => Low,				    -- in
		OFB				    => Low, 			    -- in
		BITSLIP			    => IntFrmBitSlip(0),    -- in
		CE1				    => IntFrmEna,      	    -- in
		CE2				    => Low,				    -- in
		RST				    => IntFrmClkRst,        -- in
		CLK				    => IntFrmClk,	 	    -- in
		CLKB			    => Low, 			    -- in
		CLKDIV			    => FrmClkDiv,	 	    -- in
        CLKDIVP             => Low,                 -- in
        OCLK			    => Low, 			    -- in
        OCLKB               => Low,                 -- in
		DYNCLKDIVSEL	    => Low, 			    -- in
		DYNCLKSEL		    => Low, 			    -- in
        SHIFTOUT1		    => open,	 		    -- out
		SHIFTOUT2		    => open, 			    -- out
		O				    => open, 			    -- out
		Q1				    => IntFrmSrdsOut(6),    -- out	(0)
		Q2				    => IntFrmSrdsOut(4),    -- out	(2)
		Q3				    => IntFrmSrdsOut(2),    -- out	(4)
		Q4				    => IntFrmSrdsOut(0),    -- out	(6)
		Q5				    => open,	 		    -- out
		Q6				    => open, 			    -- out
        Q7                  => open,                -- out
        Q8                  => open,                -- out
		SHIFTIN1		    => Low, 			    -- in
		SHIFTIN2		    => Low				    -- in
	);
--
AdcFrame_I_Isrds_n : ISERDESE2
	generic map (
        SERDES_MODE         => "MASTER",            -- string
        INTERFACE_TYPE      => "NETWORKING",        -- string
        IOBDELAY            => "NONE",              -- string
        DATA_RATE           => "SDR",               -- string
        DATA_WIDTH          => IntIsrdsDataWidth,   -- integer 12-bit = 3 and 14/16 b its = 4
        DYN_CLKDIV_INV_EN   => "FALSE",             -- string
        DYN_CLK_INV_EN      => "FALSE",             -- string
        NUM_CE              => 1,                   -- integer
        OFB_USED            => "FALSE",             -- string
        INIT_Q1             => '0',                 -- bit;
        INIT_Q2             => '0',                 -- bit;
        INIT_Q3             => '0',                 -- bit;
        INIT_Q4             => '0',                 -- bit;
        SRVAL_Q1            => '0',                 -- bit;
        SRVAL_Q2            => '0',                 -- bit;
        SRVAL_Q3            => '0',                 -- bit;
        SRVAL_Q4            => '0',                 -- bit;
        IS_CLKB_INVERTED    => '0',                 -- CLKB clock input is NOT inverted
        IS_CLKDIVP_INVERTED => '0',                 -- CLKDIVP input is NOT inverted
        IS_CLKDIV_INVERTED  => '0',                 -- CLKDIV clock input is NOT inverted
        IS_CLK_INVERTED     => '1',                 -- CLK clock input IS INVERTED
        IS_D_INVERTED       => '0',                 -- D (data) input is NOT inverted
        IS_OCLKB_INVERTED   => '0',                 -- OCLKB clock input is NOT inverted
        IS_OCLK_INVERTED    => '0'                  -- OCLK clock input is NOT inverted
	)
	port map (
		D				    => FrmClk_n,		    -- in
		DDLY			    => Low,				    -- in
		OFB				    => Low, 			    -- in
		BITSLIP			    => IntFrmBitSlip(1),    -- in
		CE1				    => IntFrmEna,      	    -- in
		CE2				    => Low,				    -- in
		RST				    => IntFrmClkRst,	    -- in
		CLK				    => IntFrmClk,	 	    -- in
		CLKB			    => Low, 			    -- in
		CLKDIV			    => FrmClkDiv,	 	    -- in
        CLKDIVP             => Low,                 -- in
		OCLK			    => Low, 			    -- in
        OCLKB               => Low,                 -- in
		DYNCLKDIVSEL	    => Low, 			    -- in
		DYNCLKSEL		    => Low, 			    -- in
		SHIFTOUT1		    => open,	 		    -- out
		SHIFTOUT2		    => open, 			    -- out
		O				    => open, 			    -- out
		Q1				    => IntFrmSrdsOut(7),    -- out	(1)
		Q2				    => IntFrmSrdsOut(5),    -- out	(3)
		Q3				    => IntFrmSrdsOut(3),    -- out	(5)
		Q4				    => IntFrmSrdsOut(1),    -- out	(7)
		Q5				    => open,	 		    -- out
		Q6				    => open, 			    -- out
        Q7                  => open,                -- out
        Q8                  => open,                -- out
		SHIFTIN1		    => Low, 			    -- in
		SHIFTIN2		    => Low				    -- in
	);
-----------------------------------------------------------------------------------------------
-- INVERT THE NEEDED BITS.
-----------------------------------------------------------------------------------------------
Gen_1_FrmBus : if (FrmBits(C_AdcBits)/2) = 6 generate
-- 12-bit single wire. Only three meaningful bits.
	IntFrmSrdsDatEvn <= IntFrmSrdsOut(4) & IntFrmSrdsOut(2) & IntFrmSrdsOut(0);
	IntFrmSrdsDatOdd <= not IntFrmSrdsOut(5) & not IntFrmSrdsOut(3) & not IntFrmSrdsOut(1);
end generate Gen_1_FrmBus;
Gen_2_FrmBus : if (FrmBits(C_AdcBits)/2) = 8 generate
-- 14 and 16-bit single wire, all four bits are taken in account.
	IntFrmSrdsDatEvn <= IntFrmSrdsOut(6) & IntFrmSrdsOut(4) &
	                    IntFrmSrdsOut(2) & IntFrmSrdsOut(0);
    IntFrmSrdsDatOdd <= not IntFrmSrdsOut(7) & not IntFrmSrdsOut(5) &
                        not IntFrmSrdsOut(3) & not IntFrmSrdsOut(1);
end generate Gen_2_FrmBus;
-----------------------------------------------------------------------------------------------
-- Double Nibble Detection.
-- When the ADC is used in 1-wire mode the frame pattern is 12 or 16 bits long.
-- It is captured in two ISERDES. One running at rising CLK and the other running at falling
-- CLK. after a number of bitslips a ISERDES can output twice the same nibble of data.
-- This phenomenon is called "Double Nibble" and as written before happens after a
-- Bitslip request.
-- The output of each ISERDES is first checked for these double nibbles and if needed the
-- ISERDES output is corrected. After that the data is passed into the frame pattern
-- Recognition part of the design.
-----------------------------------------------------------------------------------------------
Gen_1_DbleNibChk : if (C_AdcWireInt = 1) generate
    AdcFrame_I_DblNbblDtct_Evn : entity AdcFrame_lib.DoubleNibbleDetect
        generic map (C_AdcBits => Cnst_C_AdcBits) -- enter only 16 or 12 (14 is turned into 16).
        port map (
            Clock   => FrmClkDiv, -- in
            RstIn   => IntFrmClkRst, -- in
            Final   => IntFrmDbleNibFnlEvn, -- out
            DataIn  => IntFrmSrdsDatEvn, -- in 14/16=[3:0], 12=[2:0]
            DataOut => IntFrmSrdsDatEvn_d  -- out 14/16=[3:0], 12=[2:0]
        );
--
    AdcFrame_I_DblNbblDtct_Odd : entity AdcFrame_lib.DoubleNibbleDetect
        generic map (C_AdcBits => C_AdcBits)
        port map (
            Clock   => FrmClkDiv, -- in
            RstIn   => IntFrmClkRst, -- in
            Final   => IntFrmDbleNibFnlOdd, -- out
            DataIn  => IntFrmSrdsDatOdd, -- in 14/16=[3:0], 12=[2:0]
            DataOut => IntFrmSrdsDatOdd_d  -- out 14/16=[3:0], 12=[2:0]
        );
--
    AdcFrame_DblNibFnl_PROCESS : process (FrmClkDiv, IntFrmClkRst)
    begin
        if (IntFrmClkRst = '1') then
            IntFrmDbleNibFnlOdd_d <= '0';
            IntFrmDbleNibFnlEvn_d <= '0';
        elsif (FrmClkDiv'event and FrmClkDiv = '1') then
            if (IntFrmDbleNibFnlOdd = '1') then
                IntFrmDbleNibFnlOdd_d <= '1';
            else --(IntFrmDbleNibFnlOdd = '0')
                IntFrmDbleNibFnlOdd_d <= '0';
            end if;
            if (IntFrmDbleNibFnlEvn = '1') then
                IntFrmDbleNibFnlEvn_d <= '1';
            else --(IntFrmDbleNibFnlOdd = '0')
                IntFrmDbleNibFnlEvn_d <= '0';
            end if;
        end if;
    end process AdcFrame_DblNibFnl_PROCESS;
--
    IntFrmDbleNibFnl <= IntFrmDbleNibFnlOdd_d and IntFrmDbleNibFnlEvn_d;
end generate Gen_1_DbleNibChk;
--
Gen_2_DbleNibChk : if (C_AdcWireInt = 2) generate
    IntFrmSrdsDatEvn_d <= IntFrmSrdsDatEvn;
    IntFrmSrdsDatOdd_d <= IntFrmSrdsDatOdd;
    IntFrmDbleNibFnl <= Low;
end generate Gen_2_DbleNibChk;
-----------------------------------------------------------------------------------------------
-- DATA REGISTER
-----------------------------------------------------------------------------------------------
Gen_1_DatBus : for n in (FrmBits(C_AdcBits)/4) downto 1 generate
    IntFrmSrdsDat((n*2)-1) <= IntFrmSrdsDatOdd_d(n-1);
    IntFrmSrdsDat((n*2)-2) <= IntFrmSrdsDatEvn_d(n-1);
end generate Gen_1_DatBus;
--
Gen_1_DatReg : for n in (FrmBits(C_AdcBits)/2)-1 downto 0 generate
    AdcFrame_I_Fdce_Reg1 : FDCE
        generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
        port map(D => IntFrmSrdsDat(n), CE => IntFrmEna, C => FrmClkDiv,
                 CLR => IntFrmClkRst, Q => IntFrmDat(n));
end generate Gen_1_DatReg;
-----------------------------------------------------------------------------------------------
-- BIT SWAP MULTIPLEXER and REGISTER
-- Swap the bits in correct order when the pattern detected is bit swapped.
-----------------------------------------------------------------------------------------------
Gen_2_DatMux : for n in (FrmBits(C_AdcBits)/4)-1 downto 0 generate
begin
    IntFrmDatMux((n*2)+1) <= IntFrmDat(n*2)     when (IntFrmSwapMux_d = '1') else IntFrmDat((n*2)+1);
    IntFrmDatMux(n*2)     <= IntFrmDat((n*2)+1) when (IntFrmSwapMux_d = '1') else IntFrmDat(n*2);
end generate Gen_2_DatMux;
Gen_3_DatReg : for n in (FrmBits(C_AdcBits)/2)-1 downto 0 generate
    AdcFrame_I_Fdce_Reg2 : FDCE
        generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
        port map (D => IntFrmDatMux(n), C => FrmClkDiv, CE => IntFrmEna, CLR => IntFrmClkRst,
                  Q => IntFrmDatSwp(n));
end generate Gen_3_DatReg;
-----------------------------------------------------------------------------------------------
-- FRAME OUTPUT REGISTERS
-----------------------------------------------------------------------------------------------
Gen_4_OutReg12 : if C_AdcBits = 12 generate
    IntFrmDatSwpBus <= "0000" &
                       IntFrmDatSwp(5) & IntFrmDatSwp(4) &
                       IntFrmDatSwp(3) & IntFrmDatSwp(2) &
                       IntFrmDatSwp(1) & IntFrmDatSwp(0) &
                       IntFrmDatSwp(5) & IntFrmDatSwp(4) &
                       IntFrmDatSwp(3) & IntFrmDatSwp(2) &
                       IntFrmDatSwp(1) & IntFrmDatSwp(0);
    Gen_4_H : for n in 6 to 15 generate
        AdcFrame_I_Fdce_FrmClkDatMsb : FDCE
        generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
        port map (D => IntFrmDatSwpBus(n), CE => IntFrmMsbRegEna_d, C => FrmClkDiv,
                CLR => IntFrmClkRst, Q => IntFrmClkDat(n));
    end generate Gen_4_H;
    Gen_4_L : for n in 0 to 5 generate
        AdcFrame_I_Fdce_FrmClkDatLsb : FDCE
        generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
        port map (D => IntFrmDatSwpBus(n), CE => IntFrmLsbRegEna_d, C => FrmClkDiv,
                CLR => IntFrmClkRst, Q => IntFrmClkDat(n));
    end generate Gen_4_L;
end generate Gen_4_OutReg12;
--
Gen_5_OutReg12n : if C_AdcBits /= 12 generate
    IntFrmDatSwpBus <= IntFrmDatSwp(7) & IntFrmDatSwp(6) &
                       IntFrmDatSwp(5) & IntFrmDatSwp(4) &
                       IntFrmDatSwp(3) & IntFrmDatSwp(2) &
                       IntFrmDatSwp(1) & IntFrmDatSwp(0) &
                       IntFrmDatSwp(7) & IntFrmDatSwp(6) &
                       IntFrmDatSwp(5) & IntFrmDatSwp(4) &
                       IntFrmDatSwp(3) & IntFrmDatSwp(2) &
                       IntFrmDatSwp(1) & IntFrmDatSwp(0);
    Gen_5_H : for n in 8 to 15 generate
        AdcFrame_I_Fdce_FrmClkDatMsb : FDCE
        generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
        port map (D => IntFrmDatSwpBus(n), CE => IntFrmMsbRegEna_d, C => FrmClkDiv,
                CLR => IntFrmClkRst, Q => IntFrmClkDat(n));
    end generate Gen_5_H;
    Gen_5_L : for n in 0 to 7 generate
        AdcFrame_I_Fdce_FrmClkDatLsb : FDCE
        generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
        port map (D => IntFrmDatSwpBus(n), CE => IntFrmLsbRegEna_d, C => FrmClkDiv,
                CLR => IntFrmClkRst, Q => IntFrmClkDat(n));
    end generate Gen_5_L;
end generate Gen_5_OutReg12n;
--
FrmClkDat <= IntFrmClkDat;
-----------------------------------------------------------------------------------------------
-- FRAME PATTERN COMPARATOR
-----------------------------------------------------------------------------------------------
IntFrmCmp(2 downto 0) <= "101" when (IntFrmSrdsDat = IntPatternA) else	-- Equ, 	, Msb
						 "100" when (IntFrmSrdsDat = IntPatternB) else	-- Equ, 	, Lsb
						 "111" when (IntFrmSrdsDat = IntPatternC) else	-- Equ, swpd, Msb
						 "110" when (IntFrmSrdsDat = IntPatternD) else	-- Equ, Swpd, Lsb
						 "000";
IntFrmCmp(3) <= High when (C_AdcWireInt = 2) else Low; -- Msb = all zero
--
-- When "Equ" goes high, one of the four patterns has been found.
-- The other two signals will reflect (Msb or Lsb, bitswapped or not) what pattern has been
-- found. WHen "Equ" thus goes high, store the status of all signals and make sure it can't
-- be changed.
--
--IntFrmEquGte <= (IntFrmCmp(2) or IntFrmEqu_d) and IntFrmEna;

IntFrmEquGte <= IntFrmCmp(2) and IntFrmEna;
--
AdcFrame_I_Fdce_FrmMsbAllZero_d : FDCE
    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
    port map (D => IntFrmCmp(3), CE => IntFrmMsbAllZero_d_Ena, C => FrmClkDiv,
              CLR => IntFrmClkRst, Q => IntFrmMsbAllZero_d);
AdcFrame_I_Fdce_FrmEqu_d : FDCE
    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
    port map (D => IntFrmEquGte, CE => High, C => FrmClkDiv,
              CLR => IntFrmClkRst, Q => IntFrmEqu_d);
AdcFrame_I_Fdce_FrmSwapMux_d : FDCE
    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
    port map (D => IntFrmCmp(1), CE => IntFrmSwapMux_d_Ena, C => FrmClkDiv,
              CLR => IntFrmClkRst, Q => IntFrmSwapMux_d);
AdcFrame_I_Fdce_FrmLsbMsb_d : FDCE
    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
    port map (D => IntFrmCmp(0), CE => IntFrmLsbMsb_d_Ena, C => FrmClkDiv,
              CLR => IntFrmClkRst, Q => IntFrmLsbMsb_d);
--
IntFrmMsbAllZero_d_Ena <= IntFrmCmp(2) and not IntFrmEqu_d;
IntFrmSwapMux_d_Ena <= IntFrmCmp(2)and not IntFrmEqu_d;
IntFrmLsbMsb_d_Ena <= IntFrmCmp(2) and not IntFrmEqu_d;
FrmClkSwapMux <= IntFrmSwapMux_d;
-----------------------------------------------------------------------------------------------
-- OUTPUT REGISTER ENABLER
-----------------------------------------------------------------------------------------------
AdcFrame_EnaSel_PROCESS : process (FrmClkDiv, IntFrmMsbAllZero_d, IntFrmEqu_d)
subtype IntFrmRegEnaCase is std_logic_vector(4 downto 0);
begin
	if (IntFrmMsbAllZero_d = High) then
		IntFrmRegEna_d <= Low;
		IntFrmMsbRegEna_d <= High;
		IntFrmLsbRegEna_d <= High;
	elsif (FrmClkDiv'event and FrmClkDiv = '1') then
		case IntFrmRegEnaCase'(IntFrmLsbMsb_d, IntFrmEqu_d, IntFrmRegEna_d,
									IntFrmMsbRegEna_d, IntFrmLsbRegEna_d) is
			when "00001" =>	IntFrmRegEna_d <= '0';
							IntFrmMsbRegEna_d <= '0'; -- A
							IntFrmLsbRegEna_d <= '1'; --
			when "01001" =>	IntFrmRegEna_d <= '1';
							IntFrmMsbRegEna_d <= '0'; -- B
							IntFrmLsbRegEna_d <= '1'; --
			when "01101" =>	IntFrmRegEna_d <= '1';
							IntFrmMsbRegEna_d <= '1'; -- C
							IntFrmLsbRegEna_d <= '0'; --
			when "01110" =>	IntFrmRegEna_d <= '1';
							IntFrmMsbRegEna_d <= '0'; -- D, goto C
							IntFrmLsbRegEna_d <= '1'; --
			--
			when "11001" =>	IntFrmRegEna_d <= '1';
							IntFrmMsbRegEna_d <= '1'; -- E
							IntFrmLsbRegEna_d <= '0'; --
			when "11110" =>	IntFrmRegEna_d <= '1';
							IntFrmMsbRegEna_d <= '0'; -- F
							IntFrmLsbRegEna_d <= '1'; --
			when "11101" =>	IntFrmRegEna_d <= '1';
							IntFrmMsbRegEna_d <= '1'; -- G, goto F
							IntFrmLsbRegEna_d <= '0'; --
			--
			when others =>	IntFrmRegEna_d <= '0';
							IntFrmMsbRegEna_d <= '0';
							IntFrmLsbRegEna_d <= '1';
		end case;
	end if;
end process;
FrmClkMsbRegEna <= IntFrmMsbRegEna_d;
FrmClkLsbRegEna <= IntFrmLsbRegEna_d;
-----------------------------------------------------------------------------------------------
-- SAMPLE EVENT COUNTER
-- Take a frame sample every 16 ClkDiv cycles.
-----------------------------------------------------------------------------------------------
AdcFrame_EvntCnt_PROCESS : process (FrmClkDiv, IntFrmClkRst,
                                    IntFrmEquSet_d, IntFrmEna)
begin
	if (IntFrmClkRst = High) then
		IntFrmEvntCnt <= (others => '0');
		IntFrmEvntCntTc_d <= Low;
	elsif (FrmClkDiv'event and FrmClkDiv = '1') then
		if (IntFrmEquSet_d = Low and IntFrmEna = High) then
			IntFrmEvntCnt <= IntFrmEvntCnt + "01";
			IntFrmEvntCntTc_d <= IntFrmEvntCntTc;
		end if;
	end if;
end process;
IntFrmEvntCntTc <= High when (IntFrmEvntCnt = "1110") else Low;
--IntFrmEvntCntTc <= High when (IntFrmEvntCnt = ((2**IntFrmEvntCnt'length)-2)) else Low;
-----------------------------------------------------------------------------------------------
-- BITSLIP EVENT COUNTER
-- Bitslip 8 times for a 8-bit ISERDES and 6 times for a 6-bit ISERDES.
-----------------------------------------------------------------------------------------------
AdcFrame_SlipCnt_PROCESS : process (FrmClkDiv, IntFrmClkRst,
                                    IntFrmEvntCntTc_d, IntFrmSlipCntTc)
begin
	if (IntFrmClkRst = High) then
		IntFrmSlipCnt <= (others => '0');
        IntFrmSlipCntTc_d <= Low;
	elsif (FrmClkDiv'event and FrmClkDiv = '1') then
		if (IntFrmEvntCntTc_d = High) then
			IntFrmSlipCnt <= IntFrmSlipCnt + "01";
		end if;
        IntFrmSlipCntTc_d <= IntFrmSlipCntTc;
		--if (IntFrmEvntCntTc_d = High and IntFrmSlipCntTc = High) then
		--	IntFrmSlipCntTc_d <= High;
		--else
		--	IntFrmSlipCntTc_d <= Low;
		--end if;
	end if;
end process;
-- Terminal count trip points.
-- Single LVDS channel and 12-bit resolution, count 12
AdcFrame_SlipCntTc_1_12 : if (C_AdcWireInt = 1 and FrmBits(C_AdcBits) = 12) generate
	IntFrmSlipCntTc <= High when (IntFrmSlipCnt = "01100") else Low; -- 12 or X'C'
end generate;
-- Dual LVDS channel and 12-bit resolution, count 6
AdcFrame_SlipCntTc_2_12 : if (C_AdcWireInt = 2 and FrmBits(C_AdcBits) = 12) generate
	IntFrmSlipCntTc <= High when (IntFrmSlipCnt = "00110") else Low; -- 6
end generate;
-- Single LVDS channel and 16-bit resolution, count 16.
AdcFrame_SlipCntTc_1_16 : if (C_AdcWireInt = 1 and FrmBits(C_AdcBits) = 16) generate
	IntFrmSlipCntTc <= High when (IntFrmSlipCnt = "10000") else Low; -- 16 or X'10'
end generate;
-- Dual LVDS channel and 16-bit resolution, count 8
AdcFrame_SlipCntTc_2_16 : if (C_AdcWireInt = 2 and FrmBits(C_AdcBits) = 16) generate
	IntFrmSlipCntTc <= High when (IntFrmSlipCnt = "01001") else Low; -- 8
end generate;
--
AdcFrame_I_Fdce_SlipCntTc_1 : FDCE
    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
    port map (D => High, CE => IntFrmSlipCntTc_d, C => FrmClkDiv,
              CLR => IntFrmSlipCntTc_d2, Q => IntFrmSlipCntTc_d1);
--
IntFrmSlipCntTc_d2Ena <= IntFrmSlipCntTc_d and IntFrmSlipCntTc_d1;
--
AdcFrame_I_Fdce_SlipCntTc_2 : FDCE
    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
    port map (D => IntFrmSlipCntTc_d2Ena, CE => High, C => FrmClkDiv,
              CLR => IntFrmClkRst, Q => IntFrmSlipCntTc_d2);
-----------------------------------------------------------------------------------------------
-- WARNING EVENT COUNTER
-- When this counter issues terminal count, synchronisation was impossible for 8 times.
-----------------------------------------------------------------------------------------------
AdcFrame_WarnCnt_PROCESS : process (FrmClkDiv, IntFrmClkRst)
begin
	if (IntFrmClkRst = High) then
		IntFrmWarnCnt <= (others => '0');
		IntFrmWarnCntTc_d <= Low;
	elsif (FrmClkDiv'event and FrmClkDiv = '1') then
		if (IntFrmSlipCntTc_d = High) then
			IntFrmWarnCnt <= IntFrmWarnCnt + "01";
			IntFrmWarnCntTc_d <= IntFrmWarnCntTc;
		end if;
	end if;
end process;
IntFrmWarnCntTc <= High when (IntFrmWarnCnt = "110") else Low;
FrmClkSyncWarn <= IntFrmWarnCntTc_d;
-----------------------------------------------------------------------------------------------
-- Enable, RESYNC or INTERNAL RESET
-- This is the reset logic for the whole design.
-- Whenever one of these signals (IntFrmSlipCntTc_d2, IntFrmDbleNibFnl, FrmClkReSync, FrmClkRst)
-- is high the circuit is pulled int reset (call it a re-sync operation).
--
-- The only components not influenced by this are the ISERDES and the Sync Warning Counter.
-- they only act on the external "FrmClkRst" input.
--
-- A circuit enable "IntFrmEna" is generated when the inputs "FrmClkDone" and "FrmClkEna" are
-- high and when the "IntFrmReSync" reset is released.
-----------------------------------------------------------------------------------------------
AdcFrame_I_GenPulse_1 : entity Common.GenPulse
    port map (
        Clk		=> FrmClkDiv, -- in
        Ena		=> High, -- in
        SigIn	=> FrmClkReSync, -- in
        SigOut	=> IntFrmClkReSync -- out
    );
--
IntFrmReSyncOut <= IntFrmSlipCntTc_d2 or IntFrmDbleNibFnl or IntFrmClkReSync; -- or FrmClkRst;
--
AdcFrame_I_Fdce_ReSync : FDCE
    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
    port map (D => IntFrmReSyncOut, CE => High, C => FrmClkDiv,
              CLR => low, Q => IntFrmReSyncOut_d);
--
IntFrmClkRst <= FrmClkRst or IntFrmReSyncOut_d;
FrmClkReSyncOut <= IntFrmReSyncOut_d;
--
AdcFrame_I_Fdce_Done : FDCE
    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
    port map(D => FrmClkDone, CE => FrmClkEna, C => FrmClkDiv, CLR => IntFrmClkRst,
             Q => IntFrmEna);
-----------------------------------------------------------------------------------------------
-- BITSLIP STATE MACHINE.
-----------------------------------------------------------------------------------------------
AdcFrame_Bitslip_PROCESS : process (IntFrmClkRst, FrmClkDiv)
subtype IntFrmBitSlipCase is std_logic_vector(5 downto 0);
begin
	if (IntFrmClkRst = High) then
		IntFrmBitSlip <= (others => '0');
	elsif (FrmClkDiv'event and FrmClkDiv = '1') then
		if (IntFrmEna = High and IntFrmEquSet_d = Low) then
			case IntFrmBitSlipCase'(IntFrmEqu_d, IntFrmEvntCntTc_d, IntFrmBitSlip(5),
									IntFrmBitSlip(4), IntFrmBitSlip(3), IntFrmBitSlip(2)) is
				when "000000" => IntFrmBitSlip <= "000000"; -- B
				when "010000" => IntFrmBitSlip <= "000101"; -- C Slip_p
				when "000001" => IntFrmBitSlip <= "000100"; -- D
				when "010001" => IntFrmBitSlip <= "001010"; -- E Slip_n
				when "000010" => IntFrmBitSlip <= "001000"; -- F
				when "010010" => IntFrmBitSlip <= "000101"; -- G Slip_p and goto D
				--
				when "100000" => IntFrmBitSlip <= "000000"; -- H
				when "110000" => IntFrmBitSlip <= "100101"; -- K Slip_p
				when "101001" => IntFrmBitSlip <= "110000"; -- L EquSet
				when "101100" => IntFrmBitSlip <= "110000"; -- M Halt
				--
				when "100001" => IntFrmBitSlip <= "000100"; -- N
				when "110001" => IntFrmBitSlip <= "101010"; -- P Slip_n
				when "101010" => IntFrmBitSlip <= "110000"; -- R EquSet goto M
				--
				when "100010" => IntFrmBitSlip <= "001000"; -- S
				--when "110010" => IntFrmBitSlip <= "100101"; -- T Slip_p goto L
                when "110010" => IntFrmBitSlip <= "1001" & IntFrmSwapMux_d & not IntFrmSwapMux_d;
				--
				when others => IntFrmBitSlip <= "110000";
			end case;
		end if;
	end if;
end process;
FrmClkBitSlip_p <= IntFrmBitSlip(0);
FrmClkBitSlip_n <= IntFrmBitSlip(1);
IntFrmEquSet_d <= IntFrmBitSlip(4);
--
-----------------------------------------------------------------------------------------------
end  AdcFrame_struct;
