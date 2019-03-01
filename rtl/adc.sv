`timescale 1ns / 1ps

module adc (
    input logic DCLK_IO,
    input logic CLKDIV,

    input logic RST,
    input logic CE,
    input logic bitslip,

    input logic ln0_p,
    input logic ln0_n,

    input logic ln1_p,
    input logic ln1_n,

    output logic [15:0] d_out
);
    
    logic ln0, ln1;
    logic [7:0] ln0_des, ln1_des;

    adc_buf buffers
    (
        .ln0_p(ln0_p),
        .ln0_n(ln0_n),

        .ln1_p(ln1_p),
        .ln1_n(ln1_n),

        .ln0  (ln0),
        .ln1  (ln1)
    );

    dataDeserializer ln0_deserializer
    (
        .CLK(DCLK_IO),
        .CLKDIV(CLKDIV),
        .RST(RST),
        .bitslip(bitslip),
        .CE(CE),

        .D(ln0),
        .data_o(ln0_des)
    );

    dataDeserializer ln1_deserializer
    (
        .CLK(DCLK_IO),
        .CLKDIV(CLKDIV),
        .RST(RST),
        .bitslip(bitslip),
        .CE(CE),

        .D(ln1),
        .data_o(ln1_des)
    );

    assign d_out = {ln1_des[0], ln0_des[0],
                    ln1_des[1], ln0_des[1],
                    ln1_des[2], ln0_des[2],
                    ln1_des[3], ln0_des[3],
                    ln1_des[4], ln0_des[4],
                    ln1_des[5], ln0_des[5],
                    ln1_des[6], ln0_des[6],
                    ln1_des[7], ln0_des[7]};

endmodule