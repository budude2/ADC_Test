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
-- /___/  \  /   Vendor: 				Xilinx
-- \   \   \/    Version:               V0.03
--  \   \        Filename: 				AdcData.vhd
--  /   /        Date Last Modified:	12 Feb 2018
-- /___/   /\    Date Created:			18 Dec 2007
-- \   \  /  \
--  \___\/\___\
--
-- Device: 		Virtex-6, 7-Series
-- Author: 		Marc Defossez
-- Entity Name: AdcData
-- Purpose: 	2-channel ADC data receiver interface.
--				The output of this module is alwasy fprmatted in 32-bit.
--				When the interface is for a 12-bit ADC then the output is formatted as:
--				32 ---------- 16 , 15 ----------- 0
--				 0000 & (12-bit) ,  0000 & (12-bit)
--				When the interface is for 14-bit or 16-bit the the ouput is formatted as:
--				32 ---------- 16 , 15 ----------- 0
--				 (   16-bit   ) ,  (   16-bit    )
-- 				In 1-wire mode the 32-bit output shows two channels
--				In 2-wire mode the 32-bit output shows two words of the same channel.
--
-- Tools: 		Vivado_2017.3 or later
-- Limitations: none
--
-- Revision History:
-----------------------------------------------------------------------------------------------
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
--
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_UNSIGNED.all;
library UNISIM;
	use UNISIM.VCOMPONENTS.all;
-----------------------------------------------------------------------------------------------
-- Entity pin description
-----------------------------------------------------------------------------------------------
entity AdcData is
	generic (
		C_AdcBits			: integer := 16;	-- Can be 12, 14 or 16
		C_AdcBytOrBitMode	: integer := 0;     -- 1 = BIT mode, 0 = BYTE mode,
		C_AdcMsbOrLsbFst	: integer := 0;     -- 0 = MSB first, 1 = LSB first
		C_AdcWireInt		: integer := 1		-- 1 = 1-wire, 2 = 2-wire.
	);
    port (
        DatD0_n			: in std_logic;
		DatD0_p			: in std_logic;
		DatD1_n			: in std_logic;
		DatD1_p			: in std_logic;
		DatClk			: in std_logic;
		DatClkDiv		: in std_logic;
		DatRst			: in std_logic;
		DatEna			: in std_logic;
		DatDone			: in std_logic;
		DatBitSlip_p	: in std_logic;
        DatBitSlip_n	: in std_logic;
        DatSwapMux		: in std_logic;
        DatMsbRegEna	: in std_logic;
        DatLsbRegEna	: in std_logic;
        DatReSync		: in std_logic;
		DatOut			: out std_logic_vector(31 downto 0)
    );
