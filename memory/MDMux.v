module MDMux (
	input wire [31:0]	BusMuxOut,
	input wire [31:0]	MDatain,
	input wire 			Read,
	output wire [31:0]	D
);

assign D = Read ? MDatain : BusMuxOut;
// can also write: assign D = Read ? Mdatain : BusMuxOut;

// use "assign" when output is single logic expression
// means D is ALWAYS electrically connected to this logic function
// pure combinational, no memory, clock, state or ordering
// like drawing a gate level schematic
// best used for simple mux, bitwise ops, small combinational logic

// use "always @(*)" when logic is conditional or multi-step
// means whenever any input changes, recompute D procedurally
// still combinational, no storage, no clock
// BUT allows multiple conditions, case statements, intermediate signals
// best used when multiple control signals, priority matters, modelling functional unit, or need case or nested if
endmodule