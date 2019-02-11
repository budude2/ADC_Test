----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz> 
-- 
-- Module Name: tx_interface - Behavioral
-- 
-- Description: To send data streams out to an Ethernet PHY over RGMII 
-- 
------------------------------------------------------------------------------------
-- FPGA_Webserver from https://github.com/hamsternz/FPGA_Webserver
------------------------------------------------------------------------------------
-- The MIT License (MIT)
-- 
-- Copyright (c) 2015 Michael Alan Field <hamster@snap.net.nz>
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tx_interface is
    Port ( clk125MHz   : in  STD_LOGIC;
           clk125Mhz90 : in  STD_LOGIC;
           --
           phy_ready   : in  STD_LOGIC;
           ---
           udp_valid   : in  STD_LOGIC;
           udp_data    : in  STD_LOGIC_VECTOR (7 downto 0);
           ---
           eth_txck    : out STD_LOGIC;
           eth_txctl   : out STD_LOGIC;
           eth_txd     : out STD_LOGIC_VECTOR (3 downto 0));
end tx_interface;

architecture Behavioral of tx_interface is

    component tx_add_crc32 is
    Port ( clk             : in  STD_LOGIC;
           data_valid_in   : in  STD_LOGIC                     := '0';
           data_in         : in  STD_LOGIC_VECTOR (7 downto 0);
           data_valid_out  : out STD_LOGIC                     := '0';
           data_out        : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0'));
    end component;

    component tx_add_preamble is
    Port ( clk             : in  STD_LOGIC;
           data_valid_in   : in  STD_LOGIC;
           data_in         : in  STD_LOGIC_VECTOR (7 downto 0);
           data_valid_out  : out STD_LOGIC                     := '0';
           data_out        : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0'));
    end component;

    signal with_crc_data_valid  : STD_LOGIC;
    signal with_crc_data        : STD_LOGIC_VECTOR (7 downto 0);
    
    signal framed_data_valid  : STD_LOGIC;
    signal framed_data        : STD_LOGIC_VECTOR (7 downto 0);

    signal data        : STD_LOGIC_VECTOR (7 downto 0);
    signal data_valid  : STD_LOGIC;
    signal data_enable : STD_LOGIC;
    signal data_error  : STD_LOGIC;

    component tx_rgmii is
    Port ( clk         : in STD_LOGIC;
           clk90       : in STD_LOGIC;
           phy_ready   : in STD_LOGIC;

           data_valid  : in STD_LOGIC;
           data        : in STD_LOGIC_VECTOR (7 downto 0);
           data_error  : in STD_LOGIC;
           data_enable : in STD_LOGIC := '1';
           
           eth_txck    : out STD_LOGIC;
           eth_txctl   : out STD_LOGIC;
           eth_txd     : out STD_LOGIC_VECTOR (3 downto 0));
    end component ;
begin

i_tx_add_crc32: tx_add_crc32 port map (
    clk              => clk125MHz,
    data_valid_in    => udp_valid,
    data_in          => udp_data,
    data_valid_out   => with_crc_data_valid,
    data_out         => with_crc_data);

i_tx_add_preamble: tx_add_preamble port map (
    clk             => clk125MHz,
    data_valid_in   => with_crc_data_valid,
    data_in         => with_crc_data,
    data_valid_out  => framed_data_valid,
    data_out        => framed_data);

i_tx_rgmii: tx_rgmii port map (
    clk         => clk125MHz,
    clk90       => clk125MHz90,
    phy_ready   => phy_ready,

    data_valid  => framed_data_valid,
    data        => framed_data,
    data_error  => '0',
    data_enable => '1',

    eth_txck  => eth_txck,
    eth_txctl => eth_txctl,
    eth_txd   => eth_txd);

end Behavioral;
