`timescale 1ns / 1ps

module top
(
    input  logic SysRefClk_p,
    input  logic SysRefClk_n,
    input  logic cpu_resetn,
    input  logic btnc,

    output logic led0,
    output logic led1,
    output logic led2,
    output logic led3,

    // ADC Data Interface
    input  logic DCLK_p_pin,
    input  logic DCLK_n_pin,
    input  logic FCLK_p_pin,
    input  logic FCLK_n_pin,
    input  logic [7:0] DATA_p_pin,
    input  logic [7:0] DATA_n_pin,

    // UART
    input  logic usb_uart_rxd,
    output logic usb_uart_txd,

    // SPI
    output logic CSB1,
    output logic CSB2,
    inout  logic SDIO,
    output logic SCLK,

    // Gigabit Ethernet
    output logic [3:0] eth_txd,
    output logic ETH_TX_EN,
    output logic eth_txck,
    output logic ETH_PHYRST_N
);

    // MMCM signals
    logic clk_100m, clk_50m, clk_125m, clk_125m90;
    logic dcm_locked;

    // ADC Signals
    logic adc_clk, bitslip, aligned, adc_rst, adc1_valid, adc2_valid;
    logic [13:0] adc4, adc8;
    logic [15:0] adc1, adc2, adc1_125m, adc2_125m;
    logic [7:0] frmData;

    // Microblaze Signals
    logic [31:0] MB_O;

    // Buffering Signals
    logic cdc_rst_n, rst_125m_n, eth_en, start, tick;
    logic [7:0] eth_data;

    assign led0 = dcm_locked;
    assign led1 = 0;
    assign led2 = MB_O[0];
    assign led3 = MB_O[1];

    clk_wiz_0 MMCM
    (
        // Clock out ports
        .clk_100m(clk_100m),        // output clk_100m
        .clk_50m(clk_50m),          // output clk_50m
        .clk_125m(clk_125m),        // output clk_125m
        .clk_125m90(clk_125m90),    // output clk_125m90

        // Status signal
        .locked(dcm_locked),        // output locked

        // Clock in ports
        .clk_in1_p(SysRefClk_p),    // input clk_in1_p
        .clk_in1_n(SysRefClk_n)     // input clk_in1_n
    );

    db_fsm debouncer
    (
        .clk(clk_125m),
        .reset(!rst_125m_n),
        .sw(btnc),
        .db(btnc_db)
    );

    edge_detect_moore edge_detector
    (
        .clk(clk_125m),
        .reset(!rst_125m_n),
        .level(btnc_db),
        .tick(tick)
    );

    simpleCDC enCDC
    (
        .sourceClk(clk_100m),
        .destClk(adc_clk),
        .d_in(MB_O[0]),
        .d_out(en_synced)
    );

    rstBridge cdcRestet
    (
        .clk(adc_clk),
        .asyncrst_n(cpu_resetn),
        .rst_n(cdc_rst_n)
    );

    rstBridge rst_125m
    (
        .clk(clk_125m),
        .asyncrst_n(cpu_resetn),
        .rst_n(rst_125m_n)
    );

    adc adc_inst
    ( 
        .DCLK_p_pin(DCLK_p_pin),
        .DCLK_n_pin(DCLK_n_pin),
        .FCLK_p_pin(FCLK_p_pin),
        .FCLK_n_pin(FCLK_n_pin),
        .cpu_resetn(cpu_resetn),

        // Input Pins
        .d0a1_p(DATA_p_pin[6]),
        .d0a1_n(DATA_n_pin[6]),
        .d1a1_p(DATA_p_pin[7]),
        .d1a1_n(DATA_n_pin[7]),
        .d0a2_p(DATA_p_pin[0]),
        .d0a2_n(DATA_n_pin[0]),
        .d1a2_p(DATA_p_pin[1]),
        .d1a2_n(DATA_n_pin[1]),
        .d0b2_p(DATA_p_pin[2]),
        .d0b2_n(DATA_n_pin[2]),
        .d1b2_p(DATA_p_pin[3]),
        .d1b2_n(DATA_n_pin[3]),
        .d0d2_p(DATA_p_pin[4]),
        .d0d2_n(DATA_n_pin[4]),
        .d1d2_p(DATA_p_pin[5]),
        .d1d2_n(DATA_n_pin[5]),

        // Deserialized output
        .adc1(adc1),
        .adc2(adc2),
        .adc4(adc4),
        .adc8(adc8),

        // Clocks and Status Outputs
        .divclk_o(adc_clk),
        .frmData(frmData),
        .adc_en(en_synced),
        .aligned(aligned),
        .RstOut(adc_rst)
    );

    adc_cdc adc1_cdc
    (
		.wr_clk(adc_clk),
		.wr_rst(!cdc_rst_n),
		.rd_clk(clk_125m),
		.rd_rst(!rst_125m_n),

		.din(adc1),
		.din_valid(aligned),

		.dout(adc1_125m),
		.dout_valid(adc1_valid)
    );

    adc_cdc adc2_cdc
    (
		.wr_clk(adc_clk),
		.wr_rst(!cdc_rst_n),
		.rd_clk(clk_125m),
		.rd_rst(!rst_125m_n),

		.din(adc2),
		.din_valid(aligned),

		.dout(adc2_125m),
		.dout_valid(adc2_valid)
    );

    ADC_Control_wrapper MB
    (
        .clk_100m(clk_100m),
        .clk_50m(clk_50m),
        .dcm_locked(dcm_locked),
        .cpu_resetn(cpu_resetn),

        .ADC_CSB1(CSB1),
        .ADC_CSB2(CSB2),
        .ADC_SCLK(SCLK),
        .ADC_SDIO(SDIO),
        
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd),
        
        .O(MB_O)
    );

    assign start = aligned & tick;

    logic en_wr, addr;
    logic full_adc1, empty_adc1, en_rd1, full_adc2, empty_adc2, en_rd2;
    logic [7:0] dout1, dout2;

    writeController writeController
    (
        .rstn(rst_125m_n),
        .clk(clk_125m),
        .full(full_adc1 | full_adc2),
        .empty(empty_adc1 & empty_adc2),
        .start(start),
        .wr_en(en_wr),
        .state()
    );

    widthConverter adc1_buffer
    (
    	.clk(clk_125m),
        .rst(!rst_125m_n),
        
        .wr_en(en_wr & adc1_valid),
        .din(adc1_125m),
        .full(full_adc1),

        .rd_en(en_rd1),
        .dout(dout1),
        .empty(empty_adc1)
    );

    widthConverter adc2_buffer
    (
    	.clk(clk_125m),
        .rst(!rst_125m_n),

        .wr_en(en_wr & adc2_valid),
        .din(adc2_125m),
        .full(full_adc2),

        .rd_en(en_rd2),
        .dout(dout2),
        .empty(empty_adc2)
    );
    
    readController readController
    (
        .clk(clk_125m),
        .rstn(rst_125m_n),
        
        .full(full_adc1 | full_adc2),
        .empty1(empty_adc1),
        .empty2(empty_adc2),
        .eth_en(eth_en),
        .rd_en1(en_rd1),
        .rd_en2(en_rd2),
        .addr(addr)
    );

    always_comb begin
    	case(addr)
    		0:
    		begin
    			eth_data = dout1;
    		end

    		1:
    		begin
    			eth_data = dout2;
    		end
    	endcase
    end

    udp_tx_top udp_tx
    (
        .clk_125m(clk_125m),
        .clk_125m90(clk_125m90),

        .udp_tx_valid(eth_en),
        .udp_tx_data(eth_data),
        .udp_tx_busy(),

        .eth_txd(eth_txd),
        .ETH_TX_EN(ETH_TX_EN),
        .eth_txck(eth_txck),
        .ETH_PHYRST_N(ETH_PHYRST_N)
    );

    ila_0 ila (
        .clk(clk_125m), // input wire clk

        .probe0(start), // input wire [0:0]  probe0  
        .probe1(adc1_valid), // input wire [0:0]  probe1 
        .probe2(adc2_valid), // input wire [0:0]  probe2 
        .probe3(empty_adc1), // input wire [0:0]  probe3 
        .probe4(empty_adc2), // input wire [0:0]  probe4 
        .probe5(en_rd1), // input wire [0:0]  probe5 
        .probe6(en_rd2), // input wire [0:0]  probe6
        .probe7(full_adc1),
        .probe8(full_adc2)
);

endmodule