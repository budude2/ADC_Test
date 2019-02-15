`timescale 1ns / 1ps

module bufferTB( );

    // MMCM signals
    logic clk_100m, clk_50m, clk_125m, clk_125m90, SysRefClk_p, SysRefClk_n;
    logic dcm_locked;

    // ADC Signals
    logic adc_clk, aligned, adc_rst, adc1_valid, adc2_valid, adc_rst_n;
    logic [15:0] adc1, adc2, adc1_125m, adc2_125m;

    // Buffering Signals
    logic rst_125m_n, eth_en, start, tick;
    logic [7:0] eth_data;

    logic [3:0] eth_txd;
    logic ETH_TX_EN;
    logic eth_txck;
    logic ETH_PHYRST_N;

    // Simulation signals
    logic cpu_resetn;

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

    rstBridge rst_125m
    (
        .clk(clk_125m),
        .asyncrst_n(cpu_resetn),
        .rst_n(rst_125m_n)
    );

    rstBridge writeReset
    (
        .clk(adc_clk),
        .asyncrst_n(cpu_resetn),
        .rst_n(adc_rst_n)
    );

    adc_cdc adc1_cdc
    (
        .wr_clk(adc_clk),
        .rd_clk(clk_125m),
        .wr_rst(!adc_rst_n),
        .rd_rst(!rst_125m_n),

        .din(adc1),
        .din_valid(aligned),

        .dout(adc1_125m),
        .dout_valid(adc1_valid)
    );

    adc_cdc adc2_cdc
    (
        .wr_clk(adc_clk),
        .rd_clk(clk_125m),
        .wr_rst(!adc_rst_n),
        .rd_rst(!rst_125m_n),

        .din(adc2),
        .din_valid(aligned),

        .dout(adc2_125m),
        .dout_valid(adc2_valid)
    );

    assign start = aligned & tick;

    logic en_wr, addr;
    logic full_adc1, empty_adc1, en_rd1, full_adc2, empty_adc2, en_rd2;
    logic [7:0] dout1, dout2;

    writeController writeController
    (
        .rstn(rst_125m_n),
        .clk(adc_clk),
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

    initial begin
        SysRefClk_p = 0;
        SysRefClk_n = 1;

        forever begin
            #2.5
            SysRefClk_p = ~SysRefClk_p;
            SysRefClk_n = ~SysRefClk_n;
        end
    end

    initial begin
        adc_clk = 0;

        #4
        forever begin
            #4
            adc_clk = ~adc_clk;
        end
    end

    initial begin
        adc1 = 0;
        adc2 = 0;
        forever begin
            @(posedge adc_clk);
            adc1 = adc1 + 1;
            adc2 = adc2 + 1;
        end
    end

    initial begin
        cpu_resetn = 0;
        aligned    = 0;
        tick       = 0;
        #16
        cpu_resetn = 1;
        #250
        aligned = 1;
        #200
        tick = 1;
        #16
        tick = 0;
    end

endmodule
