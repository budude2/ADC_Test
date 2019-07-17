`timescale 1ns / 1ps

module udpCommandParser
    (
        input logic clk,
        input logic rst,

        input logic data_ready,
        input logic [31:0] data,

        output logic rd_en,
        output logic sendAdcData
    );

    logic [31:0] curr_command, next_command;

    typedef enum logic [2:0] {init = 3'b001, getCommand = 3'b010, parseCommand = 3'b100} state_type;
    state_type curr_state, next_state;

    always_ff @(posedge clk) begin
        if(rst == 1'b1) begin
            curr_state   <= init;
            curr_command <= 0;
        end
        else begin
            curr_state   <= next_state;
            curr_command <= next_command;
        end
    end

    always_comb begin
        next_state  = curr_state;

        rd_en       = 0;
        sendAdcData = 0;

        case(curr_state)
            init:
            begin
                if(data_ready == 1'b1) begin
                    next_state = getCommand;
                end
            end

            getCommand:
            begin
                rd_en        = 1;
                next_command = data;

                next_state   = parseCommand;
            end

            parseCommand:
            begin
                if(curr_command == 32'h73656e64) begin
                    sendAdcData = 1;
                    next_state  = init;
                end

                else begin
                    next_state = init;
                end
            end

            default:
            begin
            end
        endcase // curr_state
    end

endmodule