end AdcData;
-----------------------------------------------------------------------------------------------
-- Arcitecture section
-----------------------------------------------------------------------------------------------
architecture AdcData_struct of AdcData  is
-----------------------------------------------------------------------------------------------
-- Component Instantiation
-----------------------------------------------------------------------------------------------
-- Components are instantiated through library naming.
-----------------------------------------------------------------------------------------------
-- Constants, Signals and Attributes Declarations
-----------------------------------------------------------------------------------------------
-- Functions
-- In two wire mode a 12 bit ADC has 2 channels of 6 bits. The AdcBits stay at 12.
-- In two wire mode a 14 bit ADC has 2 channels of 8 bits. The AdcBits is set at 16.
-- In two wire mode a 16 bit ADC has 2 channels of 8 bits. The AdcBits stay at 16.
function DatBits (Bits : integer) return integer is
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
end function DatBits;
-- Constants
constant IntIsrdsDataWidth : integer := DatBits(C_AdcBits)/4;
constant Low			: std_logic := '0';
constant High			: std_logic := '1';
-- Signals
signal IntDatClk		: std_logic;
signal IntDatClk_n		: std_logic;
--
-- ADC resolution = 12-bit: IntDatSrds0Out(5 downto 0) and IntDatSrds1Out(5 downto 0)
-- ADC resolution = 14-bit or 16-bit: IntDatSrds0Out(7 downto 0) and IntDatSrds1Out(7 downto 0)
signal IntDatSrds0Out	: std_logic_vector(7 downto 0);
signal IntDatSrds1Out	: std_logic_vector(7 downto 0);
signal IntDatSrds0		: std_logic_vector((DatBits(C_AdcBits)/2)-1 downto 0);
signal IntDatSrds1		: std_logic_vector((DatBits(C_AdcBits)/2)-1 downto 0);
signal IntDat0			: std_logic_vector((DatBits(C_AdcBits)/2)-1 downto 0);
signal IntDat1			: std_logic_vector((DatBits(C_AdcBits)/2)-1 downto 0);
signal IntDat0Mux       : std_logic_vector((DatBits(C_AdcBits)/2)-1 downto 0);
signal IntDat1Mux       : std_logic_vector((DatBits(C_AdcBits)/2)-1 downto 0);
signal IntDat0Swp		: std_logic_vector((DatBits(C_AdcBits)/2)-1 downto 0);
signal IntDat1Swp		: std_logic_vector((DatBits(C_AdcBits)/2)-1 downto 0);
signal IntDatSwpBus     : std_logic_vector(31 downto 0);
signal IntDatDone		: std_logic;
signal IntDatEna 		: std_logic;
-- Attributes
attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of AdcData_struct : architecture is "YES";
-----------------------------------------------------------------------------------------------
begin
--
-- DatRst and DatEna are synchronised to DatClkDiv on the level were this component "AdcData"
-- is used. This higher level is "AdcToplevel".
AdcData_Done_PROCESS : process (DatClkDiv, DatRst)
begin
	if (DatRst = High) then
		IntDatDone <= Low;
	elsif (DatClkDiv'event and DatClkDiv = '1') then
        IntDatDone <= DatDone;
	end if;
end process;
--
IntDatEna <= High when (IntDatDone = High and DatEna = High) else Low;
-----------------------------------------------------------------------------------------------
IntDatClk <= DatClk;			-- CLOCK FOR P-side ISERDES
--IntDatClk_n <= not DatClk;		-- CLOCK FOR N_side ISERDES
-- Above is commented because the ISERDESE2 has a generic IS_CLK_INVERTED set to '1'.
-- The CLK clock is inverted inside the ISERDESE2.
-----------------------------------------------------------------------------------------------
-- ISERDES for channel ZERO
-----------------------------------------------------------------------------------------------
AdcData_I_Isrds_D0_p : ISERDESE2
    generic map (
		SERDES_MODE			=> "MASTER",			-- string
		INTERFACE_TYPE		=> "NETWORKING",		-- string
		IOBDELAY			=> "NONE",				-- string
		DATA_RATE 			=> "SDR", 				-- string
		DATA_WIDTH 			=> IntIsrdsDataWidth,	-- integer <-- Number of bits
		DYN_CLKDIV_INV_EN	=> "FALSE", 			-- string
		DYN_CLK_INV_EN		=> "FALSE", 			-- string
		NUM_CE				=> 1, 					-- integer
		OFB_USED			=> "FALSE", 			-- string
        INIT_Q1             => '0',         -- bit;
        INIT_Q2             => '0',         -- bit;
        INIT_Q3             => '0',         -- bit;
        INIT_Q4             => '0',         -- bit;
        SRVAL_Q1            => '0',         -- bit;
        SRVAL_Q2            => '0',         -- bit;
        SRVAL_Q3            => '0',         -- bit;
        SRVAL_Q4            => '0',         -- bit;
        IS_CLKB_INVERTED    => '0',         -- CLKB clock input is NOT inverted
        IS_CLKDIVP_INVERTED => '0',         -- CLKDIVP input is NOT inverted
        IS_CLKDIV_INVERTED  => '0',         -- CLKDIV clock input is NOT inverted
        IS_CLK_INVERTED     => '0',         -- CLK clock input is NOT inverted
        IS_D_INVERTED       => '0',         -- D (data) input is NOT inverted
        IS_OCLKB_INVERTED   => '0',         -- OCLKB clock input is NOT inverted
        IS_OCLK_INVERTED    => '0'          -- OCLK clock input is NOT inverted
    )
    port map (
		D				=> DatD0_p,		-- in
		DDLY			=> Low, 		-- in
		OFB				=> Low, 		-- in
		BITSLIP			=> DatBitSlip_p,-- in
		CE1				=> IntDatDone,	-- in
		CE2				=> Low,			-- in
		RST				=> DatRst,	    -- in
		CLK				=> IntDatClk, 	-- in
		CLKB			=> Low, 		-- in
		CLKDIV			=> DatClkDiv, 	-- in
        CLKDIVP         => Low,         -- in
		OCLK			=> Low, 		-- in
        OCLKB           => Low,         -- in
		DYNCLKDIVSEL	=> Low, 		-- in
		DYNCLKSEL		=> Low, 		-- in
		SHIFTOUT1		=> open, 		-- out
		SHIFTOUT2		=> open, 		-- out
		O				=> open, 		-- out
		Q1				=> IntDatSrds0Out(6), -- out	(0)
		Q2				=> IntDatSrds0Out(4), -- out	(2)
		Q3				=> IntDatSrds0Out(2), -- out	(4)
		Q4				=> IntDatSrds0Out(0), -- out	(6)
		Q5				=> open, 		-- out
		Q6				=> open, 		-- out
        Q7              => open,        -- out
        Q8              => open,        -- out
		SHIFTIN1		=> Low, 		-- in
		SHIFTIN2		=> Low 			-- in
	);
AdcData_I_Isrds_D0_n : ISERDESE2
	generic map (
		SERDES_MODE			=> "MASTER",			--
		INTERFACE_TYPE		=> "NETWORKING",		--
		IOBDELAY			=> "NONE",				--
		DATA_RATE 			=> "SDR", 				--
		DATA_WIDTH 			=> IntIsrdsDataWidth,	-- <-- Number of bits
		DYN_CLKDIV_INV_EN	=> "FALSE",      		--
		DYN_CLK_INV_EN		=> "FALSE", 			--
		NUM_CE				=> 1, 					--
		OFB_USED			=> "FALSE", 			--
        INIT_Q1             => '0',         -- bit;
        INIT_Q2             => '0',         -- bit;
        INIT_Q3             => '0',         -- bit;
        INIT_Q4             => '0',         -- bit;
        SRVAL_Q1            => '0',         -- bit;
        SRVAL_Q2            => '0',         -- bit;
        SRVAL_Q3            => '0',         -- bit;
        SRVAL_Q4            => '0',          -- bit;
        IS_CLKB_INVERTED    => '0',         -- CLKB clock input is NOT inverted
        IS_CLKDIVP_INVERTED => '0',         -- CLKDIVP input is NOT inverted
        IS_CLKDIV_INVERTED  => '0',         -- CLKDIV clock input is NOT inverted
        IS_CLK_INVERTED     => '1',         -- CLK clock input IS INVERTED
        IS_D_INVERTED       => '0',         -- D (data) input is NOT inverted
        IS_OCLKB_INVERTED   => '0',         -- OCLKB clock input is NOT inverted
        IS_OCLK_INVERTED    => '0'          -- OCLK clock input is NOT inverted
    )
    port map (
		D				=> DatD0_n,		-- in
		DDLY			=> Low, 		-- in
		OFB				=> Low, 		-- in
		BITSLIP			=> DatBitSlip_n,-- in
		CE1				=> IntDatDone,	-- in
		CE2				=> Low,			-- in
		RST				=> DatRst,	    -- in
		CLK				=> IntDatClk,	-- in
		CLKB			=> Low, 		-- in
		CLKDIV			=> DatClkDiv, 	-- in
        CLKDIVP         => Low,         -- in
		OCLK			=> Low, 		-- in
        OCLKB           => Low,         -- in
		DYNCLKDIVSEL	=> Low, 		-- in
		DYNCLKSEL		=> Low, 		-- in
		SHIFTOUT1		=> open, 		-- out
		SHIFTOUT2		=> open, 		-- out
		O				=> open, 		-- out
		Q1				=> IntDatSrds0Out(7), -- out	(1)
		Q2				=> IntDatSrds0Out(5), -- out	(3)
		Q3				=> IntDatSrds0Out(3), -- out	(5)
		Q4				=> IntDatSrds0Out(1), -- out	(7)
		Q5				=> open, 		-- out
		Q6				=> open, 		-- out
        Q7              => open,        -- out
        Q8              => open,        -- out
		SHIFTIN1		=> Low, 		-- in
		SHIFTIN2		=> Low 			-- in
	);
-----------------------------------------------------------------------------------------------
-- ISERDES for channel ONE
-----------------------------------------------------------------------------------------------
AdcData_I_Isrds_D1_p : ISERDESE2
    generic map (
		SERDES_MODE			=> "MASTER",			-- string
		INTERFACE_TYPE		=> "NETWORKING",		-- string
		IOBDELAY			=> "NONE",				-- string
		DATA_RATE 			=> "SDR", 				-- string
		DATA_WIDTH 			=> IntIsrdsDataWidth,	-- integer <-- Number of bits
		DYN_CLKDIV_INV_EN	=> "FALSE",				-- string
		DYN_CLK_INV_EN		=> "FALSE",				-- string
		NUM_CE				=> 1, 					-- integer
		OFB_USED			=> "FALSE",				-- string
        INIT_Q1             => '0',         -- bit;
        INIT_Q2             => '0',         -- bit;
        INIT_Q3             => '0',         -- bit;
        INIT_Q4             => '0',         -- bit;
        SRVAL_Q1            => '0',         -- bit;
        SRVAL_Q2            => '0',         -- bit;
        SRVAL_Q3            => '0',         -- bit;
        SRVAL_Q4            => '0',         -- bit;
        IS_CLKB_INVERTED    => '0',         -- CLKB clock input is NOT inverted
        IS_CLKDIVP_INVERTED => '0',         -- CLKDIVP input is NOT inverted
        IS_CLKDIV_INVERTED  => '0',         -- CLKDIV clock input is NOT inverted
        IS_CLK_INVERTED     => '0',         -- CLK clock input is NOT inverted
        IS_D_INVERTED       => '0',         -- D (data) input is NOT inverted
        IS_OCLKB_INVERTED   => '0',         -- OCLKB clock input is NOT inverted
        IS_OCLK_INVERTED    => '0'          -- OCLK clock input is NOT inverted
    )
    port map (
		D				=> DatD1_p,		-- in
		DDLY			=> Low, 		-- in
		OFB				=> Low, 		-- in
		BITSLIP			=> DatBitSlip_p,-- in
		CE1				=> IntDatDone,	-- in
		CE2				=> Low,			-- in
		RST				=> DatRst,	    -- in
		CLK				=> IntDatClk, 	-- in
		CLKB			=> Low, 		-- in
		CLKDIV			=> DatClkDiv, 	-- in
        CLKDIVP         => Low,         -- in
		OCLK			=> Low, 		-- in
        OCLKB           => Low,         -- in
		DYNCLKDIVSEL	=> Low, 		-- in
		DYNCLKSEL		=> Low, 		-- in
		SHIFTOUT1		=> open, 		-- out
		SHIFTOUT2		=> open, 		-- out
		O				=> open, 		-- out
		Q1				=> IntDatSrds1Out(6), -- out	(0)
		Q2				=> IntDatSrds1Out(4), -- out	(2)
		Q3				=> IntDatSrds1Out(2), -- out	(4)
		Q4				=> IntDatSrds1Out(0), -- out	(6)
		Q5				=> open, 		-- out
		Q6				=> open, 		-- out
        Q7              => open,        -- out
        Q8              => open,        -- out
		SHIFTIN1		=> Low, 		-- in
		SHIFTIN2		=> Low 			-- in
    );
AdcData_I_Isrds_D1_n : ISERDESE2
	generic map (
		SERDES_MODE			=> "MASTER",			--
		INTERFACE_TYPE		=> "NETWORKING",		--
		IOBDELAY			=> "NONE",				--
		DATA_RATE 			=> "SDR", 				--
		DATA_WIDTH 			=> IntIsrdsDataWidth,	-- <-- Number of bits
		DYN_CLKDIV_INV_EN	=> "FALSE", 			--
		DYN_CLK_INV_EN		=> "FALSE", 			--
		NUM_CE				=> 1, 					--
		OFB_USED			=> "FALSE", 			--
        INIT_Q1             => '0',         -- bit;
        INIT_Q2             => '0',         -- bit;
        INIT_Q3             => '0',         -- bit;
        INIT_Q4             => '0',         -- bit;
        SRVAL_Q1            => '0',         -- bit;
        SRVAL_Q2            => '0',         -- bit;
        SRVAL_Q3            => '0',         -- bit;
        SRVAL_Q4            => '0',         -- bit;
        IS_CLKB_INVERTED    => '0',         -- CLKB clock input is NOT inverted
        IS_CLKDIVP_INVERTED => '0',         -- CLKDIVP input is NOT inverted
        IS_CLKDIV_INVERTED  => '0',         -- CLKDIV clock input is NOT inverted
        IS_CLK_INVERTED     => '1',         -- CLK clock input IS INVERTED
        IS_D_INVERTED       => '0',         -- D (data) input is NOT inverted
        IS_OCLKB_INVERTED   => '0',         -- OCLKB clock input is NOT inverted
        IS_OCLK_INVERTED    => '0'          -- OCLK clock input is NOT inverted
    )
    port map (
		D				=> DatD1_n,		-- in
		DDLY			=> Low, 		-- in
		OFB				=> Low, 		-- in
		BITSLIP			=> DatBitSlip_n,-- in
		CE1				=> IntDatDone,	-- in
		CE2				=> Low,			-- in
		RST				=> DatRst,	    -- in
		CLK				=> IntDatClk,	-- in
		CLKB			=> Low, 		-- in
		CLKDIV			=> DatClkDiv, 	-- in
        CLKDIVP         => Low,         -- in
		OCLK			=> Low, 		-- in
        OCLKB           => Low,         -- in
		DYNCLKDIVSEL	=> Low, 		-- in
		DYNCLKSEL		=> Low, 		-- in
		SHIFTOUT1		=> open, 		-- out
		SHIFTOUT2		=> open, 		-- out
		O				=> open, 		-- out
		Q1				=> IntDatSrds1Out(7), -- out	(1)
		Q2				=> IntDatSrds1Out(5), -- out	(3)
		Q3				=> IntDatSrds1Out(3), -- out	(5)
		Q4				=> IntDatSrds1Out(1), -- out	(7)
		Q5				=> open, 		-- out
		Q6				=> open, 		-- out
        Q7              => open,        -- out
        Q8              => open,        -- out
		SHIFTIN1		=> Low, 		-- in
		SHIFTIN2		=> Low 			-- in
	);
-----------------------------------------------------------------------------------------------
Gen_1_DatBus : if (DatBits(C_AdcBits)/2) = 6 generate
begin
	IntDatSrds0 <= not IntDatSrds0Out(5) & IntDatSrds0Out(4) &
					not IntDatSrds0Out(3) & IntDatSrds0Out(2) &
					not IntDatSrds0Out(1) & IntDatSrds0Out(0);
	IntDatSrds1 <= not IntDatSrds1Out(5) & IntDatSrds1Out(4) &
					not IntDatSrds1Out(3) & IntDatSrds1Out(2) &
					not IntDatSrds1Out(1) & IntDatSrds1Out(0);
end generate;
Gen_2_DatBus : if (DatBits(C_AdcBits)/2) = 8 generate
begin
	IntDatSrds0 <= not IntDatSrds0Out(7) & IntDatSrds0Out(6) &
					not IntDatSrds0Out(5) & IntDatSrds0Out(4) &
					not IntDatSrds0Out(3) & IntDatSrds0Out(2) &
					not IntDatSrds0Out(1) & IntDatSrds0Out(0);
	IntDatSrds1 <= not IntDatSrds1Out(7) & IntDatSrds1Out(6) &
					not IntDatSrds1Out(5) & IntDatSrds1Out(4) &
					not IntDatSrds1Out(3) & IntDatSrds1Out(2) &
					not IntDatSrds1Out(1) & IntDatSrds1Out(0);
end generate;
-----------------------------------------------------------------------------------------------
-- DATA REGISTER
-----------------------------------------------------------------------------------------------
Gen_1_DatReg : for n in (DatBits(C_AdcBits)/2)-1 downto 0 generate
    AdcData_I_Fdce_Reg0 : FDCE
        generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
        port map (D => IntDatSrds0(n), C => DatClkDiv, CE => IntDatEna, CLR => DatReSync,
                  Q => IntDat0(n));
    AdcData_I_Fdce_Reg1 : FDCE
        generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
        port map (D => IntDatSrds1(n), C => DatClkDiv, CE => IntDatEna, CLR => DatReSync,
                  Q => IntDat1(n));
end generate Gen_1_DatReg;
-----------------------------------------------------------------------------------------------
-- BIT SWAP MULTIPLEXER and REGISTER
-- Swap the bits in correct order when the pattern detected is bit swapped.
-----------------------------------------------------------------------------------------------
Gen_2_DatMux : for n in (DatBits(C_AdcBits)/4)-1 downto 0 generate
begin
    IntDat0Mux((n*2)+1) <= IntDat0(n*2)     when (DatSwapMux = '1') else IntDat0((n*2)+1);
    IntDat0Mux(n*2)     <= IntDat0((n*2)+1) when (DatSwapMux = '1') else IntDat0(n*2);
    IntDat1Mux((n*2)+1) <= IntDat1(n*2)     when (DatSwapMux = '1') else IntDat1((n*2)+1);
    IntDat1Mux(n*2)     <= IntDat1((n*2)+1) when (DatSwapMux = '1') else IntDat1(n*2);
end generate Gen_2_DatMux;
Gen_3_DatReg : for n in (DatBits(C_AdcBits)/2)-1 downto 0 generate
    AdcData_I_Fdce_Reg2 : FDCE
        generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
        port map (D => IntDat0Mux(n), C => DatClkDiv, CE => IntDatEna, CLR => DatReSync,
                  Q => IntDat0Swp(n));
    AdcData_I_Fdce_Reg3 : FDCE
        generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0', IS_D_INVERTED => '0')
        port map (D => IntDat1Mux(n), C => DatClkDiv, CE => IntDatEna, CLR => DatReSync,
                  Q => IntDat1Swp(n));
end generate Gen_3_DatReg;
-----------------------------------------------------------------------------------------------
-- 1-WIRE, 12x SERIALIZATION for 12-bit ADCs
-- The data from one ADC will show up in the output of one interface channel. It is so that the
-- 32-bit output of the interface shows both channels. Bits 31:16 show the upper channel and
-- bits 15:0 show the lower channel.
-----------------------------------------------------------------------------------------------
Gen_1w_12b : if (C_AdcBits = 12 and C_AdcWireInt = 1) generate
	-- 1-wire mode is only coded for BIT wise operation.
	Gen_1_Msb : if C_AdcMsbOrLsbFst = 0 generate
--		-- MSB first.
--		-- Output	: 31						16	15							0
--		--			: "0000" & MSB(5:0) & LSB(5:0)	"0000" & MSB(5:0) & LSB(5:0)
        IntDatSwpBus <= "0000" & IntDat1Swp(5 downto 0) & IntDat1Swp(5 downto 0) &
                        "0000" & IntDat0Swp(5 downto 0) & IntDat0Swp(5 downto 0);
        Gen_1_H : for n in 6 to 15 generate
            I_Fdce_HH : FDCE
                generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                            IS_D_INVERTED => '0')
                port map (D => IntDatSwpBus(n+16), CE => DatMsbRegEna, C => DatClkDiv,
                          CLR => DatReSync, Q => DatOut(n+16));
            I_Fdce_HL : FDCE
                generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                            IS_D_INVERTED => '0')
                port map (D => IntDatSwpBus(n), CE => DatMsbRegEna, C => DatClkDiv,
                          CLR => DatReSync, Q => DatOut(n));
        end generate Gen_1_H;
        Gen_1_L : for n in 0 to 5 generate
            I_Fdce_LH : FDCE
                generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                            IS_D_INVERTED => '0')
                port map (D => IntDatSwpBus(n+16), CE => DatLsbRegEna, C => DatClkDiv,
                          CLR => DatReSync, Q => DatOut(n+16));
            I_Fdce_LL : FDCE
                generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                            IS_D_INVERTED => '0')
                port map (D => IntDatSwpBus(n), CE => DatLsbRegEna, C => DatClkDiv,
                          CLR => DatReSync, Q => DatOut(n));
        end generate Gen_1_L;
	end generate;
	Gen_1_Lsb : if C_AdcMsbOrLsbFst = 1 generate
		-- LSB first.
		-- Output	: 31             22 & 21    16 & 15              6 & 5      0
		--			: "0000" & LSB(0:5) & MSB(0:5)   "0000" & LSB(0:5) & MSB(0:5)
		IntDatSwpBus <= "0000" & IntDat1Swp(0) & IntDat1Swp(1) & IntDat1Swp(2) & -- 31-|
		                         IntDat1Swp(3) & IntDat1Swp(4) & IntDat1Swp(5) & --    |-22
		                IntDat1Swp(0) & IntDat1Swp(1) & IntDat1Swp(2) &          -- 21-|
		                IntDat1Swp(3) & IntDat1Swp(4) & IntDat1Swp(5) &          --    |-16
		                "0000" & IntDat0Swp(0) & IntDat0Swp(1) & IntDat0Swp(2) & -- 15-|
                                 IntDat0Swp(3) & IntDat0Swp(4) & IntDat0Swp(5) & --    |-6
                        IntDat0Swp(0) & IntDat0Swp(1) & IntDat0Swp(2) &          --  5-|
                        IntDat0Swp(3) & IntDat0Swp(4) & IntDat0Swp(5);           --    |-0
        Gen_1_H : for n in 6 to 15 generate
            I_Fdce_HH : FDCE
                generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                            IS_D_INVERTED => '0')
                port map (D => IntDatSwpBus(n+16), CE => DatMsbRegEna, C => DatClkDiv,
                          CLR => DatReSync, Q => DatOut(n+16));
            I_Fdce_HL : FDCE
                generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                            IS_D_INVERTED => '0')
                port map (D => IntDatSwpBus(n), CE => DatMsbRegEna, C => DatClkDiv,
                          CLR => DatReSync, Q => DatOut(n));
        end generate Gen_1_H;
        Gen_1_L : for n in 0 to 5 generate
            I_Fdce_LH : FDCE
                generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                            IS_D_INVERTED => '0')
                port map (D => IntDatSwpBus(n+16), CE => DatLsbRegEna, C => DatClkDiv,
                          CLR => DatReSync, Q => DatOut(n+16));
            I_Fdce_LL : FDCE
                generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                            IS_D_INVERTED => '0')
                port map (D => IntDatSwpBus(n), CE => DatLsbRegEna, C => DatClkDiv,
                          CLR => DatReSync, Q => DatOut(n));
        end generate Gen_1_L;
	end generate;
