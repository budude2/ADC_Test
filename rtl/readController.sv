`timescale 1ns / 1ps

module readController(
    input  logic clk,
    input  logic rstn,
    input  logic full,
    input  logic empty1,
    input  logic empty2,
    input  logic empty4,
    input  logic empty8,
    output logic eth_en,
    output logic rd_en1,
    output logic rd_en2,
    output logic rd_en4,
    output logic rd_en8,
    output logic [1:0] addr
    );

typedef enum logic [2:0] {init = 3'b001, read = 3'b010, pause = 3'b100} state_type;
state_type curr_state, next_state;

logic empty;
logic [15:0] count_curr, count_next;

assign empty = empty1 & empty2 & empty4 & empty8;

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
    rd_en1  = 0;
    rd_en2  = 0;
    rd_en4  = 0;
    rd_en8  = 0;
    addr    = 2'b00;

    case(curr_state)
        init:
        begin
            if((full == 1) & (empty == 0))
                next_state = read;
        end

        read:
        begin
            eth_en = 1;

            count_next = count_curr + 1;

            if(empty1 == 0) begin
                rd_en1  = 1;
                addr    = 2'b00;
            end
            else if(empty2 == 0) begin
                rd_en2  = 1;
                addr    = 2'b01;
            end
            else if(empty4 == 0) begin
                rd_en4  = 1;
                addr    = 2'b10;
            end
            else if(empty8 == 0) begin
                rd_en8  = 1;
                addr    = 2'b11;
            end

            if(empty == 1)
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

            if(empty1 == 0) begin
                addr    = 2'b00;
            end
            else if(empty2 == 0) begin
                addr    = 2'b01;
            end
            else if(empty4 == 0) begin
                addr    = 2'b10;
            end
            else if(empty8 == 0) begin
                addr    = 2'b11;
            end

            if(empty == 1)
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