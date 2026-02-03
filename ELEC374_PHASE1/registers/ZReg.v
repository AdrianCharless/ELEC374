module ZREG (
	input			clear, clock, Zenable,
	input	[63:0]	Zinput,
	//output	[63:0]	Z, just for debugging purposes
	output	[31:0]	ZHI,
	output	[31:0]	ZLO
);

reg [63:0] q;
initial q = 0;

always @(posedge clock) begin
	if (clear) begin
		q <= 64'h0;
	end else if (Zenable) begin
		q <= Zin;
	end
end

//assign Z		= q;
assign ZLO		= q[31:0];
assign ZHI		= q[63:32];

endmodule