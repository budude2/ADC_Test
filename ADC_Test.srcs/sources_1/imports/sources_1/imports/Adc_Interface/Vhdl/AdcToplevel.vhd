----------------------------------------------------------------------------------------------
-- Copyright 2012, Xilinx, Inc. All rights reserved.
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
-- \   \   \/ 			Version:             V0.02
--  \   \
--  /   /        		Filename:            AdcToplevel.vhd
-- /___/   /\    		Date Created:        Nov 2007
-- \   \  /  \          Date Last Modified:  29 Jan 2018
--  \___\/\___\
--
-- Device:          7-Series
-- Author:          defossez
-- Entity Name:     AdcToplevel
-- Purpose:         Top level for an interface between a Virtex-6 FPGA and ADS6245
-- Tools:           Vivado_2017.3 or later
-- Limitations:     none
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
	use IEEE.std_logic_textio.all;
	use std.textio.all;
library UNISIM;
	use UNISIM.VCOMPONENTS.all;
library AdcClock_Lib;
	use AdcClock_Lib.all;
library AdcFrame_Lib;
	use AdcFrame_Lib.all;
library AdcData_Lib;
	use AdcData_Lib.all;
library AdcMem_Lib;
	use AdcMem_Lib.all;
-----------------------------------------------------------------------------------------------
-- Entity pin description
-----------------------------------------------------------------------------------------------
--      GENERICS
-- C_AdcChnls           -- ADC Channels available in a package.
-- C_AdcBits            -- Value can be 12, 14, or 16 (14 is means 14-bit buried in 16-bit)
-- C_AdcWireInt         -- 0 = 1-wire, 1 = 2-wire
-- C_FrmPattern         -- Pattern to lock the frame to.
--
-- A 14 or 16 bit ADC in 2-wire mode has a 8-bit frame pattern. The C_FrmPattern parameter
-- must be set to:  C_FrmPattern ==> "0000000011110000".
-- The frame pattern does not use the upper 8-bits of the pattern because the frame Pattern
-- is only 8-bit wide.
-- A 14 or 16 bit ADC in 1-wire mode has a 16-bit frame pattern. The C_FrmPattern parameter
-- must be set to:  C_FrmPattern ==> "1111111100000000".
-- The frame pattern uses the full 16-bit of the pattern.
-- The same applies for a 12-bit ADC device.
--      C_FrmPattern        : string    := "111111000000";      -- 1-wire, 12 bit.
--      C_FrmPattern        : string    := "000000111000";      -- 2-wire, 12 bit.
--
-- C_StatTaps           -- Number of taps the IDELAY starts from (Middle of the Tap chain).
-- C_IdelayCtrlLoc      -- Hard location of the IDELAYCTRL component.
--      PORTS
-- DATA_n           -- I -- ADC data input signals from the ADC device.
-- DATA_p           -- I --
-- DCLK_n, DCLK_p   -- I -- High speed clock from the ADC device.
-- FCLK_n, FCLK_p   -- I -- Word or frame clock from the ADC device.
-- SysRefClk        -- I -- Reference clock for IDELAYCTRL (200 MHz).
-- AdcIntrfcRst     -- I -- Reset for the interface from the application.
-- AdcIntrfcEna     -- I -- Enable signal for the interface from the application.
-- AdcReSync        -- I -- Signal to restart the resync process.
-- AdcFrmSyncWrn    -- O -- Warning from the sync logic, alignment is not possible
-- AdcBitClkAlgnWrn -- O -- Status signal. BitClock adjusted.
-- AdcBitClkInvrtd  -- O -- Bit clock state, rising or falling
-- AdcBitClkDone    -- O -- Bit clock alignment done
-- AdcIdlyCtrlRdy   -- O -- IDELAYCTRL ready
-- AdcFrmDataOut    -- O -- Frame clock pattern as data (normally not used)
-- AdcMemClk        -- I -- Application clock to the clock crossing buffer
-- AdcMemRst		-- I -- Application reset to the clock crossing memory
-- AdcMemEna        -- I -- Application enable for the clock crossing memory
-- AdcMemDataOut    -- O -- Data output to the application or the BRAM data buffer.
-- AdcMemFlags      -- O -- Memory status flags, 2-wire = 8 flag bits, 1-wire = 4 flag bits
-- AdcMemFull       -- O -- Already decoded flag bit.
-- AdcMemEmpty      -- O -- Already decoded flag bit. 2-wire = 2 bits and 1-wire
-----------------------------------------------------------------------------------------------
entity AdcToplevel is
	generic (
        C_AdcChnls          : integer := 2;     -- Number of ADC in a package
        C_AdcWireInt        : integer := 2;     -- 2 = 2-wire, 1 = 1-wire interface
        C_BufioLoc          : string  := "BUFIO_X0Y6";
        C_BufrLoc           : string  := "BUFR_X0Y6";
        C_AdcBits           : integer := 16;
        C_StatTaps          : integer := 16;
		C_AdcUseIdlyCtrl	: integer := 1;	     -- 0 = No, 1 = Yes
		C_AdcIdlyCtrlLoc	: string  := "IDELAYCTRL_X0Y1";
		C_FrmPattern        : string  := "0000000011110000"  -- Read above text!
	);
    port (
		DCLK_p	           : in std_logic;
		DCLK_n	           : in std_logic;  -- Not used.
		FCLK_p	           : in std_logic;
		FCLK_n	           : in std_logic;
		DATA_p	           : in std_logic_vector((C_AdcChnls*C_AdcWireInt)-1 downto 0);
		DATA_n	           : in std_logic_vector((C_AdcChnls*C_AdcWireInt)-1 downto 0);
        -- application connections
        SysRefClk          : in std_logic;		-- 200 MHz for IODELAYCTRL from application
        AdcIntrfcRst       : in std_logic;
        AdcIntrfcEna       : in std_logic;
        AdcReSync          : in std_logic;
        AdcFrmSyncWrn      : out std_logic;
        AdcBitClkAlgnWrn   : out std_logic;
		AdcBitClkInvrtd    : out std_logic;
		AdcBitClkDone      : out std_logic;
		AdcIdlyCtrlRdy     : out std_logic;
			-- Data from the frame clock
        AdcFrmDataOut      : out std_logic_vector(15 downto 0);
        	-- ADC memory data output
        AdcMemClk          : in std_logic; -- Application clock
        AdcMemRst		   : in std_logic; -- Application reset
        AdcMemEna          : in std_logic; -- Application Enable
        AdcMemDataOut      : out std_logic_vector(((32/C_AdcWireInt)*((C_AdcChnls/2)*C_AdcWireInt))-1 downto 0);
        AdcMemFlags        : out std_logic_vector((4*(C_AdcChnls/2)*C_AdcWireInt)-1 downto 0);
        AdcMemFull         : out std_logic_vector(((C_AdcChnls/2)*C_AdcWireInt)-1 downto 0);
        AdcMemEmpty        : out std_logic_vector(((C_AdcChnls/2)*C_AdcWireInt)-1 downto 0);
        debug_bitslip_p	   : out std_logic;
        debug_bitslip_n    : out std_logic
    );
