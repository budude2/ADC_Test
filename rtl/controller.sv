`timescale 1ns / 1ps

module controller(
    input  logic full,
    input  logic empty,
    input  logic clk,
    input  logic rstn,
    input  logic start,
    input  logic fifo_rst,
    output logic wr_en,
    output logic [3:0] state
    );

typedef enum logic [3:0] {init = 4'b0001, buffer = 4'b0010, pause = 4'b0100, stop = 4'b1000} state_type;
state_type curr_state, next_state;

assign state = curr_state;

always_ff @(posedge clk) begin
    if(rstn == 0'b0) begin
        curr_state <= init;
    end
    else begin
        curr_state <= next_state;
    end
end

always_comb begin
    next_state = curr_state;

    wr_en = 0;

    case(curr_state)
    	init:
    	begin
            if((start == 1) & (fifo_rst == 0))
    		    next_state = buffer;
    	end

    	buffer:
    	begin
    		wr_en = 1;

    		if(full == 1)
    			next_state = pause;
    	end

    	pause:
    	begin
    		if(empty == 1)
    			next_state = init;
    	end

        stop:
        begin
        end
    endcase // curr_state
end

endmodule
