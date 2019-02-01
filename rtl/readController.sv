`timescale 1ns / 1ps

module readController(
    input  logic clk,
    input  logic rstn,
    input  logic full,
    input  logic empty,
    input  logic fifo_rst,
    output logic eth_en,
    output logic rd_en
    );

typedef enum logic [1:0] {pause = 2'b01, buffer = 2'b10} state_type;
state_type curr_state, next_state;


always_ff @(posedge clk) begin
    if(rstn == 0'b0) begin
        curr_state <= pause;
    end
    else begin
        curr_state <= next_state;
    end
end

always_comb begin
    next_state = curr_state;

    eth_en  = 0;
    rd_en  	= 0;

    case(curr_state)
    	pause:
    	begin
            if((full == 1) & (fifo_rst == 0))
    		    next_state = buffer;
    	end

    	buffer:
    	begin
    		eth_en = 1;
    		rd_en  = 1;

    		if(empty == 1)
    			next_state = pause;
    	end
    endcase // curr_state
end

endmodule
