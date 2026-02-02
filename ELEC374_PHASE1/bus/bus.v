//bi-directional bus 

module Bus (
    //Mux
    input [31:0]BusMuxInR0, input [31:0]BusMuxInR1, input [31:0]BusMuxInR2, input [31:0]BusMuxInR3, 
	 input [31:0]BusMuxInR4, input [31:0]BusMuxInR5, input [31:0]BusMuxInR6, input [31:0]BusMuxInR7, 
	 input [31:0]BusMuxInR8, input [31:0]BusMuxInR9, input [31:0]BusMuxInR10, input [31:0]BusMuxInR11, 
	 input [31:0]BusMuxInR12, input [31:0]BusMuxInR13, input [31:0]BusMuxInR14, input [31:0]BusMuxInR15,
	 input [31:0]BusMuxInHI, input [31:0]BusMuxInLO,
	 input [31:0]BusMuxInZhigh, input [31:0]BusMuxInZlow,
	 input [31:0]BusMuxInPC, input [31:0]BusMuxInMDR, 
	 input [31:0]BusMuxInInPort, 
	 input [31:0]C_sign_extended,
	 
	 input R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out,  
	 input R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,
	 input HIout, LOout, Zhighout, Zlowout,
	 input PCout, MDRout, 
	 input InPortout, Cout
    
	output wire [31:0]BusMuxOut //wire vs register?? WIRE
);
//do if else to check all of the signals 
//for the register that has the signal on, update busmux out register to put the value in... 

	reg [32:0] q;


	//NEED TO WRITE THE IF STATEMETNS
always @ (*) begin
	
end
assign BusMuxOut = q;
endmodule

