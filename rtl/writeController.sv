`timescale 1ns / 1ps

module writeController(
    input  logic full,
    input  logic empty,
    input  logic clk,
    input  logic rstn,
    input  logic start,
    output logic wr_en,
    output logic [2:0] state
    );

typedef enum logic [2:0] {init = 3'b001, buffer = 3'b010, pause = 3'b100} state_type;
state_type curr_state, next_state;

assign state = curr_state;

always_ff @(posedge clk) begin
    if(rstn == 1'b0) begin
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
            if(start == 1)
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

        default:
        begin
        end
    endcase // curr_state
end

endmodule