end generate;
-----------------------------------------------------------------------------------------------
-- 2-WIRE, 12x SERIALIZATION for 12-bit ADCs
-- Only one of these options can be chosen at a time.
--	2-wire, Msb-Bit or Msb-Byte
--	2-wire, Lsb-Bit or Lsb-Byte
-----------------------------------------------------------------------------------------------
Gen_2w_12b : if (C_AdcBits = 12 and C_AdcWireInt = 2) generate
	Gen_1_Msb : if C_AdcMsbOrLsbFst = 0 generate
	-- Bit mode, MSB First
	-- Bit			: 5    4   3   2   1   0
	-- Channel 0	: D10, D8, D6, D4, D2, D0
	-- Channel 1	: D11, D9, D7, D5, D3, D1
	-- Output		: 0 0 0 0, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0
	--				: 0 0 0 0, 1_5, 0_5, 1_4, 0_4, 1_3, 0_3, 1_2, 0_2, 1_1, 0_1, 1_0, 0_0
        Gen_1_Bit :	if C_AdcBytOrBitMode = 1 generate	-- Bit mode
            IntDatSwpBus <= "0000"
                            & IntDat1Swp(5) & IntDat0Swp(5) & IntDat1Swp(4) & IntDat0Swp(4)
                            & IntDat1Swp(3) & IntDat0Swp(3) & IntDat1Swp(2) & IntDat0Swp(2)
                            & IntDat1Swp(1) & IntDat0Swp(1) & IntDat1Swp(0) & IntDat0Swp(0)
                            & "0000"
                            & IntDat1Swp(5) & IntDat0Swp(5) & IntDat1Swp(4) & IntDat0Swp(4)
                            & IntDat1Swp(3) & IntDat0Swp(3) & IntDat1Swp(2) & IntDat0Swp(2)
                            & IntDat1Swp(1) & IntDat0Swp(1) & IntDat1Swp(0) & IntDat0Swp(0);
            Gen_1_HL : for n in 0 to 15 generate
                I_Fdce_H : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n+16), CE => DatMsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n+16));
                I_Fdce_L : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n), CE => DatLsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n));
            end generate Gen_1_HL;
		end generate;
	-- Byte mode, MSB First
	-- Bit			: 5    4    3   2   1   0
	-- Channel 0	: D5,  D4,  D3, D2, D1, D0
	-- Channel 1	: D11, D10, D9, D8, D7, D6
	-- Output		: 0 0 0 0, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0
	--				: 0 0 0 0, 1_5, 1_4, 1_3, 1_2, 1_1, 1_0, 0_5, 0_4, 0_3, 0_2, 0_1, 0_0
		Gen_1_Byt : if C_AdcBytOrBitMode = 0 generate	-- Byte Mode
            IntDatSwpBus <= "0000"
                            & IntDat1Swp(5) & IntDat1Swp(4) & IntDat1Swp(3) & IntDat1Swp(2)
                            & IntDat1Swp(1) & IntDat1Swp(0) & IntDat0Swp(5) & IntDat0Swp(4)
                            & IntDat0Swp(3) & IntDat0Swp(2) & IntDat0Swp(1) & IntDat0Swp(0)
                            & "0000"
                            & IntDat1Swp(5) & IntDat1Swp(4) & IntDat1Swp(3) & IntDat1Swp(2)
                            & IntDat1Swp(1) & IntDat1Swp(0) & IntDat0Swp(5) & IntDat0Swp(4)
                            & IntDat0Swp(3) & IntDat0Swp(2) & IntDat0Swp(1) & IntDat0Swp(0);
            Gen_1_HL : for n in 0 to 15 generate
                I_Fdce_H : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n+16), CE => DatMsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n+16));
                I_Fdce_L : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n), CE => DatLsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n));
            end generate Gen_1_HL;
		end generate;
	end generate;
