//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
//Date        : Tue Nov 27 22:44:33 2018
//Host        : DESKTOP-S0CCCTL running 64-bit major release  (build 9200)
//Command     : generate_target ADC_Control_wrapper.bd
//Design      : ADC_Control_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module ADC_Control_wrapper
   (ADC_CSB1,
    ADC_CSB2,
    ADC_SCLK,
    ADC_SDIO,
    O,
    clk_100m,
    clk_125m,
    clk_200m,
    clk_50m,
    cpu_resetn,
    dcm_locked,
    eth_mdio_mdc_0_mdc,
    eth_mdio_mdc_0_mdio_io,
    eth_rgmii_0_rd,
    eth_rgmii_0_rx_ctl,
    eth_rgmii_0_rxc,
    eth_rgmii_0_td,
    eth_rgmii_0_tx_ctl,
    eth_rgmii_0_txc,
    phy_reset_out,
    usb_uart_rxd,
    usb_uart_txd);
  output [0:0]ADC_CSB1;
  output [0:0]ADC_CSB2;
  output ADC_SCLK;
  inout ADC_SDIO;
  output [31:0]O;
  input clk_100m;
  input clk_125m;
  input clk_200m;
  input clk_50m;
  input cpu_resetn;
  input dcm_locked;
  output eth_mdio_mdc_0_mdc;
  inout eth_mdio_mdc_0_mdio_io;
  input [3:0]eth_rgmii_0_rd;
  input eth_rgmii_0_rx_ctl;
  input eth_rgmii_0_rxc;
  output [3:0]eth_rgmii_0_td;
  output eth_rgmii_0_tx_ctl;
  output eth_rgmii_0_txc;
  output [0:0]phy_reset_out;
  input usb_uart_rxd;
  output usb_uart_txd;

  wire [0:0]ADC_CSB1;
  wire [0:0]ADC_CSB2;
  wire ADC_SCLK;
  wire ADC_SDIO;
  wire [31:0]O;
  wire clk_100m;
  wire clk_125m;
  wire clk_200m;
  wire clk_50m;
  wire cpu_resetn;
  wire dcm_locked;
  wire eth_mdio_mdc_0_mdc;
  wire eth_mdio_mdc_0_mdio_i;
  wire eth_mdio_mdc_0_mdio_io;
  wire eth_mdio_mdc_0_mdio_o;
  wire eth_mdio_mdc_0_mdio_t;
  wire [3:0]eth_rgmii_0_rd;
  wire eth_rgmii_0_rx_ctl;
  wire eth_rgmii_0_rxc;
  wire [3:0]eth_rgmii_0_td;
  wire eth_rgmii_0_tx_ctl;
  wire eth_rgmii_0_txc;
  wire [0:0]phy_reset_out;
  wire usb_uart_rxd;
  wire usb_uart_txd;

  ADC_Control ADC_Control_i
       (.ADC_CSB1(ADC_CSB1),
        .ADC_CSB2(ADC_CSB2),
        .ADC_SCLK(ADC_SCLK),
        .ADC_SDIO(ADC_SDIO),
        .O(O),
        .clk_100m(clk_100m),
        .clk_125m(clk_125m),
        .clk_200m(clk_200m),
        .clk_50m(clk_50m),
        .cpu_resetn(cpu_resetn),
        .dcm_locked(dcm_locked),
        .eth_mdio_mdc_0_mdc(eth_mdio_mdc_0_mdc),
        .eth_mdio_mdc_0_mdio_i(eth_mdio_mdc_0_mdio_i),
        .eth_mdio_mdc_0_mdio_o(eth_mdio_mdc_0_mdio_o),
        .eth_mdio_mdc_0_mdio_t(eth_mdio_mdc_0_mdio_t),
        .eth_rgmii_0_rd(eth_rgmii_0_rd),
        .eth_rgmii_0_rx_ctl(eth_rgmii_0_rx_ctl),
        .eth_rgmii_0_rxc(eth_rgmii_0_rxc),
        .eth_rgmii_0_td(eth_rgmii_0_td),
        .eth_rgmii_0_tx_ctl(eth_rgmii_0_tx_ctl),
        .eth_rgmii_0_txc(eth_rgmii_0_txc),
        .phy_reset_out(phy_reset_out),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd));
  IOBUF eth_mdio_mdc_0_mdio_iobuf
       (.I(eth_mdio_mdc_0_mdio_o),
        .IO(eth_mdio_mdc_0_mdio_io),
        .O(eth_mdio_mdc_0_mdio_i),
        .T(eth_mdio_mdc_0_mdio_t));
endmodule
