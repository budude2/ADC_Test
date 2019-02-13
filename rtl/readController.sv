`timescale 1ns / 1ps

module readController(
    input  logic clk,
    input  logic rstn,
    input  logic full,
    input  logic empty,
    output logic eth_en,
    output logic rd_en
    );

typedef enum logic [2:0] {init = 3'b001, read = 3'b010, pause = 3'b100} state_type;
state_type curr_state, next_state;

logic [10:0] count_curr, count_next;

always_ff @(posedge clk) begin
    if(rstn == 1'b0) begin
        curr_state <= init;
        count_curr <= 0;
    end
    else begin
        curr_state <= next_state;
        count_curr <= count_next;
    end
end

always_comb begin
    next_state = curr_state;
    count_next = count_curr;

    eth_en  = 0;
    rd_en   = 0;

    case(curr_state)
        init:
        begin
            if((full == 1) & (empty == 0))
                next_state = read;
        end

        read:
        begin
            eth_en = 1;
            rd_en  = 1;

            count_next = count_curr + 1;

            if(empty == 1)
                next_state = init;
            else if(count_curr == 511)
            begin
                next_state = pause;
                count_next = 0;
            end
        end

        pause:
        begin
            count_next = count_curr + 1;

            if(empty == 1)
                next_state = init;
            else if(count_curr == 2047)
            begin
                next_state = read;
                count_next = 0;
            end
        end

        default:
        begin
        end
    endcase // curr_state
end

endmodule