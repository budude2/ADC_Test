//////////////////////////////////////////////////////////////////////////////////
// Company: 		Analog Devices, Inc.
// Engineer: 		MKH
// Create Date:   8 August 2012 
//////////////////////////////////////////////////////////////////////////////////
module iser_fco_strobe 
  (
   input   [1:0]          fco_din,
   input                  fco_rst_n,
   input                  fco_dclk,
   input                  fco_dclk_rdy,
   output                 fco_strobe, 
   output                 fco_position,
   output                 fco_ready
  );

   //==========================================================================
   // Register and wire declarations
   //==========================================================================
   reg        fco_ready_d0;
   reg        fco_ready_d1;
   reg        fco_ready_reg;
   reg        fco_strobe_reg;
   reg        fco_position_reg;
   reg  [1:0] fco_din_d1;
   reg  [1:0] fco_din_d2;
   
   //==========================================================================
   // Register 2 cycles of FCO data
   //==========================================================================
   always @(posedge fco_dclk, negedge fco_rst_n)
      if(fco_rst_n == 1'b0)
         begin
            fco_din_d1 <= 2'b0;
            fco_din_d2 <= 2'b0;
         end
      else if(fco_dclk_rdy == 1'b1)
         begin
            fco_din_d1 <= fco_din;
            fco_din_d2 <= fco_din_d1;
         end
     
   //==========================================================================
   // Find rising edge
   //==========================================================================
   always @(posedge fco_dclk, negedge fco_rst_n)
      if(fco_rst_n == 1'b0)
         fco_strobe_reg <= 1'b0;
      else if((fco_ready_reg == 1'b1) && (fco_din_d2 == 2'b0) && (fco_din_d1 == 2'b11))
         fco_strobe_reg <= 1'b1;
      else if((fco_ready_reg == 1'b1) && (fco_din_d2 == 2'b0) && (fco_din_d1 == 2'b01))
         fco_strobe_reg <= 1'b1;
      else
         fco_strobe_reg <= 1'b0;
  
   assign fco_strobe = fco_strobe_reg;
      
   //==========================================================================
   // Indicate location of rising edge
   // 0 = no delay
   // 1 = delayed by 1
   //==========================================================================
   always @(posedge fco_dclk, negedge fco_rst_n)
      if(fco_rst_n == 1'b0)
         fco_position_reg <= 1'b0;
      else if((fco_ready_reg == 1'b1) && (fco_din_d2 == 2'b0) && (fco_din_d1 == 2'b01))
         fco_position_reg <= 1'b1;

   assign fco_position = fco_position_reg;

   //==========================================================================
   // Generate FCO ready output
   //==========================================================================
   always @(posedge fco_dclk, negedge fco_rst_n)
      if(fco_rst_n == 1'b0)
         begin
            fco_ready_d0  <= 1'b0;
            fco_ready_d1  <= 1'b0;
            fco_ready_reg <= 1'b0;
         end
      else if(fco_dclk_rdy == 1'b1)
         begin
            fco_ready_d0  <= 1'b1;
            fco_ready_d1  <= fco_ready_d0;
            fco_ready_reg <= fco_ready_d1;
         end
     
   assign fco_ready = fco_ready_reg;

endmodule
