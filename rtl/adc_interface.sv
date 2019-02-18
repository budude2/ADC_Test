`timescale 1ns / 1ps

module adc_interface
    ( 
        input logic DCLK_p_pin,
        input logic DCLK_n_pin,
        input logic FCLK_p_pin,
        input logic FCLK_n_pin,
        input logic rst_n,
        input logic adc_en,

        // ADC 1
        input logic d0a1_p,
        input logic d0a1_n,
        input logic d1a1_p,
        input logic d1a1_n,

        // ADC 2
        input logic d0a2_p,
        input logic d0a2_n,
        input logic d1a2_p,
        input logic d1a2_n,
        
        // ADC 4
        input logic d0b2_p,
        input logic d0b2_n,
        input logic d1b2_p,
        input logic d1b2_n,

        // ADC 8
        input logic d0d2_p,
        input logic d0d2_n,
        input logic d1d2_p,
        input logic d1d2_n,

        output logic [15:0] adc1,
        output logic [15:0] adc2,
        output logic [15:0] adc4,
        output logic [15:0] adc8,
        
        output logic divclk_o,
        output logic [7:0] frmData,
        output logic aligned
    );

    logic DCLK, DCLK_IO, CLKDIV, FCLK, adc_rst, adc_rst_n, bitslip, rst_sync;

    IBUFDS #(
        .DIFF_TERM("TRUE"),     // Differential Termination
        .IBUF_LOW_PWR("FALSE"), // Low power="TRUE", Highest performance="FALSE"
        .IOSTANDARD("LVDS_25")  // Specify the input I/O standard
    ) IBUFDS_clk (
        .I(DCLK_p_pin),  // Diff_p buffer input (connect directly to top-level port)
        .IB(DCLK_n_pin), // Diff_n buffer input (connect directly to top-level port)
        .O(DCLK)         // Buffer output
    );

    IBUFDS #(
        .DIFF_TERM("TRUE"),     // Differential Termination
        .IBUF_LOW_PWR("FALSE"), // Low power="TRUE", Highest performance="FALSE"
        .IOSTANDARD("LVDS_25")  // Specify the input I/O standard
    ) IBUFDS_fco (
        .I(FCLK_p_pin),  // Diff_p buffer input (connect directly to top-level port)
        .IB(FCLK_n_pin), // Diff_n buffer input (connect directly to top-level port)
        .O(FCLK)         // Buffer output
    );

    BUFIO BUFIO_inst (
        .I(DCLK),    // 1-bit input: Clock input (connect to an IBUF or BUFMR).
        .O(DCLK_IO)  // 1-bit output: Clock output (connect to I/O clock loads).

    );

    BUFR #(
        .BUFR_DIVIDE("4"),     // Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"
        .SIM_DEVICE("7SERIES") // Must be set to "7SERIES"
    ) BUFR_inst (
        .CE(1'b1),         // 1-bit input: Active high, clock enable (Divided modes only)
        .CLR(~rst_n), // 1-bit input: Active high, asynchronous clear (Divided modes only)
        .I(DCLK),          // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
        .O(CLKDIV)         // 1-bit output: Clock output port
    );

    rstBridge writeReset
    (
        .clk(CLKDIV),
        .asyncrst_n(rst_n),
        .rst_n(rst_sync)
    );

    shiftReg rstDelay
    (
        .clk(CLKDIV),
        .D(rst_sync),
        .Q(adc_rst_n)
    );

    assign adc_rst = ~adc_rst_n;

    frameDetector fdet_inst
    (
        .CLK(DCLK_IO),
        .CLKDIV(CLKDIV),
        .CE(adc_en),
        .RST(adc_rst),
        .D(FCLK),
        .data_o(frmData),
        .bitslip(bitslip)
    );

    bitslip fcosync
    (
      .CLKDIV(CLKDIV),
      .ISERDES_FCO(frmData),
      .rst(adc_rst),
      .ISERDES_bslip(bitslip),
      .aligned(aligned),
      .CE(adc_en)
   );

    adc adc1_inst
    (
        .DCLK_IO(DCLK_IO),
        .CLKDIV (CLKDIV ),
        .RST    (adc_rst),
        .CE     (adc_en),

        .bitslip(bitslip),

        .ln0_p  (d0a1_p  ),
        .ln0_n  (d0a1_n  ),
        .ln1_p  (d1a1_p  ),
        .ln1_n  (d1a1_n  ),

        .d_out  (adc1  )
    );

    adc adc2_inst
    (
        .DCLK_IO(DCLK_IO),
        .CLKDIV (CLKDIV ),
        .RST    (adc_rst),
        .CE     (adc_en),

        .bitslip(bitslip),

        .ln0_p  (d0a2_p  ),
        .ln0_n  (d0a2_n  ),
        .ln1_p  (d1a2_p  ),
        .ln1_n  (d1a2_n  ),

        .d_out  (adc2  )
    );

    adc adc4_inst
    (
        .DCLK_IO(DCLK_IO),
        .CLKDIV (CLKDIV ),
        .RST    (adc_rst),
        .CE     (adc_en),

        .bitslip(bitslip),

        .ln0_p  (d0b2_p  ),
        .ln0_n  (d0b2_n  ),
        .ln1_p  (d1b2_p  ),
        .ln1_n  (d1b2_n  ),

        .d_out  (adc4  )
    );

    adc adc8_inst
    (
        .DCLK_IO(DCLK_IO),
        .CLKDIV (CLKDIV ),
        .RST    (adc_rst),
        .CE     (adc_en),

        .bitslip(bitslip),

        .ln0_p  (d0d2_p  ),
        .ln0_n  (d0d2_n  ),
        .ln1_p  (d1d2_p  ),
        .ln1_n  (d1d2_n  ),

        .d_out  (adc8  )
    );

    assign divclk_o = CLKDIV;
    assign RstOut   = adc_rst;

endmodule // top