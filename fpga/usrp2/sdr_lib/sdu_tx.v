/*This module stores the desired TX sequence and replays it at a fixed rate*/
module sdu_tx(
	input clk,
	input reset,

	//SDUltrasound control signals
	output reg sdu_tx_en,
	output reg sdu_seq_done_strobe,

	//PC interface
	input [15:0] sdu_tx_data,
	input sdu_tx_strobe,

	//Raw DAC output
	output [15:0] dac_out
);

endmodule

