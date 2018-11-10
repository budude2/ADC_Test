//////////////////////////////////////////////////////////////////////////////////
// Company: 		Analog Devices, Inc.
// Engineer: 		MKH
// Create Date:   02-09-2012 
//////////////////////////////////////////////////////////////////////////////////
module mmcm_freq_counter #
  (
   parameter R4_MAX    = 330000000,  // Maximum frequency of range 4
   parameter R3_MAX    = 155000000,  // Maximum frequency of range 3
   parameter R2_MAX    =  70000000,  // Maximum frequency of range 2
   parameter R1_MAX    =  35000000   // Maximum frequency of range 1
   )
  (
   // Frequency mode: 000 = state 1, 001 = state 2, 010 = state 3, etc. 
   output [2:0]               freq_mode,
   
   // Count done indicator
   output                     count_done,
   
   // Reset input, active low
   input                      reset_n,
      
   // Serial data clock input
   input                      dco_clk,

   // 100 MHz reference clock input
   input                      drp_refclk,
   
   // DUT SYNC signal has been sent or started
   input                      dut_sync_rdy   
   
   );
   
   //==========================================================================
   // Wire and register declarations
   //==========================================================================
   reg                             count_d1;
   reg                             count_done_reg;
   reg                             ref_count_d1;
   reg                             ref_count_d2;
   reg                             ref_count_done;
   reg                             dut_sync_rdy_dco_d1;
   reg                             dut_sync_rdy_dco_d2;
   reg  [2:0]                      freq_mode_reg;
   reg  [15:0]                     drp_ref_count;
   reg  [15:0]                     data_clk_count;
   reg  [15:0]                     data_clk_count_d1;
   reg  [15:0]                     data_clk_count_reg;

   wire [15:0]                     drp_ref_count_max;

   //==========================================================================
   // Assignments
   //==========================================================================
   assign freq_mode         = freq_mode_reg;
   assign count_done        = ref_count_done;
   assign drp_ref_count_max = 16'h270F;  // 10,000 reference clock cycles

   //==========================================================================
   // Count reference clock
   //==========================================================================
   always @(posedge drp_refclk, negedge reset_n)
      if(reset_n == 1'b0)
         drp_ref_count <= 16'h0000;
      else if((dut_sync_rdy == 1'b1) && (drp_ref_count < drp_ref_count_max))
         drp_ref_count <= drp_ref_count + 1;

   //==========================================================================
   // Transfer ref clock max count to data_clk domain
   //==========================================================================
   always @(posedge dco_clk, negedge reset_n)
      if(reset_n == 1'b0)
         begin
            count_d1       <= 1'b0;
            count_done_reg <= 1'b0;
         end
      else if(drp_ref_count == drp_ref_count_max)
         begin
            count_d1       <= 1'b1;
            count_done_reg <= count_d1;
         end

   //==========================================================================
   // Sync dut_sync_rdy signal to DCO
   //==========================================================================
   always @(posedge dco_clk, negedge reset_n)
      if(reset_n == 1'b0)
         begin
            dut_sync_rdy_dco_d1 <= 1'b0;
            dut_sync_rdy_dco_d2 <= 1'b0;
         end
      else
         begin
            dut_sync_rdy_dco_d1 <= dut_sync_rdy;
            dut_sync_rdy_dco_d2 <= dut_sync_rdy_dco_d1;
         end

   //==========================================================================
   // Count data rate clock
   //==========================================================================
   always @(posedge dco_clk, negedge reset_n) 
      if(reset_n == 1'b0)
         data_clk_count <= 16'h0000;
      else if((dut_sync_rdy_dco_d2 == 1'b1) && (count_done_reg == 1'b0))
         data_clk_count <= data_clk_count + 1;

   //==========================================================================
   // Transfer clock count to ref_clk domain
   //==========================================================================
   always @(posedge drp_refclk, negedge reset_n)
      if(reset_n == 1'b0)
         begin
            data_clk_count_d1  <= 16'h0;
            data_clk_count_reg <= 16'h0;
         end
      else if(drp_ref_count == drp_ref_count_max)
         begin
            data_clk_count_d1  <= data_clk_count;
            data_clk_count_reg <= data_clk_count_d1;
         end
         
   //==========================================================================
   // Add pipeline delays to count done output
   //==========================================================================
   always @(posedge drp_refclk, negedge reset_n)
      if(reset_n == 1'b0)
         begin
            ref_count_d1   <= 1'b0;
            ref_count_d2   <= 1'b0;
            ref_count_done <= 1'b0;
         end
      else if(count_done_reg == 1'b1)
         begin
            ref_count_d1   <= 1'b1;
            ref_count_d2   <= ref_count_d1;
            ref_count_done <= ref_count_d2;
         end

   //==========================================================================
   // Assign frequency mode
   //==========================================================================
   always @(posedge drp_refclk, negedge reset_n)
      if(reset_n == 1'b0)
         freq_mode_reg <= 3'b000;      
      else if(data_clk_count_reg > R4_MAX/10000)    // Range 5
         freq_mode_reg <= 3'b000;        
      else if(data_clk_count_reg > R3_MAX/10000)    // Range 4
         freq_mode_reg <= 3'b001;
      else if(data_clk_count_reg > R2_MAX/10000)    // Range 3
         freq_mode_reg <= 3'b010;
      else if(data_clk_count_reg > R1_MAX/10000)    // Range 2
         freq_mode_reg <= 3'b011;
      else                                          // Range 1
         freq_mode_reg <= 3'b100;

endmodule
