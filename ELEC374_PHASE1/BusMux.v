module BusMux(
	input [31:0]	BusMuxIn_R0,
	input [31:0]	BusMuxIn_R1,
	input [31:0]	BusMuxIn_R2,
	input [31:0]	BusMuxIn_R3,
	input [31:0]	BusMuxIn_R4,
	input [31:0]	BusMuxIn_R5,
	input [31:0]	BusMuxIn_R6,
	input [31:0]	BusMuxIn_R7,
	input [31:0]	BusMuxIn_R8,
	input [31:0]	BusMuxIn_R9,
	input [31:0]	BusMuxIn_R10,
	input [31:0]	BusMuxIn_R11,
	input [31:0]	BusMuxIn_R12,
	input [31:0]	BusMuxIn_R13,
	input [31:0]	BusMuxIn_R14,
	input [31:0]	BusMuxIn_R15,
	input [31:0]	BusMuxIn_HI,
	input [31:0]	BusMuxIn_LO,
	input [31:0]	BusMuxIn_ZHi,
	input [31:0]	BusMuxIn_ZLo,
	input [31:0]	BusMuxIn_PC,
	input [31:0]	BusMuxIn_MDR,
	input [31:0]	BusMuxIn_InPort,
	input [31:0]	BusMuxIn_C,
	
	input [4:0]		S,
	
	output reg [31:0]	BusMuxOut
	// reg doesnt mean it is a register flipflop
	// just means this signal is assigned inside an always statement
	// whereas wire means signal is driven continuously (continuous variable)
	// howvever it COULD be a register flipflop if the always statement says @(posedge clock)
	// since below says @(*), it is combinational and therefore just a procedural variable
);

always @(*) begin
	BusMuxOut = 32'hXXXX_XXXX; // default = illegal/unknown (debug helper)
	case (S)
		5'd0:  BusMuxOut = BusMuxIn_R0;
		5'd1:  BusMuxOut = BusMuxIn_R1;
		5'd2:  BusMuxOut = BusMuxIn_R2;
		5'd3:  BusMuxOut = BusMuxIn_R3;
		5'd4:  BusMuxOut = BusMuxIn_R4;
		5'd5:  BusMuxOut = BusMuxIn_R5;
		5'd6:  BusMuxOut = BusMuxIn_R6;
		5'd7:  BusMuxOut = BusMuxIn_R7;
		5'd8:  BusMuxOut = BusMuxIn_R8;
		5'd9:  BusMuxOut = BusMuxIn_R9;
		5'd10: BusMuxOut = BusMuxIn_R10;
		5'd11: BusMuxOut = BusMuxIn_R11;
		5'd12: BusMuxOut = BusMuxIn_R12;
		5'd13: BusMuxOut = BusMuxIn_R13;
		5'd14: BusMuxOut = BusMuxIn_R14;
		5'd15: BusMuxOut = BusMuxIn_R15;
		5'd16: BusMuxOut = BusMuxIn_HI;
		5'd17: BusMuxOut = BusMuxIn_LO;
		5'd18: BusMuxOut = BusMuxIn_ZHi;
		5'd19: BusMuxOut = BusMuxIn_ZLo;
		5'd20: BusMuxOut = BusMuxIn_PC;
		5'd21: BusMuxOut = BusMuxIn_MDR;
		5'd22: BusMuxOut = BusMuxIn_InPort;
		5'd23: BusMuxOut = BusMuxIn_C;
		default: BusMuxOut = 32'hXXXX_XXXX;
	endcase
	// could also use if/else if/else statement but either or works
end

end module