end AdcToplevel;
-----------------------------------------------------------------------------------------------
-- Arcitecture section
-----------------------------------------------------------------------------------------------
architecture AdcToplevel_struct of AdcToplevel  is
-----------------------------------------------------------------------------------------------
-- Component Instantiation
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- Constants, Signals and Attributes Declarations
-----------------------------------------------------------------------------------------------
-- Functions
function int_to_chr(int: integer) return character is
    variable temp : character;
begin
	case int is
		when  0 => temp := '0';
		when  1 => temp := '1';
		when  2 => temp := '2';
		when  3 => temp := '3';
		when  4 => temp := '4';
		when  5 => temp := '5';
		when  6 => temp := '6';
		when  7 => temp := '7';
		when  8 => temp := '8';
		when  9 => temp := '9';
		when 10 => temp := 'A';
		when 11 => temp := 'B';
		when 12 => temp := 'C';
		when 13 => temp := 'D';
		when 14 => temp := 'E';
		when 15 => temp := 'F';
		when 16 => temp := 'G';
		when 17 => temp := 'H';
		when 18 => temp := 'I';
		when 19 => temp := 'J';
		when 20 => temp := 'K';
		when 21 => temp := 'L';
		when 22 => temp := 'M';
		when 23 => temp := 'N';
		when 24 => temp := 'O';
		when 25 => temp := 'P';
		when 26 => temp := 'Q';
		when 27 => temp := 'R';
		when 28 => temp := 'S';
		when 29 => temp := 'T';
		when 30 => temp := 'U';
		when 31 => temp := 'V';
		when 32 => temp := 'W';
		when 33 => temp := 'X';
		when 34 => temp := 'Y';
		when 35 => temp := 'Z';
		when others => temp := '?';
	end case;
