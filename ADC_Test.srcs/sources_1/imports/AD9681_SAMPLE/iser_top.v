//////////////////////////////////////////////////////////////////////////////////
// Company: 		Analog Devices, Inc.
// Engineer: 		IK
// Create Date:   11 June 2013 
//////////////////////////////////////////////////////////////////////////////////
module iser_top 
  (
   // Parallel Output Data 
   output [15:0] iser_chan_a,
   output [15:0] iser_chan_c,
   output [15:0] iser_chan_e,
   output [15:0] iser_chan_g,
   
   // Parallel output data clock
   output        fco_clk,
   output        fco_clk_rdy,

   // Serial Input Clock
   input         data_clk,
   input         data_clk_rdy,

   // Serial Input Data, including frame clock
   input         din_fco_p,
   input         din_fco_n,
   input         din_a_p,
   input         din_a_n,
   input         din_b_p,
   input         din_b_n,
   input         din_c_p,
   input         din_c_n,
   input         din_d_p,
   input         din_d_n,
   input         din_e_p,
   input         din_e_n,
   input         din_f_p,
   input         din_f_n,
   input         din_g_p,
   input         din_g_n,
   input         din_h_p,
   input         din_h_n,
   
   // Input Controls 
   input         din_rst_n,
   input         sel_2lane,    // 1 = 2 lanes
   input         sel_num_bits  // 0 = 16-bits (14-bit ADC), 1 = 12-bits
   );

   //==========================================================================
   // Register and wire declarations
   //==========================================================================
   wire                  iser_fco;
   wire                  iser_lane_a;
   wire                  iser_lane_b;
   wire                  iser_lane_c;
   wire                  iser_lane_d;
   wire                  iser_lane_e;
   wire                  iser_lane_f;
   wire                  iser_lane_g;
   wire                  iser_lane_h;
   wire                  fco_strobe;
   wire                  fco_position;
   wire [1:0]            iser_fco_nib;          
   wire [1:0]            iser_lane_a_nib;       
   wire [1:0]            iser_lane_b_nib;       
   wire [1:0]            iser_lane_c_nib;       
   wire [1:0]            iser_lane_d_nib;       
   wire [1:0]            iser_lane_e_nib;       
   wire [1:0]            iser_lane_f_nib;       
   wire [1:0]            iser_lane_g_nib;       
   wire [1:0]            iser_lane_h_nib;       
         
   //==========================================================================
   // Input Buffers
   //==========================================================================
   IBUFDS IB1 (.I(din_fco_p), .IB(din_fco_n), .O(iser_fco));
   IBUFDS IB2 (.I(din_a_p),   .IB(din_a_n),   .O(iser_lane_a));
   IBUFDS IB3 (.I(din_b_p),   .IB(din_b_n),   .O(iser_lane_b));
   IBUFDS IB4 (.I(din_c_p),   .IB(din_c_n),   .O(iser_lane_c));
   IBUFDS IB5 (.I(din_d_p),   .IB(din_d_n),   .O(iser_lane_d));
   IBUFDS IB6 (.I(din_e_p),   .IB(din_e_n),   .O(iser_lane_e));
   IBUFDS IB7 (.I(din_f_p),   .IB(din_f_n),   .O(iser_lane_f));
   IBUFDS IB8 (.I(din_g_p),   .IB(din_g_n),   .O(iser_lane_g));
   IBUFDS IB9 (.I(din_h_p),   .IB(din_h_n),   .O(iser_lane_h));
   
   BUFG   BG1 (.I(iser_fco), .O(fco_clk));
  
   //==========================================================================
   // Deserialize each lane into 4-bit nibbles 
   //==========================================================================
   iser_ddr 
     iser_ddr_f0
     (// Outputs
      .dout                             (iser_fco_nib),
      // Inputs
      .din                              (iser_fco),
      .data_clk                         (data_clk));

   iser_ddr 
     iser_ddr_i0
     (// Outputs
      .dout                             (iser_lane_a_nib),
      // Inputs
      .din                              (iser_lane_a),
      .data_clk                         (data_clk));

   iser_ddr 
     iser_ddr_i1
     (// Outputs
      .dout                             (iser_lane_b_nib),
      // Inputs
      .din                              (iser_lane_b),
      .data_clk                         (data_clk));

   iser_ddr 
     iser_ddr_i2
     (// Outputs
      .dout                             (iser_lane_c_nib),
      // Inputs
      .din                              (iser_lane_c),
      .data_clk                         (data_clk));

   iser_ddr 
     iser_ddr_i3
     (// Outputs
      .dout                             (iser_lane_d_nib),
      // Inputs
      .din                              (iser_lane_d),
      .data_clk                         (data_clk));

   iser_ddr 
     iser_ddr_i4
     (// Outputs
      .dout                             (iser_lane_e_nib),
      // Inputs
      .din                              (iser_lane_e),
      .data_clk                         (data_clk));

   iser_ddr 
     iser_ddr_i5
     (// Outputs
      .dout                             (iser_lane_f_nib),
      // Inputs
      .din                              (iser_lane_f),
      .data_clk                         (data_clk));

   iser_ddr 
     iser_ddr_i6
     (// Outputs
      .dout                             (iser_lane_g_nib),
      // Inputs
      .din                              (iser_lane_g),
      .data_clk                         (data_clk));

   iser_ddr 
     iser_ddr_i7
     (// Outputs
      .dout                             (iser_lane_h_nib),
      // Inputs
      .din                              (iser_lane_h),
      .data_clk                         (data_clk));

   //==========================================================================
   // Generate capture strobe based on FCO rising edge
   //==========================================================================
   iser_fco_strobe
     iser_fco_strobe
     (// Outputs
      .fco_strobe                       (fco_strobe),
      .fco_position                     (fco_position),
      .fco_ready                        (fco_clk_rdy),
      // Inputs
      .fco_din                          (iser_fco_nib),
      .fco_rst_n                        (din_rst_n),
      .fco_dclk                         (data_clk),
      .fco_dclk_rdy                     (data_clk_rdy));         
        
   //==========================================================================
   // Deserialize data based on mode and FCO strobe 
   //==========================================================================
   iser_deframe_data 
     iser_dfrm_data_i0
     (// Outputs
      .dout_0                           (iser_chan_a),
      // Inputs
      .din_nib_0                        (iser_lane_a_nib),
      .din_nib_1                        (iser_lane_b_nib),
      .fco_clk                          (fco_clk),
      .fco_strobe                       (fco_strobe),
      .fco_position                     (fco_position),
      .data_clk                         (data_clk),
      .sel_2lane                        (sel_2lane),
      .sel_num_bits                     (sel_num_bits));         

   iser_deframe_data 
     iser_dfrm_data_i1
     (// Outputs
      .dout_0                           (iser_chan_c),
      // Inputs
      .din_nib_0                        (iser_lane_c_nib),
      .din_nib_1                        (iser_lane_d_nib),
      .fco_clk                          (fco_clk),
      .fco_strobe                       (fco_strobe),
      .fco_position                     (fco_position),
      .data_clk                         (data_clk),
      .sel_2lane                        (sel_2lane),
      .sel_num_bits                     (sel_num_bits));         

   iser_deframe_data 
     iser_dfrm_data_i2
     (// Outputs
      .dout_0                           (iser_chan_e),
      // Inputs
      .din_nib_0                        (iser_lane_e_nib),
      .din_nib_1                        (iser_lane_f_nib),
      .fco_clk                          (fco_clk),
      .fco_strobe                       (fco_strobe),
      .fco_position                     (fco_position),
      .data_clk                         (data_clk),
      .sel_2lane                        (sel_2lane),
      .sel_num_bits                     (sel_num_bits));         

   iser_deframe_data 
     iser_dfrm_data_i3
     (// Outputs
      .dout_0                           (iser_chan_g),
      // Inputs
      .din_nib_0                        (iser_lane_g_nib),
      .din_nib_1                        (iser_lane_h_nib),
      .fco_clk                          (fco_clk),
      .fco_strobe                       (fco_strobe),
      .fco_position                     (fco_position),
      .data_clk                         (data_clk),
      .sel_2lane                        (sel_2lane),
      .sel_num_bits                     (sel_num_bits));         
     
endmodule
