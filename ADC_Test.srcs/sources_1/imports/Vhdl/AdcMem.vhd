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
--  \   \        Filename:  AdcMem.vhd
--  /   /        Date Last Modified:    12 Feb 18
-- /___/   /\    Date Created:          04 Apr 08
-- \   \  /  \
--  \___\/\___\
--
-- Device:		Virtex-6, 7-Series
-- Author:		Marc Defossez
-- Entity Name:	AdcMem
-- Purpose: 	Clock domain crossing data buffer made from distributed memory.
-- Tools:		Vivado_2017.3 or later
-- Limitations: none
--
-- Revision History:
--      Rev. 12 Feb 18 - Defossez
--      Adapted the instantiated components to the components from Vivado UNISIM libraries.
--      Changed the FDRSE (native Virtex) by a equivalent complex component.
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
	use UNISIM.vcomponents.all;
library Common;
	use Common.all;
-----------------------------------------------------------------------------------------------
-- Entity pin description
-----------------------------------------------------------------------------------------------
entity AdcMem is
	generic (
		C_AdcWireInt 	: integer		-- 1 = 1-wire, 2 = 2-wire.
	);
    port (
        ClkIn	: in std_logic;
        EnaIn	: in std_logic;
        RstIn	: in std_logic;
        DatIn	: in std_logic_vector((32/C_AdcWireInt)-1 downto 0);
        ClkOut	: in std_logic;
        RstOut	: in std_logic;
        EnaOut	: in std_logic;
        DatOut	: out std_logic_vector((32/C_AdcWireInt)-1 downto 0);
        Flags	: out std_logic_vector(3 downto 0);
        Full    : out std_logic;
        Empty   : out std_logic
    );
end AdcMem;
-----------------------------------------------------------------------------------------------
-- Arcitecture section
-----------------------------------------------------------------------------------------------
architecture AdcMem_struct of AdcMem  is
-----------------------------------------------------------------------------------------------
-- Component Instantiation
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-- Constants, Signals and Attributes Declarations
-----------------------------------------------------------------------------------------------
-- Functions
-- Constants
constant Low  : std_logic	:= '0';
constant High : std_logic	:= '1';
-- Signals
signal IntRamToFf		: std_logic_vector((32/C_AdcWireInt)-1 downto 0);
signal IntWrAddr		: std_logic_vector(4 downto 0);
signal IntRdAddr		: std_logic_vector(4 downto 0);
signal IntFlags			: std_logic_vector(3 downto 0);
-- signal IntFlagEna 		: std_logic;
-- Attributes
attribute RLOC : string;
attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of AdcMem_struct : architecture is "YES";
-----------------------------------------------------------------------------------------------
begin
-- MEMORY
-----------------------------------------------------------------------------------------------
Gen_1 : for n in (32/C_AdcWireInt)-1 downto 0 generate
	AdcMem_I_Ram64x1d : RAM32X1D
 		generic	map (
            INIT                => X"00000000",
            IS_WCLK_INVERTED    => '0'
        )
	 	port map (
	 		D		=> DatIn(n),	-- in
 			A0		=> IntWrAddr(0),	-- in
 			A1		=> IntWrAddr(1),	-- in
	 		A2		=> IntWrAddr(2),	-- in
	 		A3		=> IntWrAddr(3),	-- in
 			A4		=> IntWrAddr(4),	-- in
	 		WE		=> High,		-- in
	 		WCLK	=> ClkIn,		-- in
 			DPRA0	=> IntRdAddr(0),	-- in
 			DPRA1	=> IntRdAddr(1),	-- in
	 		DPRA2	=> IntRdAddr(2),	-- in
	 		DPRA3	=> IntRdAddr(3),	-- in
 			DPRA4	=> IntRdAddr(4),	-- in
	 		DPO		=> IntRamToFf(n),-- out
	 		SPO		=> open	-- out
 		);
	AdcMem_I_Fdce : FDCE
		generic map (
            INIT            => '0',
            IS_CLR_INVERTED => '0',
            IS_C_INVERTED   => '0',
            IS_D_INVERTED   => '0'
        )
		port map (
            D => IntRamToFf(n),
            C => ClkOut,
            CE => EnaOut,
            CLR => RstOut,
            Q => DatOut(n)
        );
