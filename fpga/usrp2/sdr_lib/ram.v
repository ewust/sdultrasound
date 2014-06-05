
module ram (clk, en, we, addr, di, do);

//User-defined parameters
parameter DATA_WIDTH = 8;
parameter DEPTH_LOG2 = 4;
parameter DEPTH = (1 << DEPTH_LOG2);

input clk;
input we;
input en;
input [DEPTH_LOG2-1:0] addr;
input [DATA_WIDTH-1:0] di;
output [DATA_WIDTH-1:0] do;

//Locals
reg [DATA_WIDTH-1:0] RAM [DEPTH-1:0];
reg [DATA_WIDTH-1:0] do;

always @(posedge clk)
begin
    if (en)
    begin
        if (we)
            RAM[addr]<=di;
        do <= RAM[addr];
    end
end

endmodule

