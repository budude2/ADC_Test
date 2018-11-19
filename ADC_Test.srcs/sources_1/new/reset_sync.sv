`timescale 1ns / 1ps

// Asynchronous Input Synchronization
//
// The following code is an example of synchronizing an asynchronous input
// of a design to reduce the probability of metastability affecting a circuit.
//
// The following synthesis and implementation attributes is added to the code
// in order improve the MTBF characteristics of the implementation:
//
//  ASYNC_REG="TRUE" - Specifies registers will be receiving asynchronous data
//                     input to allow tools to report and improve metastability
//
// The following parameters are available for customization:
//
//   SYNC_STAGES     - Integer value for number of synchronizing registers, must be 2 or higher
//   PIPELINE_STAGES - Integer value for number of registers on the output of the
//                     synchronizer for the purpose of improveing performance.
//                     Particularly useful for high-fanout nets.
//   INIT            - Initial value of synchronizer registers upon startup, 1'b0 or 1'b1.

module async_input_sync
(
	input  clk,
	input  async_in,
	output sync_out
);

	logic inter0;

	(* ASYNC_REG = "true" *)
	FDPE #(
		.INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
	) FDPE_inst0 (
		.Q(inter0),      // 1-bit Data output
		.C(clk),      // 1-bit Clock input
		.CE(1),    // 1-bit Clock enable input
		.PRE(async_in),  // 1-bit Asynchronous preset input
		.D(0)       // 1-bit Data input
	);

	(* ASYNC_REG = "true" *)
	FDPE #(
		.INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
	) FDPE_inst1 (
		.Q(sync_out),      // 1-bit Data output
		.C(clk),      // 1-bit Clock input
		.CE(1),    // 1-bit Clock enable input
		.PRE(async_in),  // 1-bit Asynchronous preset input
		.D(inter0)       // 1-bit Data input
	);

endmodule