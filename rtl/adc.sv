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
        input logic d0a1_p,
        input logic d0a1_n,
        input logic d1a1_p,
        input logic d1a1_n,
        input logic d0b2_p,
        input logic d0b2_n,
        input logic d1b2_p,
        input logic d1b2_n,
        input logic d0d2_p,
        input logic d0d2_n,
        input logic d1d2_p,
        input logic d1d2_n,
        input logic adc_en,
        output logic [15:0] adc1,
        output logic [13:0] adc2,
        output logic [13:0] adc4,
        output logic [13:0] adc8,
        output logic divclk_o,
        output logic [7:0] frmData,
        output logic aligned
    );

    logic DCLK, DCLK_IO, rst, CLKDIV, FCLK, iserdes_rst, adc_rst, d0a2, d1a2, d0a1, d1a1;
    logic d0b2, d1b2, bitslip, d0d1, d0d2;
    logic [7:0] d0a2_data, d1a2_data, d0b2_data, d1b2_data, d1d2_data, d0d2_data, d0a1_data, d1a1_data;
    //logic [15:0] adc2, adc4;

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

    IBUFDS #(
        .DIFF_TERM("TRUE"),     // Differential Termination
        .IBUF_LOW_PWR("FALSE"), // Low power="TRUE", Highest performance="FALSE"
        .IOSTANDARD("LVDS_25")  // Specify the input I/O standard
    ) IBUFDS_d0b2 (
        .I(d0b2_p),    // Diff_p buffer input (connect directly to top-level port)
        .IB(d0b2_n),   // Diff_n buffer input (connect directly to top-level port)
        .O(d0b2)       // Buffer output
    );

    IBUFDS #(
        .DIFF_TERM("TRUE"),     // Differential Termination
        .IBUF_LOW_PWR("FALSE"), // Low power="TRUE", Highest performance="FALSE"
        .IOSTANDARD("LVDS_25")  // Specify the input I/O standard
    ) IBUFDS_d1b2 (
        .I(d1b2_p),    // Diff_p buffer input (connect directly to top-level port)
        .IB(d1b2_n),   // Diff_n buffer input (connect directly to top-level port)
        .O(d1b2)       // Buffer output
    );

    IBUFDS #(
        .DIFF_TERM("TRUE"),     // Differential Termination
        .IBUF_LOW_PWR("FALSE"), // Low power="TRUE", Highest performance="FALSE"
        .IOSTANDARD("LVDS_25")  // Specify the input I/O standard
    ) IBUFDS_d0d2 (
        .I(d0d2_p),    // Diff_p buffer input (connect directly to top-level port)
        .IB(d0d2_n),   // Diff_n buffer input (connect directly to top-level port)
        .O(d0d2)       // Buffer output
    );

    IBUFDS #(
        .DIFF_TERM("TRUE"),     // Differential Termination
        .IBUF_LOW_PWR("FALSE"), // Low power="TRUE", Highest performance="FALSE"
        .IOSTANDARD("LVDS_25")  // Specify the input I/O standard
    ) IBUFDS_d1d2 (
        .I(d1d2_p),    // Diff_p buffer input (connect directly to top-level port)
        .IB(d1d2_n),   // Diff_n buffer input (connect directly to top-level port)
        .O(d1d2)       // Buffer output
    );

    IBUFDS #(
        .DIFF_TERM("TRUE"),     // Differential Termination
        .IBUF_LOW_PWR("FALSE"), // Low power="TRUE", Highest performance="FALSE"
        .IOSTANDARD("LVDS_25")  // Specify the input I/O standard
    ) IBUFDS_d0a1 (
        .I(d0a1_p),    // Diff_p buffer input (connect directly to top-level port)
        .IB(d0a1_n),   // Diff_n buffer input (connect directly to top-level port)
        .O(d0a1)       // Buffer output
    );

    IBUFDS #(
        .DIFF_TERM("TRUE"),     // Differential Termination
        .IBUF_LOW_PWR("FALSE"), // Low power="TRUE", Highest performance="FALSE"
        .IOSTANDARD("LVDS_25")  // Specify the input I/O standard
    ) IBUFDS_d1a1 (
        .I(d1a1_p),    // Diff_p buffer input (connect directly to top-level port)
        .IB(d1a1_n),   // Diff_n buffer input (connect directly to top-level port)
        .O(d1a1)       // Buffer output
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
      .ISERDES_bslip(bitslip),
      .aligned(aligned)
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

    assign adc2 = {d1a2_data[0], d0a2_data[0],
                   d1a2_data[1], d0a2_data[1],
                   d1a2_data[2], d0a2_data[2],
                   d1a2_data[3], d0a2_data[3],
                   d1a2_data[4], d0a2_data[4],
                   d1a2_data[5], d0a2_data[5],
                   d1a2_data[6], d0a2_data[6]};

    dataDeserializer d0b2_inst
    (
        .CLK(DCLK_IO),
        .CLKDIV(CLKDIV),
        .RST(adc_rst),
        .D(d0b2),
        .data_o(d0b2_data),
        .bitslip(bitslip)
    );

    dataDeserializer d1b2_inst
    (
        .CLK(DCLK_IO),
        .CLKDIV(CLKDIV),
        .RST(adc_rst),
        .D(d1b2),
        .data_o(d1b2_data),
        .bitslip(bitslip)
    );

    assign adc4 = {d1b2_data[0], d0b2_data[0],
                   d1b2_data[1], d0b2_data[1],
                   d1b2_data[2], d0b2_data[2],
                   d1b2_data[3], d0b2_data[3],
                   d1b2_data[4], d0b2_data[4],
                   d1b2_data[5], d0b2_data[5],
                   d1b2_data[6], d0b2_data[6]};

    dataDeserializer d0d2_inst
    (
        .CLK(DCLK_IO),
        .CLKDIV(CLKDIV),
        .RST(adc_rst),
        .D(d0d2),
        .data_o(d0d2_data),
        .bitslip(bitslip)
    );

    dataDeserializer d1d2_inst
    (
        .CLK(DCLK_IO),
        .CLKDIV(CLKDIV),
        .RST(adc_rst),
        .D(d1d2),
        .data_o(d1d2_data),
        .bitslip(bitslip)
    );

    assign adc8 = {d1d2_data[0], d0d2_data[0],
                   d1d2_data[1], d0d2_data[1],
                   d1d2_data[2], d0d2_data[2],
                   d1d2_data[3], d0d2_data[3],
                   d1d2_data[4], d0d2_data[4],
                   d1d2_data[5], d0d2_data[5],
                   d1d2_data[6], d0d2_data[6]};

   dataDeserializer d0a1_inst
    (
        .CLK(DCLK_IO),
        .CLKDIV(CLKDIV),
        .RST(adc_rst),
        .D(d0a1),
        .data_o(d0a1_data),
        .bitslip(bitslip)
    );

    dataDeserializer d1a1_inst
    (
        .CLK(DCLK_IO),
        .CLKDIV(CLKDIV),
        .RST(adc_rst),
        .D(d1a1),
        .data_o(d1a1_data),
        .bitslip(bitslip)
    );

    assign adc1 = {d1a1_data[0], d0a1_data[0],
                   d1a1_data[1], d0a1_data[1],
                   d1a1_data[2], d0a1_data[2],
                   d1a1_data[3], d0a1_data[3],
                   d1a1_data[4], d0a1_data[4],
                   d1a1_data[5], d0a1_data[5],
                   d1a1_data[6], d0a1_data[6],
                   d1a1_data[7], d0a1_data[7]};

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