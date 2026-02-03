//bi-directional bus 

module BUS (
    //Mux
    input [31:0]BusMuxInR0, input [31:0]BusMuxInR1, input [31:0]BusMuxInR2, input [31:0]BusMuxInR3, 
	 input [31:0]BusMuxInR4, input [31:0]BusMuxInR5, input [31:0]BusMuxInR6, input [31:0]BusMuxInR7, 
	 input [31:0]BusMuxInR8, input [31:0]BusMuxInR9, input [31:0]BusMuxInR10, input [31:0]BusMuxInR11, 
	 input [31:0]BusMuxInR12, input [31:0]BusMuxInR13, input [31:0]BusMuxInR14, input [31:0]BusMuxInR15,
	 input [31:0]BusMuxInHI, input [31:0]BusMuxInLO,
	 input [31:0]BusMuxInZHI, input [31:0]BusMuxInZLO,
	 input [31:0]BusMuxInPC, input [31:0]BusMuxInMDR, 
	 input [31:0]BusMuxInInPort, 
	 input [31:0]C_sign_extended,
	 
	 input R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out,  
	 input R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,
	 input HIout, LOout, ZHIout, ZLOout,
	 input PCout, MDRout, 
	 input InPortout, Cout,
    
	output wire [31:0]BusMuxOut //wire vs register?? WIRE
);
//do if else to check all of the signals 
//for the register that has the signal on, update busmux out register to put the value in... 

	reg [31:0] q;

always @(*) begin
    // default to avoid latch when no *_out asserted
    q = 32'b0;

    if (R0out)        q = BusMuxInR0;
    else if (R1out)   q = BusMuxInR1;
    else if (R2out)   q = BusMuxInR2;
    else if (R3out)   q = BusMuxInR3;
    else if (R4out)   q = BusMuxInR4;
    else if (R5out)   q = BusMuxInR5;
    else if (R6out)   q = BusMuxInR6;
    else if (R7out)   q = BusMuxInR7;
    else if (R8out)   q = BusMuxInR8;
    else if (R9out)   q = BusMuxInR9;
    else if (R10out)  q = BusMuxInR10;
    else if (R11out)  q = BusMuxInR11;
    else if (R12out)  q = BusMuxInR12;
    else if (R13out)  q = BusMuxInR13;
    else if (R14out)  q = BusMuxInR14;
    else if (R15out)  q = BusMuxInR15;

    else if (HIout)    q = BusMuxInHi;
    else if (LOout)    q = BusMuxInLO;

    else if (ZHIout) q = BusMuxInZHi;
    else if (ZLOout)  q = BusMuxInZLO;

    else if (PCout)    q = BusMuxInPC;
    else if (MDRout)   q = BusMuxInMDR;

    else if (InPortout) q = BusMuxInInPort;
    else if (Cout)      q = C_sign_extended;
end

assign BusMuxOut = q;

endmodule