end generate Gen_1;
-----------------------------------------------------------------------------------------------
-- READ and WRITE ADDRESS COUNTERS
-----------------------------------------------------------------------------------------------
-- Write counter
AdcMem_I_WrAddrCnt : entity Common.Cnt_5b_Bin
	port map (
		CntClk	=> ClkIn,
		CntEna	=> EnaIn,
		CntRst	=> RstIn,
		CntOut	=> IntWrAddr,
        CntTc   => open
	);
-- Read counter
-- Write counter
AdcMem_I_RdAddrCnt : entity Common.Cnt_5b_Bin
	port map (
		CntClk	=> ClkOut,
		CntEna	=> EnaOut,
		CntRst	=> RstOut,
		CntOut	=> IntRdAddr,
        CntTc   => open
	);
------------------------------------------------------------------------------------------------
-- Flags.
-- Four write flags are decoded
--		memory is filled between empty and 1/4 = IntFlag(0) -- Empty
--		memory is filled between 1/4 and 1/2 = IntFlag(1) -- Low Half
--		memory is filled between 1/2 and 3/4 = IntFlag(2) -- High Half
--		memory is filled between 3/4 and Full = IntFlag(3) -- Full
-- The flags are registered at the read or application clock for signalling to the application
-- Interface. One flag is used as auto-enable of the read counter.
-- This flag can be any flag, but here is chosen to register the Low and High flags
-- so that a natural spread and fill of the memory occurs.
-----------------------------------------------------------------------------------------------
-- Full
	IntFlags(3) <=	'1' when IntWrAddr(4 downto 3) = "11" and IntRdAddr(4 downto 3) = "00" else
					'1' when IntWrAddr(4 downto 3) = "10" and IntRdAddr(4 downto 3) = "11" else
					'1' when IntWrAddr(4 downto 3) = "01" and IntRdAddr(4 downto 3) = "10" else
					'1' when IntWrAddr(4 downto 3) = "00" and IntRdAddr(4 downto 3) = "01" else
					'0';
-- High Half
	IntFlags(2) <=	'1' when IntWrAddr(4 downto 3) = "11" and IntRdAddr(4 downto 3) = "01" else
					'1' when IntWrAddr(4 downto 3) = "10" and IntRdAddr(4 downto 3) = "00" else
					'1' when IntWrAddr(4 downto 3) = "01" and IntRdAddr(4 downto 3) = "11" else
					'1' when IntWrAddr(4 downto 3) = "00" and IntRdAddr(4 downto 3) = "10" else
					'0';
-- Low half
	IntFlags(1) <=	'1' when IntWrAddr(4 downto 3) = "11" and IntRdAddr(4 downto 3) = "10" else
					'1' when IntWrAddr(4 downto 3) = "10" and IntRdAddr(4 downto 3) = "01" else
					'1' when IntWrAddr(4 downto 3) = "01" and IntRdAddr(4 downto 3) = "00" else
					'1' when IntWrAddr(4 downto 3) = "00" and IntRdAddr(4 downto 3) = "11" else
					'0';
-- Empty
	IntFlags(0) <=	'1' when IntWrAddr(4 downto 3) = "11" and IntRdAddr(4 downto 3) = "11" else
					'1' when IntWrAddr(4 downto 3) = "10" and IntRdAddr(4 downto 3) = "10" else
					'1' when IntWrAddr(4 downto 3) = "01" and IntRdAddr(4 downto 3) = "01" else
					'1' when IntWrAddr(4 downto 3) = "00" and IntRdAddr(4 downto 3) = "00" else
					'0';
-- Flag registering.
--Gen_2 : for n in 0 to 3 generate
--    AdcMem_I_Fdce : FDCE
--        port map (D => IntFlags(n), CE => High, C => ClkOut, CLR => RstOut, Q => Flags(n));
--end generate Gen_2;
-- Combinatorial flags output.
Flags <= Intflags;
--
-- Ping-Pong Full and Empty Flags
DataMem_I_Fdrse_E : entity Common.Fdrse
    port map(S => IntFlags(0), D => Low, CE => Low, C => ClkOut, R => IntFlags(3), Q => Empty);
DataMem_I_Fdrse_F : entity Common.Fdrse
    port map(S => IntFlags(3), D => Low, CE => Low, C => ClkIn, R => IntFlags(0), Q => Full);
--
-----------------------------------------------------------------------------------------------
end  AdcMem_struct;