--
	Gen_1_Lsb : if C_AdcMsbOrLsbFst = 1 generate
	-- Bit mode, LSB First
	-- Bit			: 5   4   3   2   1   0
	-- Channel 0	: D0, D2, D4, D6, D8, D10
	-- Channel 1	: D1, D3, D5, D7, D9, D11
	-- Output		: 0 0 0 0, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0
	--				: 0 0 0 0, 1_0, 0_0, 1_1, 0_1, 1_2, 0_2, 1_3, 0_3, 1_4, 0_4, 1_5, 0_5
		Gen_1_Bit :	if C_AdcBytOrBitMode = 1 generate	-- Bit mode
            IntDatSwpBus <= "0000"
                            & IntDat1Swp(0) & IntDat0Swp(0) & IntDat1Swp(1) & IntDat0Swp(1)
                            & IntDat1Swp(2) & IntDat0Swp(2) & IntDat1Swp(3) & IntDat0Swp(3)
                            & IntDat1Swp(4) & IntDat0Swp(4) & IntDat1Swp(5) & IntDat0Swp(5)
                            & "0000"
                            & IntDat1Swp(0) & IntDat0Swp(0) & IntDat1Swp(1) & IntDat0Swp(1)
                            & IntDat1Swp(2) & IntDat0Swp(2) & IntDat1Swp(3) & IntDat0Swp(3)
                            & IntDat1Swp(4) & IntDat0Swp(4) & IntDat1Swp(5) & IntDat0Swp(5);
            Gen_1_HL : for n in 0 to 15 generate
               I_Fdce_H : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n+16), CE => DatMsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n+16));
                I_Fdce_L : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n), CE => DatLsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n));
            end generate Gen_1_HL;
		end generate;
	-- Byte Mode, LSB First
	-- Bit			: 5   4   3   2   1    0
	-- Channel 0	: D0, D1, D2, D3, D4,  D5
	-- Channel 1	: D6, D7, D8, D9, D10, D11
	-- Output		: 0 0 0 0, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0
	--				: 0 0 0 0, 1_0, 1_1, 1_2, 1_3, 1_4, 1_5, 0_0, 0_1, 0_2, 0_3, 0_4, 0_5
		Gen_1_Byt : if C_AdcBytOrBitMode = 0 generate	-- Byte Mode
            IntDatSwpBus <= "0000"
                            & IntDat1Swp(0) & IntDat1Swp(1) & IntDat1Swp(2) & IntDat1Swp(3)
                            & IntDat1Swp(4) & IntDat1Swp(5) & IntDat0Swp(0) & IntDat0Swp(1)
                            & IntDat0Swp(2) & IntDat0Swp(3) & IntDat0Swp(4) & IntDat0Swp(5)
                            & "0000"
                            & IntDat1Swp(0) & IntDat1Swp(1) & IntDat1Swp(2) & IntDat1Swp(3)
                            & IntDat1Swp(4) & IntDat1Swp(5) & IntDat0Swp(0) & IntDat0Swp(1)
                            & IntDat0Swp(2) & IntDat0Swp(3) & IntDat0Swp(4) & IntDat0Swp(5);
            Gen_1_HL : for n in 0 to 15 generate
                I_Fdce_H : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n+16), CE => DatMsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n+16));
                I_Fdce_L : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n), CE => DatLsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n));
            end generate Gen_1_HL;
		end generate;
	end generate;
