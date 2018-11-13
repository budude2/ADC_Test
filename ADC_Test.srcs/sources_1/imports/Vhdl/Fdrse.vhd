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
-- Entity Name:         Fdrse
-- Purpose:             D Flip-Flop with Synchronous Reset and Set and Clock Enable
--              LUT         FDRE
--            |-----|      |-----|
--       D----|     |-CQ---|D   Q|----
--       S----|     |    --|CE   |
--       R-+--|     |    --|>C   |
--         |  |-----|      |---+-|
--         +-------------------|
--
--         | D | R | S | CQ | C | CE | Q |
--         |---|---|---|----|---|----|---|  R = rising clock edge
--         | x | 1 | x | 0  | R |  1 | 0 |  Q = 0 by R of FF.
--         | x | 0 | 1 | 1  | R |  1 | 1 |
--         | 1 | 0 | 0 | 1  | R |  1 | 1 |
--         | 0 | 0 | 0 | 0  | R |  1 | 0 |
--         | x | 1 | 1 | 0  | R |  1 | 0 |  Q = 0 by R of FF.
--         | x | 0 | 0 | x  | R |  0 | U |  Q = Unchanged by CE of FF.
--         |   |   |   |    |   |    |   |
--
-- Limitations:         none
--
-- Vendor:              Xilinx Inc.
-- Version:             V0.02
-- Filename:            Fdrse.vhd
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
entity Fdrse is
    generic (
        INIT            : bit := '0';
        IS_R_INVERTED   : bit := '0';
        IS_C_INVERTED   : bit := '0';
        IS_D_INVERTED   : bit := '0'
    );
	port (
		D     : in std_logic;
		CE    : in std_logic;
		C     : in std_logic;
        S     : in std_logic;
		R     : in std_logic;
		Q     : out std_logic
	);
end Fdrse;
---------------------------------------------------------------------------------------------
-- Architecture section
---------------------------------------------------------------------------------------------
architecture Fdrse_struct of Fdrse is
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
signal IntQ     : std_logic;
signal intO     : std_logic;
-- Attributes
attribute KEEP_HIERARCHY : string;
    attribute KEEP_HIERARCHY of Fdrse_struct : architecture is "YES";
attribute U_SET : string;
    attribute U_SET of Fdrse_Case : label is "C_fdrse";
    attribute U_SET of Fdrse_I_Fd : label is "C_fdrse";
---------------------------------------------------------------------------------------------
begin
--
Fdrse_Case : process (IntQ, D, CE, S)
subtype LutOut is std_logic_vector(3 downto 0);
begin
    case LutOut'(IntQ & D & CE & S) is
        when "0000" => IntO <= '0'; -- IntQ = 0, rest = 0 thus O/Q = 0
        when "0001" => IntO <= '1'; -- Set = 1 thus O/Q = 1
        when "0010" => IntO <= '0'; -- CE = 1, D = 0, IntQ = 0 thus O/Q = 0
        when "0011" => IntO <= '1'; -- Set = 1 thus O/Q = 1
        when "0100" => IntO <= '0'; -- CE = 0, IntQ = 0 thus O/Q = 0
        when "0101" => IntO <= '1'; -- Set = 1 thus O/Q = 1
        when "0110" => IntO <= '1'; -- CE = 1, D = 1 IntQ = 0 thus O/Q = 1
        when "0111" => IntO <= '1'; -- Set = 1 thus O/Q = 1
        when "1000" => IntO <= '1'; -- IntQ = 1 Thus )/Q = 1
        when "1001" => IntO <= '1'; -- Set = 1 thus O/Q = 1
        when "1010" => IntO <= '0'; -- CE = 1, D = 0 IntQ = 1 thus O/Q = 0
        when "1011" => IntO <= '1'; -- Set = 1 thus O/Q = 1
        when "1100" => IntO <= '1'; -- CE = 0, IntQ = 1 thus O/Q = 1
        when "1101" => IntO <= '1'; -- Set = 1 thus O/Q = 1
        when "1110" => IntO <= '1'; -- CE = 1, IntQ & D = 1 thus O/Q = 1
        -- when "1111" => IntO <= '1';
        when others => IntO <= '1'; -- Set = 1 thus O/Q = 1
    end case;
end process Fdrse_Case;
--
Q <= IntQ;
--
Fdrse_I_Fd : FDRE
    generic map (
        INIT            => INIT,
        IS_R_INVERTED   => IS_R_INVERTED,
        IS_C_INVERTED   => IS_C_INVERTED,
        IS_D_INVERTED   => IS_D_INVERTED
    )
    port map (
        D   =>  IntO,
        C   =>  C,
        CE  =>  High,
        R   =>  R,
        Q   =>  IntQ
    );
----------------------------------------------------------------------------------------------
end Fdrse_struct;
