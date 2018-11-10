//////////////////////////////////////////////////////////////////////////////////
// Company: 		Analog Devices, Inc.
// Engineer: 		MKH
// Create Date:   02-09-2012 
//////////////////////////////////////////////////////////////////////////////////
module data_clock_ctrl # 
   (
   parameter R4_MAX            = 330000000,  // Maximum frequency of range 4
   parameter R3_MAX            = 155000000,  // Maximum frequency of range 3
   parameter R2_MAX            =  70000000,  // Maximum frequency of range 2
   parameter R1_MAX            =  35000000,   // Maximum frequency of range 1
   parameter CLKFBOUT_MULT_F   =        30,
   parameter DIVCLK_DIVIDE     =        15,
   parameter CLKOUT1_DIVIDE    =         2,
   parameter CLKOUT1_PHASE     =         0,
   parameter CLKOUT2_DIVIDE    =         2,
   parameter CLKOUT2_PHASE     =         0,
   parameter S1_CLKFBOUT_MULT  =        30,
   parameter S1_DIVCLK_DIVIDE  =        15,
   parameter S1_CLKOUT1_DIVIDE =         2,
   parameter S1_CLKOUT1_PHASE  =         0,
   parameter S1_CLKOUT2_DIVIDE =         2,
   parameter S1_CLKOUT2_PHASE  =         0,
   parameter S2_CLKFBOUT_MULT  =        30,
   parameter S2_DIVCLK_DIVIDE  =        15,
   parameter S2_CLKOUT1_DIVIDE =         2,
   parameter S2_CLKOUT1_PHASE  =         0,
   parameter S2_CLKOUT2_DIVIDE =         2,
   parameter S2_CLKOUT2_PHASE  =         0,
   parameter S3_CLKFBOUT_MULT  =        30,
   parameter S3_DIVCLK_DIVIDE  =        15,
   parameter S3_CLKOUT1_DIVIDE =         2,
   parameter S3_CLKOUT1_PHASE  =         0,
   parameter S3_CLKOUT2_DIVIDE =         2,
   parameter S3_CLKOUT2_PHASE  =         0,
   parameter S4_CLKFBOUT_MULT  =        30,
   parameter S4_DIVCLK_DIVIDE  =        15,
   parameter S4_CLKOUT1_DIVIDE =         2,
   parameter S4_CLKOUT1_PHASE  =         0,
   parameter S4_CLKOUT2_DIVIDE =         2,
   parameter S4_CLKOUT2_PHASE  =         0,
   parameter S5_CLKFBOUT_MULT  =        30,
   parameter S5_DIVCLK_DIVIDE  =        15,
   parameter S5_CLKOUT1_DIVIDE =         2,
   parameter S5_CLKOUT1_PHASE  =         0,
   parameter S5_CLKOUT2_DIVIDE =         2,
   parameter S5_CLKOUT2_PHASE  =         0
    )
   (
   output        data_clk,
   output        data_clk_dv,
   output        data_clk_rdy,
   input         user_reset_n,
   input         dut_sync_rdy,
   input         drp_ref_clk,
   input         dco_p,
   input         dco_n
   );

   //==========================================================================
   // Wire and register declarations
   //==========================================================================
   wire                              dco_buf;
   wire [2:0]                        freq_mode;     

   //==========================================================================
   // Input clock buffer
   //==========================================================================
   IBUFGDS bufds (.I(dco_p), .IB(dco_n), .O(dco_buf));
   
   //==========================================================================
   // Instantiate MMCM frequency counter
   //==========================================================================
   mmcm_freq_counter # (                         // Range 5: >R4_MAX 
      .R4_MAX                         (R4_MAX),  // Range 4: <R4_MAX, >R3_MAX
      .R3_MAX                         (R3_MAX),  // Range 3: <R3_MAX, >R2_MAX
      .R2_MAX                         (R2_MAX),  // Range 2: <R2_MAX, >R1_MAX
      .R1_MAX                         (R1_MAX)   // Range 1: <R1_MAX
      ) 
      mmcm_freq_count 
     (// Outputs
      .freq_mode                      (freq_mode),
      .count_done                     (count_done),
      // Inputs
      .reset_n                        (user_reset_n),
      .dut_sync_rdy                   (dut_sync_rdy),
      .drp_refclk                     (drp_ref_clk), 
      .dco_clk                        (dco_buf)); 

   //==========================================================================
   // Reset controller
   //==========================================================================
   drp_start_ctrl drp_start_ctrl 
     (// Outputs
      .drp_start                      (drp_start),
      // Inputs
      .reset_n                        (user_reset_n),
      .clkin                          (drp_ref_clk),
      .count_done                     (count_done));
 
   //==========================================================================
   // Instantiate MMCM with DRP controller
   // M and D parameters must be set per DUT
   //==========================================================================
   mmcm_top # (
      // Initial State
      .CLKFBOUT_MULT_F                (CLKFBOUT_MULT_F),  
      .DIVCLK_DIVIDE                  (DIVCLK_DIVIDE),
      .CLKOUT1_DIVIDE                 (CLKOUT1_DIVIDE),
      .CLKOUT1_PHASE                  (CLKOUT1_PHASE),
      .CLKOUT2_DIVIDE                 (CLKOUT2_DIVIDE),
      .CLKOUT2_PHASE                  (CLKOUT2_PHASE),
      // State 1
      .S1_CLKFBOUT_MULT               (S1_CLKFBOUT_MULT),  
      .S1_DIVCLK_DIVIDE               (S1_DIVCLK_DIVIDE),
      .S1_CLKOUT1_DIVIDE              (S1_CLKOUT1_DIVIDE),
      .S1_CLKOUT1_PHASE               (S1_CLKOUT1_PHASE),
      .S1_CLKOUT2_DIVIDE              (S1_CLKOUT2_DIVIDE),
      .S1_CLKOUT2_PHASE               (S1_CLKOUT2_PHASE),
      // State 2
      .S2_CLKFBOUT_MULT               (S2_CLKFBOUT_MULT),  
      .S2_DIVCLK_DIVIDE               (S2_DIVCLK_DIVIDE),
      .S2_CLKOUT1_DIVIDE              (S2_CLKOUT1_DIVIDE),
      .S2_CLKOUT1_PHASE               (S2_CLKOUT1_PHASE),
      .S2_CLKOUT2_DIVIDE              (S2_CLKOUT2_DIVIDE),
      .S2_CLKOUT2_PHASE               (S2_CLKOUT2_PHASE),
      // State 3
      .S3_CLKFBOUT_MULT               (S3_CLKFBOUT_MULT),  
      .S3_DIVCLK_DIVIDE               (S3_DIVCLK_DIVIDE),
      .S3_CLKOUT1_DIVIDE              (S3_CLKOUT1_DIVIDE),
      .S3_CLKOUT1_PHASE               (S3_CLKOUT1_PHASE),
      .S3_CLKOUT2_DIVIDE              (S3_CLKOUT2_DIVIDE),
      .S3_CLKOUT2_PHASE               (S3_CLKOUT2_PHASE),
      // State 4
      .S4_CLKFBOUT_MULT               (S4_CLKFBOUT_MULT),  
      .S4_DIVCLK_DIVIDE               (S4_DIVCLK_DIVIDE),
      .S4_CLKOUT1_DIVIDE              (S4_CLKOUT1_DIVIDE),
      .S4_CLKOUT1_PHASE               (S4_CLKOUT1_PHASE),
      .S4_CLKOUT2_DIVIDE              (S4_CLKOUT2_DIVIDE),
      .S4_CLKOUT2_PHASE               (S4_CLKOUT2_PHASE),
      // State 5
      .S5_CLKFBOUT_MULT               (S5_CLKFBOUT_MULT),  
      .S5_DIVCLK_DIVIDE               (S5_DIVCLK_DIVIDE),
      .S5_CLKOUT1_DIVIDE              (S5_CLKOUT1_DIVIDE),
      .S5_CLKOUT1_PHASE               (S5_CLKOUT1_PHASE),
      .S5_CLKOUT2_DIVIDE              (S5_CLKOUT2_DIVIDE),
      .S5_CLKOUT2_PHASE               (S5_CLKOUT2_PHASE)
      )
      mmcm_top
     (// Outputs
      .CLK1OUT                        (data_clk),
      .CLK2OUT                        (data_clk_dv),
      .SRDY                           (data_clk_rdy),
      // Inputs
      .RST_N                          (user_reset_n),  
      .SSTEP                          (drp_start),     // SSTEP is the input to start a reconfiguration.  It should only be pulsed for one clock cycle.
      .STATE                          (freq_mode),     // STATE determines which state the MMCM_ADV will be reconfigured to.  
      .CLKIN                          (dco_buf), 
      .CLKIN_DRP                      (drp_ref_clk));  

endmodule
