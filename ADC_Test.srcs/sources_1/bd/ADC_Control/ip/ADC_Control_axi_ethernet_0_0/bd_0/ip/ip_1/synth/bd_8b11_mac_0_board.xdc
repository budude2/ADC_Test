#--------------------Physical Constraints-----------------

set_property BOARD_PIN {eth_rgmii_rxc} [get_ports rgmii_rxc]
set_property BOARD_PIN {eth_rgmii_rx_ctl} [get_ports rgmii_rx_ctl]
set_property BOARD_PIN {eth_rgmii_rd_0} [get_ports rgmii_rxd[0]]

set_property BOARD_PIN {eth_rgmii_rd_1} [get_ports rgmii_rxd[1]]

set_property BOARD_PIN {eth_rgmii_rd_2} [get_ports rgmii_rxd[2]]

set_property BOARD_PIN {eth_rgmii_rd_3} [get_ports rgmii_rxd[3]]

set_property BOARD_PIN {eth_rgmii_txc} [get_ports rgmii_txc]
set_property BOARD_PIN {eth_rgmii_tx_ctl} [get_ports rgmii_tx_ctl]
set_property BOARD_PIN {eth_rgmii_td_0} [get_ports rgmii_txd[0]]

set_property BOARD_PIN {eth_rgmii_td_1} [get_ports rgmii_txd[1]]

set_property BOARD_PIN {eth_rgmii_td_2} [get_ports rgmii_txd[2]]

set_property BOARD_PIN {eth_rgmii_td_3} [get_ports rgmii_txd[3]]

set_property BOARD_PIN {eth_mdc} [get_ports mdc]
set_property BOARD_PIN {eth_mdio_i} [get_ports mdio_t]
