---------------------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /
-- \   \   \/    © Copyright 2012 Xilinx, Inc. All rights reserved.
--  \   \        This file contains confidential and proprietary information of Xilinx, Inc.
--  /   /        and is protected under U.S. and international copyright and other
-- /___/   /\    intellectual property laws.
-- \   \  /  \
--  \___\/\___\
--
---------------------------------------------------------------------------------------------
-- Device:              Virtex-6, 7-Series
-- Author:              Defossez
-- Entity Name:         Fdcr
-- Purpose:             FF with synchronous enable and reset (Does not use the CE and R/S
--                      inputs of the native FFs).
--                      The reason for making this FF is: in 7-series A SLICE has 8 FFs.
--                      All these FF share one connection of set and or reset what makes the
--                      use restricted.
--                      All FFs share also one connection for enable.
--                      This connection is share with the WE inputs of all LUTS.
-- Tools:               Vivado_2017.3 or later and higher
-- Limitations:         none
--
-- Vendor:              Xilinx Inc.
-- Version:             V0.02
-- Filename:            Fdcr.vhd
-- Date Created:        24 Jul, 2012
-- Date Last Modified:  12 Feb, 2018
---------------------------------------------------------------------------------------------
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
-- Contact:    e-mail  hotline@xilinx.com        phone   + 1 800 255 7778
---------------------------------------------------------------------------------------------
-- Revision History:
--  Rev. 12 Feb 2018 - Defossez
--      FD instantiation replaced by the Vivado libraries instantiation of a FDCE.
---------------------------------------------------------------------------------------------
-- Naming Conventions:
--  Generics start with:                                    "C_*"
--  Ports
--      All words in the label of a port name start with a upper case, AnInputPort.
--      Active low ports end in                             "*_n"
--      Active high ports of a differential pair end in:    "*_p"
--      Ports being device pins end in _pin                 "*_pin"
--      Reset ports end in:                                 "*Rst"
--      Enable ports end in:                                "*Ena", "*En"
--      Clock ports end in:                                 "*Clk", "ClkDiv", "*Clk#"
--  Signals and constants
--      Signals and constant labels start with              "Int*"
--      Registered signals end in                           "_d#"
--      User defined types:                                 "*_TYPE"
--      State machine next state:                           "*_Ns"
--      State machine current state:                        "*_Cs"
--      Counter signals end in:                             "*Cnt", "*Cnt_n"
--   Processes:                                 "<Entity_><Function>_PROCESS"
--   Component instantiations:                  "<Entity>_I_<Component>_<Function>"
---------------------------------------------------------------------------------------------
library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.std_logic_UNSIGNED.all;
library UNISIM;
	use UNISIM.vcomponents.all;
---------------------------------------------------------------------------------------------
-- Entity pin description
---------------------------------------------------------------------------------------------
entity Fdcr is
    generic (INIT : bit := '0');
	port (
		D     : in std_logic;
		CE    : in std_logic;
		C     : in std_logic;
		R     : in std_logic;
		Q     : out std_logic
	);
end Fdcr;
---------------------------------------------------------------------------------------------
-- Architecture section
---------------------------------------------------------------------------------------------
architecture Fdcr_struct of Fdcr is
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
signal IntDceR  : std_logic;
signal IntQ     : std_logic;
-- Attributes
attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of Fdcr_struct : architecture is "NO";
---------------------------------------------------------------------------------------------
begin
--
Fdcr_Case : process (IntQ, R, CE, D)
subtype LutOut is std_logic_vector(3 downto 0);
begin
    case LutOut'(IntQ & R & CE & D) is
        when "0011" => IntDceR <= '1';
        when "1000" => IntDceR <= '1';
        when "1001" => IntDceR <= '1';
        when "1011" => IntDceR <= '1';
        when others => IntDceR <= '0';
    end case;
end process Fdcr_Case;
--Fdcr_I_Lut4 : LUT4
--    generic map (INIT => X"0B08")
--    port map (I3 => IntQ, I2 => R, I1 => CE, I0 => D, O => IntDceR);
--
Q <= IntQ;
--
Fdcr_I_Fd : FDCE
    generic map (
        INIT            => '0',
        IS_CLR_INVERTED => '0',
        IS_C_INVERTED   => '0',
        IS_D_INVERTED   => '0'
    )
    port map (
        D   =>  IntDceR,
        C   =>  C,
        CE  =>  High,
        CLR =>  Low,
        Q   =>  IntQ
    );
----------------------------------------------------------------------------------------------
end Fdcr_struct;
