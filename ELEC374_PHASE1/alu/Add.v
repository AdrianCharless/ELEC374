// ADD.v
// 32-bit add for MiniSRC Phase 1
// Output is 64-bit so it can connect directly to ZReg.Zin

module ADD (
	input  wire [31:0] A,      // from Y
	input  wire [31:0] B,      // from BusMuxOut
	output wire [63:0] Zin     // to ZReg (Zhi:Zlo)
);

wire [31:0] sum;
assign sum = A + B;

assign Zin = {32'b0, sum};     // Zhi = 0, Zlo = sum

endmodule
