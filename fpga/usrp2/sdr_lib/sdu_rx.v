module sdu_rx(
	input clk,
	input reset,

	//SDUltrasound control signals
	output reg sdu_rx_en,
	output reg sdu_seq_done_strobe,
	output reg sdu_ave_done_strobe,

	//PC interface
	output [31:0] sdu_rx_data,
	output reg sdu_rx_strobe,

	//Raw ADC input
	input [15:0] adc_in
);

parameter STATE_RESET = 0;
parameter STATE_RECORD = 1;
parameter STATE_SEQ_DONE = 2;
parameter STATE_RECORD_FINAL = 3;
parameter STATE_RECORD_PLAYBACK = 4;

//FSM logic
reg [3:0] state, next_state;
reg ram_wr_idx_reset, ram_rd_idx_reset;
reg ram_wren;
reg first_time, reset_first_time;
reg [31:0] ram_wr_idx, ram_rd_idx;

wire [31:0] ram_rd_data;
assign sdu_rx_data = ram_rd_data;
wire [31:0] adc_in_sign_ext = {{16}{adc_in[15]},adc_in};
wire [31:0] ram_wr_data = (first_time) ? adc_in_sign_ext : ram_rd_data + adc_in_sign_ext;

//Inferred RAM block
inferred_ram #(32,16) ir1(
	.clk(clk),
	.rd_addr(ram_rd_idx),
	.rd_data(ram_rd_data),
	.wr_addr(ram_wr_idx),
	.wr_data(ram_wr_data),
	.wr_en(ram_wren)
);

always @(posedge clk) begin
	if(reset) begin
		state <= #1 STATE_RESET;
		ram_wr_idx <= #1 32'd0;
		ram_rd_idx <= #1 32'd0;
		first_time <= #1 1'b1;
	end else begin
		state <= #1 next_state;
		if(ram_wr_idx_reset) begin
			ram_wr_idx <= #1 32'd0;
		end else if(ram_wren) begin
			ram_wr_idx <= #1 ram_wr_idx + 32'd1;
		end
		if(ram_rd_idx_reset) begin
			ram_rd_idx <= #1 32'd0;
		end else if(ram_rd_idx_incr) begin
			ram_rd_idx <= #1 ram_rd_idx + 32'd1;
		end
		if(reset_first_time) begin
			first_time <= #1 1'b0;
		end
	end
end

always @* begin
	next_state = state;
	ram_wr_idx_reset = 1'b0;
	ram_rd_idx_reset = 1'b0;
	ram_rd_idx_incr = 1'b0;
	sdu_rx_strobe = 1'b0;
	ram_wren = 1'b0;
	reset_first_time = 1'b0;
	
	case(state)
		STATE_RESET: begin
			ram_wr_idx_reset = 1'b1;
			ram_rd_idx_reset = 1'b1;
			if(sdu_rx_en) begin
				next_state = STATE_RECORD;
			end
		end
		
		STATE_RECORD: begin
			ram_wren = 1'b1;
			ram_rd_idx_incr = 1'b1;
			if(sdu_ave_done_strobe) begin
				next_state = STATE_RECORD_FINAL;
			end else if(sdu_seq_done_strobe) begin
				next_state = STATE_SEQ_DONE;
			end
		end
		
		STATE_SEQ_DONE: begin
			reset_first_time = 1'b1;
			next_state = STATE_RESET;
		end
		
		STATE_RECORD_FINAL: begin
			ram_rd_idx_reset = 1'b1;
			next_state = STATE_RECORD_PLAYBACK;
		end
		
		STATE_RECORD_PLAYBACK: begin
			sdu_rx_strobe = 1'b1;
			ram_rd_idx_incr = 1'b1;
			if(ram_rd_idx == ram_wr_idx) begin
				next_state = STATE_RESET;
			end
		end
	endcase
end

endmodule

