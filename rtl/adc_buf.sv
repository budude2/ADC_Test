`timescale 1ns / 1ps

module adc_buf
#(   
    parameter DIFF_TERM 	= "TRUE",
    parameter IBUF_LOW_PWR 	= "FALSE",
    parameter IOSTANDARD 	= "LVDS_25"
)
(
    input logic ln0_p,
    input logic ln0_n,

    input logic ln1_p,
    input logic ln1_n,

    output logic ln0,
    output logic ln1
);

    IBUFDS #(
        .DIFF_TERM(DIFF_TERM),          // Differential Termination
        .IBUF_LOW_PWR(IBUF_LOW_PWR),    // Low power="TRUE", Highest performance="FALSE"
        .IOSTANDARD(IOSTANDARD)         // Specify the input I/O standard
    ) IBUFDS_ln0 (
        .I(ln0_p),    // Diff_p buffer input (connect directly to top-level port)
        .IB(ln0_n),   // Diff_n buffer input (connect directly to top-level port)
        .O(ln0)       // Buffer output
    );

    IBUFDS #(
        .DIFF_TERM(DIFF_TERM),       // Differential Termination
        .IBUF_LOW_PWR(IBUF_LOW_PWR), // Low power="TRUE", Highest performance="FALSE"
        .IOSTANDARD(IOSTANDARD)      // Specify the input I/O standard
    ) IBUFDS_ln1 (
        .I(ln1_p),    // Diff_p buffer input (connect directly to top-level port)
        .IB(ln1_n),   // Diff_n buffer input (connect directly to top-level port)
        .O(ln1)       // Buffer output
    );

endmodule