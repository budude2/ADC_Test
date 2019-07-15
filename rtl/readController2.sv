`timescale 1ns / 1ps

module readController2(
    input  logic clk,
    input  logic rstn,

    input  logic full,
    input  logic [5:0] empty,
    output logic [5:0] rd_en,
    output logic [2:0] addr,

    input logic tx_done,
    input  logic axis_tready,
    output logic axis_tlast,
    output logic axis_tvalid,
    output logic axis_tvalid_hdr
    );

typedef enum logic [7:0] {  init  = 8'b00000001,
                            read1 = 8'b00000010,
                            read2 = 8'b00000100,
                            read3 = 8'b00001000,
                            read4 = 8'b00010000,
                            read7 = 8'b00100000,
                            read8 = 8'b01000000,
                            pause = 8'b10000000
                            } state_type;

state_type curr_state, next_state;
logic [15:0] curr_count, next_count;

always_ff @(posedge clk) begin
    if(rstn == 1'b0) begin
        curr_state <= init;
        curr_count <= 0;
    end else begin
        curr_state <= next_state;
        curr_count <= next_count;
    end
end

always_comb begin
    next_state = curr_state;
    next_count = curr_count;

    axis_tvalid     = 1'b0;
    rd_en           = 6'b000000;
    addr            = 3'b000;
    axis_tlast      = 1'b0;
    axis_tvalid_hdr = 1'b0;

    case(curr_state)
        init:
        begin
            if((full == 1'b1) & (empty == 1'b0)) begin
                axis_tvalid_hdr = 1'b1;
                next_state      = read1;
            end
        end

        read1:
        begin
            if((axis_tready == 1) & (empty[0] == 0)) begin
                axis_tvalid = 1'b1;
                rd_en[0]    = 1'b1;
                addr        = 3'b000;

                next_count = curr_count + 1;
            end

            if((curr_count == 1023) | (empty[0] == 1)) begin
                next_state = pause;
                next_count = 0;
                axis_tlast = 1'b1;
            end
        end

        read2:
        begin
            if((axis_tready == 1) & (empty[1] == 0)) begin
                axis_tvalid = 1'b1;
                rd_en[1]    = 1'b1;
                addr        = 3'b001;

                next_count = curr_count + 1;
            end

            if((curr_count == 1023) | (empty[1] == 1)) begin
                next_state = pause;
                next_count = 0;
                axis_tlast = 1'b1;
            end
        end

        read3:
        begin
            if((axis_tready == 1) & (empty[2] == 0)) begin
                axis_tvalid = 1'b1;
                rd_en[2]    = 1'b1;
                addr        = 3'b010;

                next_count = curr_count + 1;
            end

            if((curr_count == 1023) | (empty[2] == 1)) begin
                next_state = pause;
                next_count = 0;
                axis_tlast = 1'b1;
            end
        end

        read4:
        begin
            if((axis_tready == 1) & (empty[3] == 0)) begin
                axis_tvalid = 1'b1;
                rd_en[3]    = 1'b1;
                addr        = 3'b011;

                next_count = curr_count + 1;
            end

            if((curr_count == 1023) | (empty[3] == 1)) begin
                next_state = pause;
                next_count = 0;
                axis_tlast = 1'b1;
            end
        end

        read7:
        begin
            if((axis_tready == 1) & (empty[4] == 0)) begin
                axis_tvalid = 1'b1;
                rd_en[4]    = 1'b1;
                addr        = 3'b100;

                next_count = curr_count + 1;
            end

            if((curr_count == 1023) | (empty[4] == 1)) begin
                next_state = pause;
                next_count = 0;
                axis_tlast = 1'b1;
            end
        end

        read8:
        begin
            if((axis_tready == 1) & (empty[5] == 0)) begin
                axis_tvalid = 1'b1;
                rd_en[5]    = 1'b1;
                addr        = 3'b101;

                next_count = curr_count + 1;
            end

            if((curr_count == 1023) | (empty[5] == 1)) begin
                next_state = pause;
                next_count = 0;
                axis_tlast = 1'b1;
            end
        end

        pause:
        begin
            next_count = curr_count + 1;

            if(tx_done == 1'b1) begin
                axis_tvalid_hdr = 1'b1;
            end

            if(axis_tready == 1'b1) begin
                if(empty == 0) begin
                    next_state = read1;
                    next_count = 0;
                end
                else if(empty == 1) begin
                    next_state = read2;
                    next_count = 0;
                end
                else if(empty == 3) begin
                    next_state = read3;
                    next_count = 0;
                end
                else if(empty == 7) begin
                    next_state = read4;
                    next_count = 0;
                end
                else if(empty == 15) begin
                    next_state = read7;
                    next_count = 0;
                end
                else if(empty == 31) begin
                    next_state = read8;
                    next_count = 0;
                end
                else if (empty == 63) begin
                    next_state = init;
                    next_count = 0;
                end
            end
        end

        default:
        begin
        end

    endcase
end

endmodule