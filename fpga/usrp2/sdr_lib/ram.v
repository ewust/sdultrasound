
module ram(clk,reset,wr_data,wr_addr,wr_en,rd_data,rd_addr);
//User-defined parameters
parameter DATA_WIDTH = 8;
parameter DEPTH_LOG2 = 4;
parameter DEPTH = (1 << DEPTH_LOG2);

//Ports
input clk;
input reset;
input [DATA_WIDTH-1:0] wr_data;
input [DEPTH_LOG2-1:0] wr_addr;
input wr_en;
output [DATA_WIDTH-1:0] rd_data;
input [DEPTH_LOG2-1:0] rd_addr;

//Locals
reg [DATA_WIDTH-1:0] ram [DEPTH-1:0];
assign rd_data = ram[rd_addr];

always @(posedge clk) begin
	if(reset) begin
		//Not sure if there's really anything to do in the reset state...
	end else begin
		if(wr_en) begin
			ram[wr_addr] <= #1 wr_data;
		end
		//rd_data <= `SD ram[rd_addr];
	end
end

endmodule