end generate;
-----------------------------------------------------------------------------------------------
-- 1-WIRE, 16x SERIALIZATION for 14-bit and 16-bit ADCs
-- The data from one ADC will show up in the output of one interface channel. It is so that the
-- 32-bit output of the interface shows both channels. Bits 31:16 show the upper channel (CH_1)
-- and bits 15:0 show the lower (CH_0) channel.
-----------------------------------------------------------------------------------------------
Gen_1w_1416b : if (C_AdcBits /= 12 and C_AdcWireInt = 1) generate
	-- 1-wire is only coded for BIT wise operation
	Gen_1_Msb : if C_AdcMsbOrLsbFst = 0 generate
        IntDatSwpBus <= IntDat1Swp(7 downto 0) & IntDat1Swp(7 downto 0) &
                        IntDat0Swp(7 downto 0) & IntDat0Swp(7 downto 0);
            Gen_1_HL : for n in 0 to 7 generate
                I_Fdce_HH : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n+24), CE => DatMsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n+24));
                I_Fdce_HL : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n+8), CE => DatMsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n+8));
                I_Fdce_LH : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n+16), CE => DatLsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n+16));
                I_Fdce_LL : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n), CE => DatLsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n));
            end generate Gen_1_HL;
	end generate;
	Gen_1_Lsb : if C_AdcMsbOrLsbFst = 1 generate
            IntDatSwpBus <= IntDat1Swp(0) & IntDat1Swp(1) & IntDat1Swp(2) & IntDat1Swp(3) &
                            IntDat1Swp(4) & IntDat1Swp(5) & IntDat1Swp(6) & IntDat1Swp(7) &
                            IntDat1Swp(0) & IntDat1Swp(1) & IntDat1Swp(2) & IntDat1Swp(3) &
                            IntDat1Swp(4) & IntDat1Swp(5) & IntDat1Swp(6) & IntDat1Swp(7) &
                            IntDat0Swp(0) & IntDat0Swp(1) & IntDat0Swp(2) & IntDat0Swp(3) &
                            IntDat0Swp(4) & IntDat0Swp(5) & IntDat0Swp(6) & IntDat0Swp(7) &
                            IntDat0Swp(0) & IntDat0Swp(1) & IntDat0Swp(2) & IntDat0Swp(3) &
                            IntDat0Swp(4) & IntDat0Swp(5) & IntDat0Swp(6) & IntDat0Swp(7);
            Gen_1_HL : for n in 0 to 7 generate
                I_Fdce_HH : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n+24), CE => DatMsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n+24));
                I_Fdce_HL : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n+8), CE => DatMsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n+8));
                I_Fdce_LH : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n+16), CE => DatLsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n+16));
                I_Fdce_LL : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n), CE => DatLsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n));
            end generate Gen_1_HL;
	end generate;
