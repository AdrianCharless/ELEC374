module ZReg (
	input			clear, clock, Zenable,
	input	[63:0]	Zin,
	//output	[63:0]	Z, just for debugging purposes
	output	[31:0]	Zhi,
	output	[31:0]	Zlo
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
assign Zlo		= q[31:0];
assign Zhi		= q[63:32];

endmodule