return temp;
end function int_to_chr;
--
function int_to_str(int: integer; base: integer) return string is
    variable temp:      string(1 to 10);
    variable num:       integer;
    variable abs_int:   integer;
    variable len:       integer := 1;
    variable power:     integer := 1;
begin
    abs_int := abs(int);	-- Negative numbers
    num     := abs_int;

    while num >= base loop                     -- Determine how many
      len := len + 1;                          -- characters required
      num := num / base;                       -- to represent the
    end loop ;                                 -- number.

    for i in len downto 1 loop        			        -- Convert the number to
      temp(i) := int_to_chr(abs_int/power mod base);	-- a string starting
      power := power * base;                   			-- with the right hand
    end loop ;                                	 		-- side.

    -- return result and add sign if required
    if int < 0 then
       return '-'& temp(1 to len);
     else
       return temp(1 to len);
    end if;
end function int_to_str;
-- In two wire mode a 12 bit ADC has 2 channels of 6 bits. The AdcBits stay at 12.
-- In two wire mode a 14 bit ADC has 2 channels of 8 bits. The AdcBits is set at 16.
-- In two wire mode a 16 bit ADC has 2 channels of 8 bits. The AdcBits stay at 16.
function AdcBits (Bits : integer) return integer is
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
end function AdcBits;
-- Constants
constant Low : std_logic := '0';
constant High : std_logic := '1';
-- Signals
signal IntIdlyCtrlRdy		: std_logic;
signal IntRst				: std_logic;
signal IntEna_d				: std_logic;
signal IntEna				: std_logic;
--
signal IntBitClkDone		: std_logic;
signal IntClk				: std_logic;
signal IntClkDiv			: std_logic;
signal IntClkBitSlip_p		: std_logic;
signal IntClkBitSlip_n		: std_logic;
signal IntClkSwapMux		: std_logic;
signal IntClkMsbRegEna		: std_logic;
signal IntClkLsbRegEna		: std_logic;
signal IntFrmClkReSyncOut	: std_logic;
signal IntDataOut 			: std_logic_vector((32*((C_AdcChnls/2)*C_AdcWireInt))-1 downto 0);
-- Attributes
attribute LOC : string;
attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of AdcToplevel_struct : architecture is "YES";
-----------------------------------------------------------------------------------------------
--
begin
	debug_bitslip_n <= IntClkBitSlip_n;
	debug_bitslip_p <= IntClkBitSlip_p;
-----------------------------------------------------------------------------------------------
-- IDELAYCTRL
-- An IDELAYCTRL component must be used per IO-bank. Normally a ADC port fits a whole
-- IO-Bank. The number of IDELAYCTRL components should thus fit with the number of ADC port.
-- In case of this test design, two ADC ports fit into one IO-Bank, thus only one IDLEAYCTRL
-- component is needed.
-- Don not forget to hook the outputs of the IDELAYCTRL components correctly to the reset and
-- enable for each ADC block.
-- Don not forget to LOC the IDELAYCTRL components down.
-----------------------------------------------------------------------------------------------
Gen_0 : if C_AdcUseIdlyCtrl = 0 generate
	AdcIdlyCtrlRdy <= High;
end generate Gen_0;
Gen_1 : if C_AdcUseIdlyCtrl = 1 generate
	attribute LOC of AdcToplevel_I_IdlyCtrl_0 : label is C_AdcIdlyCtrlLoc;
