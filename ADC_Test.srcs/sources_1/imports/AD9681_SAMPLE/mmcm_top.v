//////////////////////////////////////////////////////////////////////////////////
// Company: 		Analog Devices, Inc.
// Engineer: 		MKH
// Create Date:   02-09-2012 
//////////////////////////////////////////////////////////////////////////////////
module mmcm_top # 
   (
    parameter CLKFBOUT_MULT_F   = 5,
    parameter DIVCLK_DIVIDE     = 1,
    parameter CLKOUT1_DIVIDE    = 1,
    parameter CLKOUT1_PHASE     = 0,
    parameter CLKOUT2_DIVIDE    = 1,
    parameter CLKOUT2_PHASE     = 0,
    parameter CLKOUT3_DIVIDE    = 1,
    parameter CLKOUT3_PHASE     = 0,
    parameter CLKOUT4_DIVIDE    = 1,
    parameter CLKOUT4_PHASE     = 0,
    parameter S1_CLKFBOUT_MULT  = 5,
    parameter S1_DIVCLK_DIVIDE  = 1,
    parameter S1_CLKOUT1_DIVIDE = 1,
    parameter S1_CLKOUT1_PHASE  = 0,
    parameter S1_CLKOUT2_DIVIDE = 1,
    parameter S1_CLKOUT2_PHASE  = 0,
    parameter S1_CLKOUT3_DIVIDE = 1,
    parameter S1_CLKOUT3_PHASE  = 0,
    parameter S1_CLKOUT4_DIVIDE = 1,
    parameter S1_CLKOUT4_PHASE  = 0,
    parameter S2_CLKFBOUT_MULT  = 5,
    parameter S2_DIVCLK_DIVIDE  = 1,
    parameter S2_CLKOUT1_DIVIDE = 1,
    parameter S2_CLKOUT1_PHASE  = 0,
    parameter S2_CLKOUT2_DIVIDE = 1,
    parameter S2_CLKOUT2_PHASE  = 0,
    parameter S2_CLKOUT3_DIVIDE = 1,
    parameter S2_CLKOUT3_PHASE  = 0,
    parameter S2_CLKOUT4_DIVIDE = 1,
    parameter S2_CLKOUT4_PHASE  = 0,
    parameter S3_CLKFBOUT_MULT  = 5,
    parameter S3_DIVCLK_DIVIDE  = 1,
    parameter S3_CLKOUT1_DIVIDE = 1,
    parameter S3_CLKOUT1_PHASE  = 0,
    parameter S3_CLKOUT2_DIVIDE = 1,
    parameter S3_CLKOUT2_PHASE  = 0,
    parameter S3_CLKOUT3_DIVIDE = 1,
    parameter S3_CLKOUT3_PHASE  = 0,
    parameter S3_CLKOUT4_DIVIDE = 1,
    parameter S3_CLKOUT4_PHASE  = 0,
    parameter S4_CLKFBOUT_MULT  = 5,
    parameter S4_DIVCLK_DIVIDE  = 1,
    parameter S4_CLKOUT1_DIVIDE = 1,
    parameter S4_CLKOUT1_PHASE  = 0,
    parameter S4_CLKOUT2_DIVIDE = 1,
    parameter S4_CLKOUT2_PHASE  = 0,
    parameter S4_CLKOUT3_DIVIDE = 1,
    parameter S4_CLKOUT3_PHASE  = 0,
    parameter S4_CLKOUT4_DIVIDE = 1,
    parameter S4_CLKOUT4_PHASE  = 0,
    parameter S5_CLKFBOUT_MULT  = 5,
    parameter S5_DIVCLK_DIVIDE  = 1,
    parameter S5_CLKOUT1_DIVIDE = 1,
    parameter S5_CLKOUT1_PHASE  = 0,
    parameter S5_CLKOUT2_DIVIDE = 1,
    parameter S5_CLKOUT2_PHASE  = 0,
    parameter S5_CLKOUT3_DIVIDE = 1,
    parameter S5_CLKOUT3_PHASE  = 0,
    parameter S5_CLKOUT4_DIVIDE = 1,
    parameter S5_CLKOUT4_PHASE  = 0
    )
   (
      // RST, active low
      input        RST_N,

      // SSTEP is the input to start a reconfiguration.  It should only be
      // pulsed for one clock cycle.
      input        SSTEP,
      
      // STATE determines which state the MMCM_ADV will be reconfigured to.  A 
      // value of 0 correlates to state 1, and a value of 1 correlates to state 
      // 2, etc.
      input  [2:0] STATE,

      // CLKIN is the input clock that feeds the MMCM_ADV CLKIN
      input        CLKIN,

      // CLKIN_DRP is the input clock that feeds the MMCM_DRP module
      input        CLKIN_DRP,

      // MMCM_ADV is locked and the 
      // MMCM_DRP module is ready to start another re-configuration
      output       SRDY,
      
      // These are the clock outputs from the MMCM_ADV.
      output       CLK1OUT,
      output       CLK2OUT,
      output       CLK3OUT,
      output       CLK4OUT
   );
   
   //==========================================================================
   // Wire and register declarations
   //==========================================================================
   wire           den;
   wire           dwe;
   wire           dclk;
   wire           drdy;
   wire           clkfb_i;
   wire           clkfb_o;   
   wire           locked;
   wire           rst_mmcm;   
   wire           clk1_bufin;
   wire           clk2_bufin;
   wire [6:0]     daddr;
   wire [15:0]    di;
   wire [15:0]    dout;

   //==========================================================================
   // Clock output buffers
   //=========================================================================   
   BUFG BUF_CLK1 (.I(clk1_bufin), .O(CLK1OUT));
   BUFG BUF_CLK2 (.I(clk2_bufin), .O(CLK2OUT));
   BUFG BUF_CLK3 (.I(clk3_bufin), .O(CLK3OUT));
   BUFG BUF_CLK4 (.I(clk4_bufin), .O(CLK4OUT));

   //==========================================================================
   // Clock feedback buffer
   //=========================================================================   
   BUFG  BUFG_CLKFB (.I(clkfb_o), .O(clkfb_i));
        
   //==========================================================================
   // Instantiate MMCM_ADV that reconfiguration will take place on
   //==========================================================================
   MMCM_ADV #
     (
      .DIVCLK_DIVIDE                      (DIVCLK_DIVIDE), 
      .CLKFBOUT_MULT_F                    (CLKFBOUT_MULT_F), 
      .CLKOUT1_DIVIDE                     (CLKOUT1_DIVIDE), 
      .CLKOUT1_PHASE                      (CLKOUT1_PHASE),
      .CLKOUT2_DIVIDE                     (CLKOUT2_DIVIDE), 
      .CLKOUT2_PHASE                      (CLKOUT2_PHASE),
      .CLKOUT3_DIVIDE                     (CLKOUT3_DIVIDE), 
      .CLKOUT3_PHASE                      (CLKOUT3_PHASE),
      .CLKOUT4_DIVIDE                     (CLKOUT4_DIVIDE), 
      .CLKOUT4_PHASE                      (CLKOUT4_PHASE)
     ) 
    mmcm_inst 
     (
      .CLKFBOUT                           (clkfb_o),
      .CLKFBIN                            (clkfb_i), 
      .CLKOUT1                            (clk1_bufin),
      .CLKOUT2                            (clk2_bufin),
      .CLKOUT3                            (clk3_bufin),
      .CLKOUT4                            (clk4_bufin),
      .DO                                 (dout),        // 16-bits
      .DRDY                               (drdy), 
      .DADDR                              (daddr),       // 5 bits
      .DCLK                               (dclk), 
      .DEN                                (den), 
      .DI                                 (di),          // 16 bits
      .DWE                                (dwe), 
      .LOCKED                             (locked), 
      .CLKIN1                             (CLKIN),
      .CLKIN2                             (1'b0),
      .CLKINSEL                           (1'b1), 
      .PSDONE                             (),
      .PSCLK                              (1'b0),
      .PSEN                               (1'b0),
      .PSINCDEC                           (1'b0),
      .PWRDWN                             (1'b0),
      .RST                                (rst_mmcm));
   
   //==========================================================================
   // MMCM_DRP instance that will perform the reconfiguration operations
   //==========================================================================
   mmcm_drp #(
      //***********************************************************************
      // State 1 Parameters
      //***********************************************************************
      .S1_CLKFBOUT_MULT                   (S1_CLKFBOUT_MULT),
      .S1_CLKFBOUT_PHASE                  (0),
      .S1_BANDWIDTH                       ("OPTIMIZED"),
      .S1_DIVCLK_DIVIDE                   (S1_DIVCLK_DIVIDE),
      // Set clock out 0 to a divide of 1, 0deg phase offset, 50/50 duty cycle
      .S1_CLKOUT0_DIVIDE                  (1),
      .S1_CLKOUT0_PHASE                   (0),
      .S1_CLKOUT0_DUTY                    (50000),
      // Set clock out 1
      .S1_CLKOUT1_DIVIDE                  (S1_CLKOUT1_DIVIDE),
      .S1_CLKOUT1_PHASE                   (S1_CLKOUT1_PHASE),
      .S1_CLKOUT1_DUTY                    (50000),
      // Set clock out 2
      .S1_CLKOUT2_DIVIDE                  (S1_CLKOUT2_DIVIDE),
      .S1_CLKOUT2_PHASE                   (S1_CLKOUT2_PHASE),
      .S1_CLKOUT2_DUTY                    (50000),
      // Set clock out 3
      .S1_CLKOUT3_DIVIDE                  (S1_CLKOUT3_DIVIDE),
      .S1_CLKOUT3_PHASE                   (S1_CLKOUT3_PHASE),
      .S1_CLKOUT3_DUTY                    (50000),
      // Set clock out 4
      .S1_CLKOUT4_DIVIDE                  (S1_CLKOUT4_DIVIDE),
      .S1_CLKOUT4_PHASE                   (S1_CLKOUT4_PHASE),
      .S1_CLKOUT4_DUTY                    (50000),
      // Set clock out 5
      .S1_CLKOUT5_DIVIDE                  (1),
      .S1_CLKOUT5_PHASE                   (0),
      .S1_CLKOUT5_DUTY                    (50000),
      // Set clock out 6
      .S1_CLKOUT6_DIVIDE                  (1),
      .S1_CLKOUT6_PHASE                   (0),
      .S1_CLKOUT6_DUTY                    (50000),
      //***********************************************************************
      // State 2 Parameters
      //***********************************************************************
      .S2_CLKFBOUT_MULT                   (S2_CLKFBOUT_MULT),
      .S2_CLKFBOUT_PHASE                  (0),
      .S2_BANDWIDTH                       ("OPTIMIZED"),
      .S2_DIVCLK_DIVIDE                   (S2_DIVCLK_DIVIDE),
      // Set clock out 0 to a divide of 1, 0deg phase offset, 50/50 duty cycle
      .S2_CLKOUT0_DIVIDE                  (1),
      .S2_CLKOUT0_PHASE                   (0),
      .S2_CLKOUT0_DUTY                    (50000),
      // Set clock out 1
      .S2_CLKOUT1_DIVIDE                  (S2_CLKOUT1_DIVIDE),
      .S2_CLKOUT1_PHASE                   (S2_CLKOUT1_PHASE),
      .S2_CLKOUT1_DUTY                    (50000),
      // Set clock out 2
      .S2_CLKOUT2_DIVIDE                  (S2_CLKOUT2_DIVIDE),
      .S2_CLKOUT2_PHASE                   (S2_CLKOUT2_PHASE),
      .S2_CLKOUT2_DUTY                    (50000),
      // Set clock out 3
      .S2_CLKOUT3_DIVIDE                  (S2_CLKOUT3_DIVIDE),
      .S2_CLKOUT3_PHASE                   (S2_CLKOUT3_PHASE),
      .S2_CLKOUT3_DUTY                    (50000),
      // Set clock out 4
      .S2_CLKOUT4_DIVIDE                  (S2_CLKOUT4_DIVIDE),
      .S2_CLKOUT4_PHASE                   (S2_CLKOUT4_PHASE),
      .S2_CLKOUT4_DUTY                    (50000),
      // Set clock out 5
      .S2_CLKOUT5_DIVIDE                  (1),
      .S2_CLKOUT5_PHASE                   (0),
      .S2_CLKOUT5_DUTY                    (50000),
      // Set clock out 6
      .S2_CLKOUT6_DIVIDE                  (1),
      .S2_CLKOUT6_PHASE                   (0),
      .S2_CLKOUT6_DUTY                    (50000),
      //***********************************************************************
      // State 3 Parameters
      //***********************************************************************
      .S3_CLKFBOUT_MULT                   (S3_CLKFBOUT_MULT),
      .S3_CLKFBOUT_PHASE                  (0),
      .S3_BANDWIDTH                       ("OPTIMIZED"),
      .S3_DIVCLK_DIVIDE                   (S3_DIVCLK_DIVIDE),
      // Set clock out 0 to a divide of 1, 0deg phase offset, 50/50 duty cycle
      .S3_CLKOUT0_DIVIDE                  (1),
      .S3_CLKOUT0_PHASE                   (0),
      .S3_CLKOUT0_DUTY                    (50000),
      // Set clock out 1
      .S3_CLKOUT1_DIVIDE                  (S3_CLKOUT1_DIVIDE),
      .S3_CLKOUT1_PHASE                   (S3_CLKOUT1_PHASE),
      .S3_CLKOUT1_DUTY                    (50000),
      // Set clock out 2
      .S3_CLKOUT2_DIVIDE                  (S3_CLKOUT2_DIVIDE),
      .S3_CLKOUT2_PHASE                   (S3_CLKOUT2_PHASE),
      .S3_CLKOUT2_DUTY                    (50000),
      // Set clock out 3
      .S3_CLKOUT3_DIVIDE                  (S3_CLKOUT3_DIVIDE),
      .S3_CLKOUT3_PHASE                   (S3_CLKOUT3_PHASE),
      .S3_CLKOUT3_DUTY                    (50000),
      // Set clock out 4
      .S3_CLKOUT4_DIVIDE                  (S3_CLKOUT4_DIVIDE),
      .S3_CLKOUT4_PHASE                   (S3_CLKOUT4_PHASE),
      .S3_CLKOUT4_DUTY                    (50000),
      // Set clock out 5
      .S3_CLKOUT5_DIVIDE                  (1),
      .S3_CLKOUT5_PHASE                   (0),
      .S3_CLKOUT5_DUTY                    (50000),
      // Set clock out 6
      .S3_CLKOUT6_DIVIDE                  (1),
      .S3_CLKOUT6_PHASE                   (0),
      .S3_CLKOUT6_DUTY                    (50000),
      //***********************************************************************
      // State 4 Parameters
      //***********************************************************************
      .S4_CLKFBOUT_MULT                   (S4_CLKFBOUT_MULT),
      .S4_CLKFBOUT_PHASE                  (0),
      .S4_BANDWIDTH                       ("OPTIMIZED"),
      .S4_DIVCLK_DIVIDE                   (S4_DIVCLK_DIVIDE),
      // Set clock out 0 to a divide of 1, 0deg phase offset, 50/50 duty cycle
      .S4_CLKOUT0_DIVIDE                  (1),
      .S4_CLKOUT0_PHASE                   (0),
      .S4_CLKOUT0_DUTY                    (50000),
      // Set clock out 1
      .S4_CLKOUT1_DIVIDE                  (S4_CLKOUT1_DIVIDE),
      .S4_CLKOUT1_PHASE                   (S4_CLKOUT1_PHASE),
      .S4_CLKOUT1_DUTY                    (50000),
      // Set clock out 2
      .S4_CLKOUT2_DIVIDE                  (S4_CLKOUT2_DIVIDE),
      .S4_CLKOUT2_PHASE                   (S4_CLKOUT2_PHASE),
      .S4_CLKOUT2_DUTY                    (50000),
      // Set clock out 3
      .S4_CLKOUT3_DIVIDE                  (S4_CLKOUT3_DIVIDE),
      .S4_CLKOUT3_PHASE                   (S4_CLKOUT3_PHASE),
      .S4_CLKOUT3_DUTY                    (50000),
      // Set clock out 4
      .S4_CLKOUT4_DIVIDE                  (S4_CLKOUT4_DIVIDE),
      .S4_CLKOUT4_PHASE                   (S4_CLKOUT4_PHASE),
      .S4_CLKOUT4_DUTY                    (50000),
      // Set clock out 5
      .S4_CLKOUT5_DIVIDE                  (1),
      .S4_CLKOUT5_PHASE                   (0),
      .S4_CLKOUT5_DUTY                    (50000),
      // Set clock out 6
      .S4_CLKOUT6_DIVIDE                  (1),
      .S4_CLKOUT6_PHASE                   (0),
      .S4_CLKOUT6_DUTY                    (50000),
      //***********************************************************************
      // State 5 Parameters
      //***********************************************************************
      .S5_CLKFBOUT_MULT                   (S5_CLKFBOUT_MULT),
      .S5_CLKFBOUT_PHASE                  (0),
      .S5_BANDWIDTH                       ("OPTIMIZED"),
      .S5_DIVCLK_DIVIDE                   (S5_DIVCLK_DIVIDE),
      // Set clock out 0 to a divide of 1, 0deg phase offset, 50/50 duty cycle
      .S5_CLKOUT0_DIVIDE                  (1),
      .S5_CLKOUT0_PHASE                   (0),
      .S5_CLKOUT0_DUTY                    (50000),
      // Set clock out 1
      .S5_CLKOUT1_DIVIDE                  (S5_CLKOUT1_DIVIDE),
      .S5_CLKOUT1_PHASE                   (S5_CLKOUT1_PHASE),
      .S5_CLKOUT1_DUTY                    (50000),
      // Set clock out 2
      .S5_CLKOUT2_DIVIDE                  (S5_CLKOUT2_DIVIDE),
      .S5_CLKOUT2_PHASE                   (S5_CLKOUT2_PHASE),
      .S5_CLKOUT2_DUTY                    (50000),
      // Set clock out 3
      .S5_CLKOUT3_DIVIDE                  (S5_CLKOUT3_DIVIDE),
      .S5_CLKOUT3_PHASE                   (S5_CLKOUT3_PHASE),
      .S5_CLKOUT3_DUTY                    (50000),
      // Set clock out 4
      .S5_CLKOUT4_DIVIDE                  (S5_CLKOUT4_DIVIDE),
      .S5_CLKOUT4_PHASE                   (S5_CLKOUT4_PHASE),
      .S5_CLKOUT4_DUTY                    (50000),
      // Set clock out 5
      .S5_CLKOUT5_DIVIDE                  (1),
      .S5_CLKOUT5_PHASE                   (0),
      .S5_CLKOUT5_DUTY                    (50000),
      // Set clock out 6
      .S5_CLKOUT6_DIVIDE                  (1),
      .S5_CLKOUT6_PHASE                   (0),
      .S5_CLKOUT6_DUTY                    (50000)
     ) 
   mmcm_drp_inst 
     (// Top port connections
      .SADDR                              (STATE),       // Input, 3-bits
      .SEN                                (SSTEP),       // Input, start pulse, active high
      .RST                                (~RST_N),      // Input, active high reset
      .SRDY                               (SRDY),        // Output, 1-bit
      .SCLK                               (CLKIN_DRP),   // Input, DRP clock
      // Direct connections to the MMCM_ADV
      .DO                                 (dout),        // Input, 16-bit data
      .DRDY                               (drdy),        // Input
      .LOCKED                             (locked),      // Input
      .DWE                                (dwe),         // Output
      .DEN                                (den),         // Output 
      .DADDR                              (daddr),       // Output, 7-bits
      .DI                                 (di),          // Output, 16-bits
      .DCLK                               (dclk),        // Output, equals SCLK
      .RST_MMCM                           (rst_mmcm));   // Output
   
endmodule
