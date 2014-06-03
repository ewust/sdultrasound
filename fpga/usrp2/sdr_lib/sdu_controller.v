module sdu_controller #(parameter BASE=0)(
	input clk,
	input reset,

	//Settings register interface
	input set_stb,
	input [7:0] set_addr,
	input [31:0] set_data,

	//SDUltrasound control signals
	output reg sdu_tx_en,
	output reg sdu_rx_en,
	output reg sdu_seq_done_strobe,
	output reg sdu_ave_done_strobe
);

//SDUltrasound settings
wire [31:0] sdu_tx_len;
wire [31:0] sdu_seq_len;
wire [31:0] sdu_num_ave;

setting_reg #(.my_addr(BASE+0), .width(32)) sr_0
(.clk(clk),.rst(reset),.strobe(set_stb),.addr(set_addr),
 .in(set_data),.out(sdu_tx_len),.changed());

setting_reg #(.my_addr(BASE+0), .width(32)) sr_1
(.clk(clk),.rst(reset),.strobe(set_stb),.addr(set_addr),
 .in(set_data),.out(sdu_seq_len),.changed());

setting_reg #(.my_addr(BASE+0), .width(32)) sr_2
(.clk(clk),.rst(reset),.strobe(set_stb),.addr(set_addr),
 .in(set_data),.out(sdu_num_ave),.changed());

//Local primitives
reg [31:0] clk_counter;
reg [31:0] seq_counter;

always @(posedge clk) begin
	if(reset) begin
		sdu_tx_en <= #1 1'b0;
		sdu_rx_en <= #1 1'b0;
		sdu_seq_done_strobe <= #1 1'b0;
		sdu_ave_done_strobe <= #1 1'b0;
		clk_counter <= #1 32'd0;
		seq_counter <= #1 32'd0;
	end else begin
		sdu_seq_done_strobe <= #1 1'b0;
		sdu_ave_done_strobe <= #1 1'b0;

		if(clk_counter == sdu_seq_len-1) begin
			clk_counter <= #1 32'd0;
			sdu_seq_done_strobe <= 1'b1;
			if(seq_counter == sdu_num_ave) begin
				seq_counter <= #1 32'd0;
				sdu_ave_done_strobe <= #1 1'b1;
			end else begin
				seq_counter <= #1 seq_counter + 32'd1;
			end
		end else begin
			clk_counter <= #1 clk_counter + 32'd1;
		end

		//A sequence consists of:
		//  TX for sdu_tx_len samples
		//  RX for sdu_seq_len-sdu_tx_len samples
		if(clk_counter < sdu_tx_len) begin
			sdu_tx_en <= #1 1'b1;
			sdu_rx_en <= #1 1'b0;
		end else begin
			sdu_tx_en <= #1 1'b0;
			sdu_rx_en <= #1 1'b1;
		end
	end
end


endmodule

