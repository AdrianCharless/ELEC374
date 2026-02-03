// OR.v
// 32-bit logical OR unit for MiniSRC Phase 1

module OR_ALU (
	input [31:0]	A,
	input [31:0]	B,
	output [31:0]	out
);

assign out = A | B;

endmodule