onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Clocks
add wave -noupdate /bufferTB/clk_100m
add wave -noupdate /bufferTB/clk_50m
add wave -noupdate /bufferTB/clk_125m
add wave -noupdate /bufferTB/clk_125m90
add wave -noupdate /bufferTB/SysRefClk_p
add wave -noupdate /bufferTB/SysRefClk_n
add wave -noupdate /bufferTB/dcm_locked
add wave -noupdate /bufferTB/rst_125m_n
add wave -noupdate /bufferTB/rst_125m
add wave -noupdate /bufferTB/adc_rst_n
add wave -noupdate /bufferTB/cpu_resetn
add wave -noupdate -divider Buffer
add wave -noupdate /bufferTB/start
add wave -noupdate /bufferTB/tick
add wave -noupdate /bufferTB/en_wr
add wave -noupdate /bufferTB/rd_en
add wave -noupdate /bufferTB/empty
add wave -noupdate /bufferTB/full
add wave -noupdate /bufferTB/addr
add wave -noupdate /bufferTB/dout1
add wave -noupdate /bufferTB/dout2
add wave -noupdate /bufferTB/dout3
add wave -noupdate /bufferTB/dout4
add wave -noupdate /bufferTB/dout7
add wave -noupdate /bufferTB/dout8
add wave -noupdate -divider ETH
add wave -noupdate /bufferTB/eth_txck
add wave -noupdate /bufferTB/eth_txd
add wave -noupdate /bufferTB/ETH_TX_EN
add wave -noupdate /bufferTB/eth_en
add wave -noupdate /bufferTB/eth_data
add wave -noupdate /bufferTB/eth_tready
add wave -noupdate /bufferTB/eth_data_tlast
add wave -noupdate -label eth_state /bufferTB/eth_i/udp_tx_i/eth_axis_tx_i/state_reg
add wave -noupdate -label ip_state /bufferTB/eth_i/udp_tx_i/ip_eth_tx_i/state_reg
add wave -noupdate -label udp_state /bufferTB/eth_i/udp_tx_i/udp_ip_tx_i/state_reg
add wave -noupdate -label mac_state /bufferTB/eth_i/eth_mac_1g_rgmii_fifo_i/eth_mac_1g_rgmii_inst/eth_mac_1g_inst/axis_gmii_tx_inst/state_reg
add wave -noupdate -divider RC
add wave -noupdate /bufferTB/readController/curr_state
add wave -noupdate /bufferTB/readController/next_state
add wave -noupdate /bufferTB/readController/count_curr
add wave -noupdate /bufferTB/readController/count_next
TreeUpdate [SetDefaultTree]
quietly WaveActivateNextPane
WaveRestoreCursors {{Cursor 2} {265909600 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 230
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {9115828 ps}
