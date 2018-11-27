`timescale 1ns / 1ps

module adc
    ( 
        input logic DCLK_p_pin,
        input logic DCLK_n_pin,
        input logic FCLK_p_pin,
        input logic FCLK_n_pin,
        input logic cpu_resetn,
        input logic d0a2_p,
        input logic d0a2_n,
        input logic d1a2_p,
        input logic d1a2_n,
        input logic adc_en,
        output logic [13:0] adc2,
        output logic divclk_o,
        output logic bitslip,
        output logic [7:0] frmData,
        output logic [7:0] d0a2_data,
        output logic [7:0] d1a2_data
    );

    logic DCLK, DCLK_IO, rst, CLKDIV, FCLK, iserdes_rst, adc_rst, d0a2, d1a2;
    //logic [7:0] frmData, d0a2_data, d1a2_data;
    logic [15:0] adc2;

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

    IBUFDS #(
        .DIFF_TERM("TRUE"),     // Differential Termination
        .IBUF_LOW_PWR("FALSE"), // Low power="TRUE", Highest performance="FALSE"
        .IOSTANDARD("LVDS_25")  // Specify the input I/O standard
    ) IBUFDS_d0a2 (
        .I(d0a2_p),    // Diff_p buffer input (connect directly to top-level port)
        .IB(d0a2_n),   // Diff_n buffer input (connect directly to top-level port)
        .O(d0a2)       // Buffer output
    );

    IBUFDS #(
        .DIFF_TERM("TRUE"),     // Differential Termination
        .IBUF_LOW_PWR("FALSE"), // Low power="TRUE", Highest performance="FALSE"
        .IOSTANDARD("LVDS_25")  // Specify the input I/O standard
    ) IBUFDS_d1a2 (
        .I(d1a2_p),    // Diff_p buffer input (connect directly to top-level port)
        .IB(d1a2_n),   // Diff_n buffer input (connect directly to top-level port)
        .O(d1a2)       // Buffer output
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
        .CLR(~cpu_resetn), // 1-bit input: Active high, asynchronous clear (Divided modes only)
        .I(DCLK),          // 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
        .O(CLKDIV)         // 1-bit output: Clock output port
    );

    AppsRst #(
        .C_AppsRstDly(10)
    ) rstController (
        .ClkIn(CLKDIV),
        .Locked(adc_en),
        .Rst(~cpu_resetn),
        .RstOut(adc_rst)
    );

    frameDetector fdet_inst
    (
        .CLK(DCLK_IO),
        .CLKDIV(CLKDIV),
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
      .ISERDES_bslip(bitslip)
   );

    dataDeserializer d0a2_inst
    (
        .CLK(DCLK_IO),
        .CLKDIV(CLKDIV),
        .RST(adc_rst),
        .D(d0a2),
        .data_o(d0a2_data),
        .bitslip(bitslip)
    );

    dataDeserializer d1a2_inst
    (
        .CLK(DCLK_IO),
        .CLKDIV(CLKDIV),
        .RST(adc_rst),
        .D(d1a2),
        .data_o(d1a2_data),
        .bitslip(bitslip)
    );

    assign adc2 = {d1a2_data[0], d0a2_data[0], d1a2_data[1], d0a2_data[1], d1a2_data[2], d0a2_data[2], d1a2_data[3], d0a2_data[3], d1a2_data[4], d0a2_data[4], d1a2_data[5], d0a2_data[5], d1a2_data[6], d0a2_data[6]};

    assign divclk_o = CLKDIV;

    // always_ff @(posedge CLKDIV) begin
    //     if(adc_rst == 1) begin
    //         adc2_q <= 0;
    //     end // if(adc_rst == 1)
    //     else begin
    //         adc2_q <= adc2;
    //     end // else
    // end // always_ff @(posedge CLKDIV)

endmodule // top