end generate;
-----------------------------------------------------------------------------------------------
-- 2-WIRE, 16x SERIALIZATION for 14-bit and 16-bit ADCs
-- Only one of these options can be chosen at a time.
--	2-wire, Msb-Bit or Msb-Byte
--	2-wire, Lsb-Bit or Lsb-Byte
-----------------------------------------------------------------------------------------------
Gen_1416Bit : if (C_AdcBits /= 12 and C_AdcWireInt = 2) generate
--	Shift in order is assumed MSB first.
	Gen_2_Msb : if C_AdcMsbOrLsbFst = 0 generate
	-- Bit mode, MSB First, 14-bits (16-bits)
	-- Bit			: 7,       6,   5,   4,  3,  2,  1,  0
	-- Channel 0	: 0/(D14), D12, D10, D8, D6, D4, D2, D0
	-- Channel 1	: 0/(D15), D13, D11, D9, D7, D5, D3, D1
		Gen1_Bit : if C_AdcBytOrBitMode = 1 generate	-- Bit mode
            IntDatSwpBus <= IntDat1Swp(5) & IntDat0Swp(5) & IntDat1Swp(4) & IntDat0Swp(4)
                            & IntDat1Swp(7) & IntDat0Swp(7) & IntDat1Swp(6) & IntDat0Swp(6)
                            & IntDat1Swp(1) & IntDat0Swp(1) & IntDat1Swp(0) & IntDat0Swp(0)
                            & IntDat1Swp(3) & IntDat0Swp(3) & IntDat1Swp(2) & IntDat0Swp(2)
                            & IntDat1Swp(5) & IntDat0Swp(5) & IntDat1Swp(4) & IntDat0Swp(4)
                            & IntDat1Swp(7) & IntDat0Swp(7) & IntDat1Swp(6) & IntDat0Swp(6)
                            & IntDat1Swp(1) & IntDat0Swp(1) & IntDat1Swp(0) & IntDat0Swp(0)
                            & IntDat1Swp(3) & IntDat0Swp(3) & IntDat1Swp(2) & IntDat0Swp(2);
            Gen_1_H : for n in 0 to 15 generate
                I_Fdce_H : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n+16), CE => DatMsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n+16));
                I_Fdce_L : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n), CE => DatLsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n));
            end generate Gen_1_H;
		end generate;
	-- Byte Mode, MSB First, 14-bits (16-bits)
	-- Data Bit		: 7,       6,       5,   4,   3,   2,   1,  0,
	-- Channel 0	: D7,      D6,      D5,  D4,  D3,  D2,  D1, D0,
	-- Channel 1	: 0/(D15), 0/(D14), D13, D12, D11, D10, D9, D8
		Gen1_Byt : if C_AdcBytOrBitMode = 0 generate	-- Byte Mode (not tested)
            IntDatSwpBus <= IntDat1Swp(5) & IntDat1Swp(4) & IntDat1Swp(7) & IntDat1Swp(6)
                            & IntDat1Swp(1) & IntDat1Swp(0) & IntDat1Swp(3) & IntDat1Swp(2)
                            & IntDat0Swp(5) & IntDat0Swp(4) & IntDat0Swp(7) & IntDat0Swp(6)
                            & IntDat0Swp(1) & IntDat0Swp(0) & IntDat0Swp(3) & IntDat0Swp(2)
                            & IntDat1Swp(5) & IntDat1Swp(4) & IntDat1Swp(7) & IntDat1Swp(6)
                            & IntDat1Swp(1) & IntDat1Swp(0) & IntDat1Swp(3) & IntDat1Swp(2)
                            & IntDat0Swp(5) & IntDat0Swp(4) & IntDat0Swp(7) & IntDat0Swp(6)
                            & IntDat0Swp(1) & IntDat0Swp(0) & IntDat0Swp(3) & IntDat0Swp(2);
            Gen_1_H : for n in 0 to 15 generate
                I_Fdce_H : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n+16), CE => DatMsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n+16));
                I_Fdce_L : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n), CE => DatLsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n));
            end generate Gen_1_H;
		end generate;
	end generate;
