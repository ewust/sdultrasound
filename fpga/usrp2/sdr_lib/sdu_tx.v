/*This module stores the desired TX sequence and replays it at a fixed rate*/
module sdu_tx(
	input clk,
	input reset,

	//SDUltrasound control signals
	input sdu_tx_en,
	input sdu_seq_done_strobe,

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

wire [31:0] ram_addr = (sdu_tx_strobe) ? ram_wr_idx : ram_rd_idx;

//Inferred RAM block
ram #(32,16) ir1(
    .clk(clk),
    .en(1'b1),
    .we(sdu_tx_strobe),
    .addr(ram_addr),
    .do(ram_rd_data),
    .di(sdu_tx_data)
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

