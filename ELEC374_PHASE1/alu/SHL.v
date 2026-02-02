// SHL.v
// Logical shift left for MiniSRC Phase 1

module SHL (
	input  wire [31:0] A,        // value to shift (from Y)
	input  wire [31:0] B,        // shift amount (from BusMuxOut / Rc)
	output wire [31:0] result
);

assign result = A << B[4:0];     // shift by 0–31 bits

endmodule
