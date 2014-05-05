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

wire [15:0] ram_rd_data;
wire [15:0] ram_wr_data = sdu_tx_data;
reg [15:0] ram_wr_idx, ram_rd_idx;
assign dac_out = ram_rd_data;

//Inferred RAM block
inferred_ram #(16,16) ir1(
	.clk(clk),
	.rd_addr(ram_rd_idx),
	.rd_data(ram_rd_data),
	.wr_addr(ram_wr_idx),
	.wr_data(sdu_tx_data),
	.wr_en(sdu_tx_strobe)
);

always @(posedge clk) begin
	if(reset) begin
		ram_wr_idx <= #1 16'd0;
		ram_rd_idx <= #1 16'd0;
	end else begin
		if(sdu_tx_strobe) begin
			ram_wr_idx <= #1 ram_wr_idx + 16'd1;
		end
		if(sdu_tx_en) begin
			ram_rd_idx <= #1 ram_rd_idx + 16'd1;
		end else begin
			ram_rd_idx <= #1 16'd0;
		end
	end
end

endmodule

