module Datapath( 
	input			clock, clear,
	input [31:0]	A,
	input [31:0]	RegAimm,
	input			RZout, RAout, RBout,
	input			RAin, RBin, RZin
 );

wire [31:0]		BusMuxOut, BusMuxInRZ, BusMuxInRA, BusMuxInRB;
wire [31:0]		ZRegIn;

register RA(
	.clear(clear),
	.clock(clock),
	.enable(RAin),
	.RegIn(A)
	.output(A)
);
register RB();