begin
	AdcToplevel_I_IdlyCtrl_0 : IDELAYCTRL
		port map (REFCLK => SysRefClk, RST => AdcIntrfcRst, RDY => AdcIdlyCtrlRdy);
end generate Gen_1;
-- IntRst and IntEna are the reset and enable signals to be used in the interface.
-- they are generated from the incoming system enable and reset.
AdcToplevel_I_Fdpe_Rst : FDPE
	generic map (INIT => '1')
	port map (C => IntClkDiv, CE => High, PRE => AdcIntrfcRst, D => Low, Q => IntRst);
AdcToplevel_I_Fdce_Ena_0 : FDCE
	generic map (INIT => '0')
	port map (C => IntClkDiv, CE => AdcIntrfcEna, CLR => IntRst, D => High, Q => IntEna_d);
AdcToplevel_I_Fdce_Ena_1 : FDCE
	generic map (INIT => '0')
	port map (C => IntClkDiv, CE => High, CLR => IntRst, D => IntEna_d, Q => IntEna);
-----------------------------------------------------------------------------------------------
-- C_AdcChnls		= c
-- C_AdcWireInt		= w
-- C_AdcBits		= b
-----------------------------------------------------------------------------------------------
-- BIT CLOCK
-- IntClk and IntClkDiv are the clock to be used in the interface.
-----------------------------------------------------------------------------------------------
-- There is no IBUFGDS used on this level of the design.
-- The IBUFGDS can be found in the AdcIo level or in the AdcToplevel_Toplevel.
-- That is this the reason why the DCLK_n is not used here.
-- At the AdcIo level the DCLK_n output is connected to GND.
-- Vivado complains about this with this message:
--    [Synth 8-3331] design AdcToplevel has unconnected port DCLK_n
AdcToplevel_I_AdcClock : entity AdcClock_Lib.AdcClock
generic map (
        C_BufioLoc      => C_BufioLoc,      -- string
        C_BufrLoc       => C_BufrLoc,       -- string
        C_AdcBits       => C_AdcBits,       -- integer
        C_StatTaps      => C_StatTaps       -- integer
    )
