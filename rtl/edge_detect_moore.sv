// Listing 5.3
module edge_detect_moore
   (
    input  logic clk, reset,
    input  logic level,
    output logic tick
   );

   // fsm state type 
   typedef enum {zero, edg, one} state_type;

   // signal declaration
   state_type state_reg, state_next;

   // state register
    always_ff @(posedge clk, posedge reset)
       if (reset)
          state_reg <= zero;
       else
          state_reg <= state_next;

   // next-state logic and output logic
   always_comb
   begin
      state_next = state_reg;  // default state: the same
      tick = 1'b0;             // default output: 0
      case (state_reg)
         zero:
            if (level)
               state_next = edg;
         edg:
            begin
               tick = 1'b1;
               if (level)
                  state_next = one;
               else
                  state_next = zero;
             end
         one:
            if (~level)
               state_next = zero;
         default: state_next = zero;
      endcase
   end
endmodule