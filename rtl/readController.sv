`timescale 1ns / 1ps

module readController(
    input  logic clk,
    input  logic rstn,
    input  logic full,
    input  logic [5:0] empty,
    output logic eth_en,
    output logic [5:0] rd_en,
    output logic [2:0] addr
    );

typedef enum logic [2:0] {init = 3'b001, read = 3'b010, pause = 3'b100} state_type;
state_type curr_state, next_state;

logic empty_red;
logic [15:0] count_curr, count_next;

assign empty_red = &empty;

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
    rd_en   = 6'b000000;
    addr    = 3'b000;

    case(curr_state)
        init:
        begin
            if((full == 1) & (empty_red == 0))
                next_state = read;
        end

        read:
        begin
            eth_en = 1;

            count_next = count_curr + 1;

            if(empty[0] == 0) begin
                rd_en[0]  = 1;
                addr    = 3'b000;
            end
            else if(empty[1] == 0) begin
                rd_en[1]  = 1;
                addr    = 3'b001;
            end
            else if(empty[2] == 0) begin
                rd_en[2]  = 1;
                addr    = 3'b010;
            end
            else if(empty[3] == 0) begin
                rd_en[3]  = 1;
                addr    = 3'b011;
            end
            else if(empty[4] == 0) begin
                rd_en[4]  = 1;
                addr    = 3'b100;
            end
            else if(empty[5] == 0) begin
                rd_en[5]  = 1;
                addr    = 3'b101;
            end

            if(empty_red == 1)
                next_state = init;
            else if(count_curr == 1023)
            begin
                next_state = pause;
                count_next = 0;
            end
        end

        pause:
        begin
            count_next = count_curr + 1;

            if(empty[0] == 0) begin
                addr    = 3'b000;
            end
            else if(empty[1] == 0) begin
                addr    = 3'b001;
            end
            else if(empty[2] == 0) begin
                addr    = 3'b010;
            end
            else if(empty[3] == 0) begin
                addr    = 3'b011;
            end
            else if(empty[4] == 0) begin
                addr    = 3'b100;
            end
            else if(empty[5] == 0) begin
                addr    = 3'b101;
            end

            if(empty_red == 1)
                next_state = init;
            else if(count_curr == 8191)
            begin
                next_state = read;
                count_next = 0;
            end
        end

        default:
        begin
        end
    endcase
end

endmodule