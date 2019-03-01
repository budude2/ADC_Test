`timescale 1ns / 1ps

module DAC();
	logic FCO_p = 1;
    logic FCO_n = 0;
    logic DCO_p = 1;
    logic DCO_n = 0;

    logic rst         = 0;
    logic iserdes_rst = 1;

    logic d0a2, d1a2;

    logic [3:0] count = 0;
    logic [15:0] adc2;

    always begin
    	#4
    	FCO_p = ~FCO_p;
    	FCO_n = ~FCO_n;
    end

    always begin
    	#1
    	DCO_p = ~DCO_p;
    	DCO_n = ~DCO_n;
	end

	initial begin
		#0.5
		forever begin
            case(count)
                4'h0 : d0a2 = 0;
                4'h1 : d0a2 = 1;
                4'h2 : d0a2 = 1;
                4'h3 : d0a2 = 1;
                4'h4 : d0a2 = 1;
                4'h5 : d0a2 = 1;
                4'h6 : d0a2 = 1;
                4'h7 : d0a2 = 1;
                4'h8 : d0a2 = 0;
                4'h9 : d0a2 = 0;
                4'hA : d0a2 = 0;
                4'hB : d0a2 = 0;
                4'hC : d0a2 = 0;
                4'hD : d0a2 = 0;
                4'hE : d0a2 = 0;
                4'hF : d0a2 = 0;
            endcase
            #1;
		end
	end

    initial begin
        #0.5
        forever begin
            case(count)
                4'h0 : d1a2 = 0;
                4'h1 : d1a2 = 0;
                4'h2 : d1a2 = 0;
                4'h3 : d1a2 = 0;
                4'h4 : d1a2 = 0;
                4'h5 : d1a2 = 0;
                4'h6 : d1a2 = 0;
                4'h7 : d1a2 = 0;
                4'h8 : d1a2 = 0;
                4'h9 : d1a2 = 1;
                4'hA : d1a2 = 1;
                4'hE : d1a2 = 1;
                4'hB : d1a2 = 1;
                4'hC : d1a2 = 1;
                4'hD : d1a2 = 1;
                4'hF : d1a2 = 1;
            endcase
            #1;
        end
    end

	always @(posedge DCO_p, posedge DCO_n) begin
		count <= count + 1;
	end

	top dut
    ( 
        .DCLK_p_pin(DCO_p),
        .DCLK_n_pin(DCO_n),
        .FCLK_p_pin(FCO_p),
        .FCLK_n_pin(FCO_n),
        .cpu_resetn(rst),
        .d0a2_p(d0a2),
        .d0a2_n(~d0a2),
        .d1a2_p(d1a2),
        .d1a2_n(~d1a2),
        .adc2_q(adc2)
        //.adc_rst(iserdes_rst)
        //,
        // .iserdes_rst(iserdes_rst),
        // .bitslip(bitslip)
    );

    initial begin
    	#6
    	rst = 1;
    	#110
    	iserdes_rst = 0;
    end
endmodule