port map (
	BitClk				=> DCLK_p,			-- in
	BitClkRst			=> IntRst,			-- in
	BitClkEna			=> IntEna,			-- in
	BitClkReSync		=> AdcReSync,		-- in
	BitClk_MonClkOut	=> IntClk,			-- out	-->--|---->----
	BitClk_MonClkIn		=> IntClk,			-- in	--<--|
	BitClk_RefClkOut	=> IntClkDiv,		-- out	-->----|-->----
	BitClk_RefClkIn		=> IntClkDiv,		-- in	--<----|
	BitClkAlignWarn 	=> AdcBitClkAlgnWrn,-- out
	BitClkInvrtd		=> AdcBitClkInvrtd,	-- out
	BitClkDone 			=> IntBitClkDone	-- out Enables the AdcFrame block.
);
AdcBitClkDone <= IntBitClkDone;
-----------------------------------------------------------------------------------------------
-- WORD / FRAME CLOCK
-----------------------------------------------------------------------------------------------
AdcToplevel_I_AdcFrame : entity AdcFrame_Lib.AdcFrame
generic map (
	C_AdcBits			=> C_AdcBits,		-- integer;
	C_AdcWireInt		=> C_AdcWireInt,	-- integer;
	C_FrmPattern		=> C_FrmPattern  	-- string -- 1 or 2-wire, 12 or 16(14)-bit
)
port map (
	FrmClk_n		=> FCLK_n,			-- in input n from IBUFDS_DIFF_OUT
	FrmClk_p		=> FCLK_p,			-- in input p from IBUFDS_DIFF_OUT
	FrmClkRst		=> IntRst,			-- in
	FrmClkEna		=> IntEna,			-- in
	FrmClk			=> IntClk,			-- in
	FrmClkDiv		=> IntClkDiv,		-- in
	FrmClkDone		=> IntBitClkDone,	-- in From AdcClock done.
	FrmClkReSync	=> AdcReSync,		-- in
	FrmClkBitSlip_p	=> IntClkBitSlip_p,	-- out
	FrmClkBitSlip_n	=> IntClkBitSlip_n,	-- out
	FrmClkSwapMux	=> IntClkSwapMux,	-- out
	FrmClkMsbRegEna	=> IntClkMsbRegEna,	-- out
	FrmClkLsbRegEna	=> IntClkLsbRegEna,	-- out
	FrmClkReSyncOut	=> IntFrmClkReSyncOut,	-- out
	FrmClkDat		=> AdcFrmDataOut,		-- out
	FrmClkSyncWarn	=> AdcFrmSyncWrn		-- out
);
-----------------------------------------------------------------------------------------------
-- DATA INPUTS
-- Default the interface is set in BYTE and MSB first mode.
-- This is coded in the AdcData level and can be modified if wanted.
-- Enable the generics and all selection possibilities are available.
-----------------------------------------------------------------------------------------------
Gen_2 : for cw in ((C_AdcChnls/2)*C_AdcWireInt)-1 downto 0 generate
--	assert false
--	report int_to_str((32*((cw+1)+(p*C_AdcChnls))),10)
--	severity note;
	AdcToplevel_I_AdcData : entity AdcData_Lib.AdcData
	generic map (
		C_AdcBits		=> C_AdcBits,		-- Can be 12, 14 or 16
		C_AdcWireInt	=> C_AdcWireInt		-- 1 = 1-wire, 2 = 2-wire.
	)
	port map (
		DatD0_n			=> DATA_n(cw*2),		-- in
		DatD0_p			=> DATA_p(cw*2),		-- in
		DatD1_n			=> DATA_n((cw*2)+1),	-- in
		DatD1_p			=> DATA_p((cw*2)+1),	-- in
		DatClk			=> IntClk,				-- in
		DatClkDiv		=> IntClkDiv,			-- in
		DatRst			=> IntRst,				-- in
		DatEna			=> IntEna,				-- in
		DatDone			=> IntBitClkDone,		-- in
		DatBitSlip_p	=> IntClkBitSlip_p,		-- in
		DatBitSlip_n	=> IntClkBitSlip_n,		-- in
		DatSwapMux		=> IntClkSwapMux,		-- in
		DatMsbRegEna	=> IntClkMsbRegEna,		-- in
		DatLsbRegEna	=> IntClkLsbRegEna,		-- in
		DatReSync		=> IntFrmClkReSyncOut,	-- in
		DatOut			=> IntDataOut((32*(cw+1))-1 downto (32*(cw+1))-32)
	);
-----------------------------------------------------------------------------------------------
-- DATA STORAGE - CLOCK DOMAIN CROSSING - DISTRIBUTED RAM.
-----------------------------------------------------------------------------------------------
	AdcToplevel_I_AdcMem : entity AdcMem_Lib.AdcMem
		generic map (
			C_AdcWireInt 	=> C_AdcWireInt	-- 1 = 1-wire, 2 = 2-wire.
		)
		port map (
			ClkIn	=> IntClkDiv,	-- in
			EnaIn	=> IntEna, 		-- in
			RstIn	=> IntRst, 		-- in
			DatIn	=> IntDataOut((32*(cw+1))-1 downto (32*(cw+1))-(32/C_AdcWireInt)), -- in
			ClkOut	=> AdcMemClk,	-- in
			RstOut	=> AdcMemRst,	-- in
			EnaOut	=> AdcMemEna,	-- in
			DatOut	=> AdcMemDataOut(((32/C_AdcWireInt)*(cw+1))-1 downto ((32/C_AdcWireInt)*(cw+1))-(32/C_AdcWireInt)),
			Flags	=> AdcMemFlags((4*(cw+1))-1 downto (4*(cw+1))-4), -- out [3:0]
			Full    => AdcMemFull(cw), -- out
			Empty   => AdcMemEmpty(cw) -- out
		);
end generate Gen_2;
-----------------------------------------------------------------------------------------------
--
end AdcToplevel_struct;
