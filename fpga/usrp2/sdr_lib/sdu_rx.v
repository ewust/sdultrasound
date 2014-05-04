module sdu_rx(
	input clk,
	input reset,

	//SDUltrasound control signals
	output reg sdu_rx_en,
	output reg sdu_seq_done_strobe,
	output reg sdu_ave_done_strobe,

	//PC interface
	output [15:0] sdu_rx_data,
	output sdu_rx_strobe,

	//Raw ADC input
	input [15:0] adc_in
);

endmodule

