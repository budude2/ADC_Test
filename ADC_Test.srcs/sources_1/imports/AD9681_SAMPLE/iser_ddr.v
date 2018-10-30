//////////////////////////////////////////////////////////////////////////////////
// Company: 		Analog Devices, Inc.
// Engineer: 		MKH
// Create Date:   16 July 2012 
//////////////////////////////////////////////////////////////////////////////////
module iser_ddr 
  (
   // Serial Data Input    
   input        din,
         
   // DCO Clock
   input        data_clk,
   
   // Serial Data Outputs    
   output [1:0] dout

   );

   //==========================================================================
   // Wire and register declarations
   //==========================================================================
   reg  [1:0] dout_reg;

   wire       q1;
   wire       q2;
      
   //==========================================================================
   // Instantiate IDDR block   
   //==========================================================================
   IDDR #(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) 
     iddr (
      .D(din), 
      .C(data_clk), 
      .Q1(q1), 
      .Q2(q2),
      .CE(1'b1), 
      .S(1'b0), 
      .R(1'b0));
      
   //==========================================================================
   // Register output   
   //==========================================================================
   always @(posedge data_clk)
      dout_reg <= {q1, q2};
      
   assign dout = dout_reg;

endmodule