-- Shift in order is assumed LSB first
	Gen_2_Lsb : if C_AdcMsbOrLsbFst = 1 generate
	-- Bit mode, LSB First, 14-bits (16-bit)
	-- Data Bit		; 7,  6,  5,  4,  3,  2,   1,   0
	-- Channel 0	: D0, D2, D4, D6, D8, D10, D12, 0/(D14)
	-- Channel 1	: D1, D3, D5, D7, D9, D11, D13, 0/(D15)
		Gen_2_Bit : if C_AdcBytOrBitMode = 1 generate	-- Bit mode
            IntDatSwpBus <= IntDat0Swp(2) & IntDat1Swp(2) & IntDat0Swp(3) & IntDat1Swp(3)
                            & IntDat0Swp(0) & IntDat1Swp(0) & IntDat0Swp(1) & IntDat1Swp(1)
                            & IntDat0Swp(6) & IntDat1Swp(6) & IntDat0Swp(7) & IntDat1Swp(7)
                            & IntDat0Swp(4) & IntDat1Swp(4) & IntDat0Swp(5) & IntDat1Swp(5)
                            & IntDat0Swp(2) & IntDat1Swp(2) & IntDat0Swp(3) & IntDat1Swp(3)
                            & IntDat0Swp(0) & IntDat1Swp(0) & IntDat0Swp(1) & IntDat1Swp(1)
                            & IntDat0Swp(6) & IntDat1Swp(6) & IntDat0Swp(7) & IntDat1Swp(7)
                            & IntDat0Swp(4) & IntDat1Swp(4) & IntDat0Swp(5) & IntDat1Swp(5);
            Gen_1_H : for n in 0 to 15 generate
                I_Fdce_H : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n+16), CE => DatMsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n+16));
                I_Fdce_L : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n), CE => DatLsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n));
            end generate Gen_1_H;
		end generate;
	-- Byte Mode, LSB First, 14-bits (16-bit)
	-- Data Bit		: 7,  6,  5,   4,   3,   2,   1,      0
	-- Channel 0	: D0, D1, D2,  D3,  D4,  D5,  D6,      D7
	-- Channel 1	: D8, D9, D10, D11, D12, D13, 0/(D14), 0/(D15)
		Gen_2_Byt : if C_AdcBytOrBitMode = 0 generate	-- Byte Mode (not tested)
            IntDatSwpBus <= IntDat1Swp(0) & IntDat1Swp(1) & IntDat1Swp(2) & IntDat1Swp(3)
                            & IntDat1Swp(4) & IntDat1Swp(5) & IntDat1Swp(6) & IntDat1Swp(7)
                            & IntDat0Swp(0) & IntDat0Swp(1) & IntDat0Swp(2) & IntDat0Swp(3)
                            & IntDat0Swp(4) & IntDat0Swp(5) & IntDat0Swp(6) & IntDat0Swp(6)
                            & IntDat1Swp(0) & IntDat1Swp(1) & IntDat1Swp(2) & IntDat1Swp(3)
                            & IntDat1Swp(4) & IntDat1Swp(5) & IntDat1Swp(6) & IntDat1Swp(7)
                            & IntDat0Swp(0) & IntDat0Swp(1) & IntDat0Swp(2) & IntDat0Swp(3)
                            & IntDat0Swp(4) & IntDat0Swp(5) & IntDat0Swp(6) & IntDat0Swp(6);
            Gen_1_H : for n in 0 to 15 generate
                I_Fdce_H : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n+16), CE => DatMsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n+16));
                I_Fdce_L : FDCE
                    generic map (INIT => '0', IS_CLR_INVERTED => '0', IS_C_INVERTED => '0',
                                IS_D_INVERTED => '0')
                    port map (D => IntDatSwpBus(n), CE => DatLsbRegEna, C => DatClkDiv,
                              CLR => DatReSync, Q => DatOut(n));
            end generate Gen_1_H;
		end generate;
	end generate;
end generate;
--
-----------------------------------------------------------------------------------------------
end  AdcData_struct;
