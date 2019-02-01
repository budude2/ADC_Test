`timescale 1ns / 1ps

module bitslip
   (
      input logic CLKDIV,
      input logic rst,
      input logic [7:0] ISERDES_FCO,
      output logic ISERDES_bslip,
      output logic aligned
   );

   typedef enum logic [3:0] {STARTUP = 4'b0001, POLL = 4'b0010, SLIP = 4'b0100, STOP = 4'b1000} state_type;

   state_type state_curr, state_next;

   logic [2:0] count_curr, count_next;

    always_ff @(posedge CLKDIV) begin
        if(rst) begin
            state_curr <= STARTUP;
            count_curr <= 0;
        end
        else begin
            state_curr <= state_next;
            count_curr <= count_next;
        end
    end


    always_comb begin
        state_next    = state_curr;
        count_next    = count_curr;
        ISERDES_bslip = 0;
        aligned       = 0;

        case(state_curr)
            STARTUP:
                begin
                    count_next = count_curr + 1;
                    if(count_curr == 3'b111)
                        state_next = POLL;
                end
            POLL:
                begin
                    if (ISERDES_FCO != 8'hF0) begin
                        ISERDES_bslip = 1'b1;
                        count_next    = 3'b000;
                        state_next    = SLIP;
                    end
                    else
                        state_next = STOP;
                end
            SLIP:
                begin
                    count_next = count_curr + 3'b001;

                    if (count_curr == 3'b111) begin
                        state_next  = POLL;
                    end
                end

            STOP:
                begin
                    aligned = 1'b1;
                end

            default:
                begin
                    state_next = STARTUP;
                end
        endcase // state_curr
    end
endmodule