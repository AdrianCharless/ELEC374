module Encoder32to5(
	input R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out,
	input R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,
	input HIout, LOout, Zhighout, Zlowout,
	input PCout, MDRout, InPortout, Cout,
	output [4:0] S
);

wire [23:0] ControlSignals = {
    Cout, InPortout, MDRout, PCout,
    Zlowout, Zhighout, LOout, HIout,
    R15out, R14out, R13out, R12out, R11out, R10out, R9out, R8out,
    R7out, R6out, R5out, R4out, R3out, R2out, R1out, R0out
};

always @(*) begin
    S = 5'bxxxxx; // default = illegal/no selection (helps debug)
	case (ControlSignals)
	// assigns 5 bit binary value to S based on value in wire ControlSignals
		24'b000000000000000000000001: S = 5'd0;  // R0
		24'b000000000000000000000010: S = 5'd1;  // R1
		24'b000000000000000000000100: S = 5'd2;  // R2
		24'b000000000000000000001000: S = 5'd3;  // R3
		24'b000000000000000000010000: S = 5'd4;  // R4
		24'b000000000000000000100000: S = 5'd5;  // R5
		24'b000000000000000001000000: S = 5'd6;  // R6
		24'b000000000000000010000000: S = 5'd7;  // R7
        24'b000000000000000100000000: S = 5'd8;  // R8
		24'b000000000000001000000000: S = 5'd9;  // R9
		24'b000000000000010000000000: S = 5'd10; // R10
		24'b000000000000100000000000: S = 5'd11; // R11
		24'b000000000001000000000000: S = 5'd12; // R12
		24'b000000000010000000000000: S = 5'd13; // R13
		24'b000000000100000000000000: S = 5'd14; // R14
		24'b000000001000000000000000: S = 5'd15; // R15
		24'b000000010000000000000000: S = 5'd16; // HI
		24'b000000100000000000000000: S = 5'd17; // LO
		24'b000001000000000000000000: S = 5'd18; // Zhigh
		24'b000010000000000000000000: S = 5'd19; // Zlow
		24'b000100000000000000000000: S = 5'd20; // PC
		24'b001000000000000000000000: S = 5'd21; // MDR
		24'b010000000000000000000000: S = 5'd22; // InPort
		24'b100000000000000000000000: S = 5'd23; // C (ALU out)
		default: S = 5'bxxxxx;	// redundant but good habit
		// if no case matches S becomes invalid
	endcase
end

endmodule