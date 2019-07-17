## Ethernet

#set_property -dict {PACKAGE_PIN AK16 IOSTANDARD LVCMOS18} [get_ports eth_int_b]
#set_property -dict {PACKAGE_PIN AF12 IOSTANDARD LVCMOS15} [get_ports eth_mdc]
#set_property -dict {PACKAGE_PIN AG12 IOSTANDARD LVCMOS15} [get_ports eth_mdio]
set_property -dict {PACKAGE_PIN AH24 IOSTANDARD LVCMOS33 SLEW FAST DRIVE 16} [get_ports ETH_PHYRST_N]
#set_property -dict {PACKAGE_PIN AK15 IOSTANDARD LVCMOS18} [get_ports eth_pme_b]
set_property -dict {PACKAGE_PIN AG10 IOSTANDARD LVCMOS15} [get_ports eth_rxck]
set_property -dict {PACKAGE_PIN AH11 IOSTANDARD LVCMOS15} [get_ports eth_rxctl]
set_property -dict {PACKAGE_PIN AJ14 IOSTANDARD LVCMOS15} [get_ports {eth_rxd[0]}]
set_property -dict {PACKAGE_PIN AH14 IOSTANDARD LVCMOS15} [get_ports {eth_rxd[1]}]
set_property -dict {PACKAGE_PIN AK13 IOSTANDARD LVCMOS15} [get_ports {eth_rxd[2]}]
set_property -dict {PACKAGE_PIN AJ13 IOSTANDARD LVCMOS15} [get_ports {eth_rxd[3]}]
set_property -dict {PACKAGE_PIN AE10 IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports eth_txck]
set_property -dict {PACKAGE_PIN AJ12 IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports {eth_txd[0]}]
set_property -dict {PACKAGE_PIN AK11 IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports {eth_txd[1]}]
set_property -dict {PACKAGE_PIN AJ11 IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports {eth_txd[2]}]
set_property -dict {PACKAGE_PIN AK10 IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports {eth_txd[3]}]
set_property -dict {PACKAGE_PIN AK14 IOSTANDARD LVCMOS15 SLEW FAST DRIVE 16} [get_ports ETH_TX_EN]
create_clock -period 8.000 -name phy_rx_clk -waveform {0.000 4.000} -add [get_ports eth_rxck]
set_clock_groups -asynchronous -group [get_clocks phy_rx_clk -include_generated_clocks]

# IDELAY on RGMII from PHY chip
set_property IDELAY_VALUE 0 [get_cells {phy_rx_ctl_idelay phy_rxd_idelay_*}]

# Autogen stuff
set_property ASYNC_REG true [get_cells -hier -regexp {.*/tx_mii_select_sync_reg\[\d\]} -filter {PARENT == i_eth/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst}]
set_max_delay -datapath_only -from [get_cells i_eth/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst/mii_select_reg_reg] -to [get_cells {i_eth/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst/tx_mii_select_sync_reg[0]}] 8.000
set_property ASYNC_REG true [get_cells -hier -regexp {.*/rx_mii_select_sync_reg\[\d\]} -filter {PARENT == i_eth/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst}]
set_max_delay -datapath_only -from [get_cells i_eth/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst/mii_select_reg_reg] -to [get_cells {i_eth/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst/rx_mii_select_sync_reg[0]}] 8.000
set_property ASYNC_REG true [get_cells -hier -regexp {.*/rx_prescale_sync_reg\[\d\]} -filter {PARENT == i_eth/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst}]
set_max_delay -datapath_only -from [get_cells {i_eth/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst/rx_prescale_reg[2]}] -to [get_cells {i_eth/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst/rx_prescale_sync_reg[0]}] 8.000
set_property ASYNC_REG true [get_cells -hier -regexp {.*/(rx|tx)_rst_reg_reg\[\d\]} -filter {PARENT == i_eth/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst/rgmii_phy_if_inst}]
set_false_path -to [get_pins -of_objects [get_cells -hier -regexp {.*/(rx|tx)_rst_reg_reg\[\d\]} -filter {PARENT == i_eth/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst/rgmii_phy_if_inst}] -filter {IS_PRESET || IS_RESET}]
set_property ASYNC_REG true [get_cells {i_eth/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst/rgmii_phy_if_inst/clk_oddr_inst/oddr[0].oddr_inst}]
set_max_delay -datapath_only -from [get_cells i_eth/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst/rgmii_phy_if_inst/rgmii_tx_clk_1_reg] -to [get_cells {i_eth/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst/rgmii_phy_if_inst/clk_oddr_inst/oddr[0].oddr_inst}] 2.000
set_max_delay -datapath_only -from [get_cells i_eth/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst/rgmii_phy_if_inst/rgmii_tx_clk_2_reg] -to [get_cells {i_eth/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst/rgmii_phy_if_inst/clk_oddr_inst/oddr[0].oddr_inst}] 2.000
