//bi-directional bus 

module Bus (
    //Mux
    input [31:0]BusMuxInR0, input [31:0]BusMuxInR1, input [31:0]BusMuxInR2, input [31:0]BusMuxInR3, 
	 input [31:0]BusMuxInR4, input [31:0]BusMuxInR5, input [31:0]BusMuxInR6, input [31:0]BusMuxInR7, 
	 input [31:0]BusMuxInR8, input [31:0]BusMuxInR9, input [31:0]BusMuxInR10, input [31:0]BusMuxInR11, 
	 input [31:0]BusMuxInR12, input [31:0]BusMuxInR13, input [31:0]BusMuxInR14, input [31:0]BusMuxInR15,
	 //do i just put s0-s4 as input as well 
	 //yes
	 
	 input [31:0]BusMuxInHI, input [31:0]BusMuxInLO,
	 input [31:0]BusMuxInZhigh, input [31:0]BusMuxInZlow,
	 input [31:0]BusMuxInPC, input [31:0]BusMuxInMDR, 
	 input [31:0]BusMuxInInPort, 
	 input [31:0]C_sign_extended,
	 
	 //put the signals ex r0 out 
	 
	 input R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out,  
	 input R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out,
    
	 input HIout, LOout, Zhighout, Zlowout,
	 input PCout, MDRout, 
	 input InPortout, Cout
	 

	 //dont need to have the output for s0-s5  they are signals so dont have specify bits 
    
    output wire [31:0]BusMuxOut //wire vs register??
);

reg [31:0] BusMux;
 

//do if else to check all of the signals 
//for the register that has the signal on, update busmux out register to put the value in... 

always @ (*) begin

	 BusMux = 32'h00000000;
		
    if(R0out) 
		busMux = BusMuxInR0;
	
	 else if (R1out)
		busMux = BusMuxInR1;
	
	 else if (R2out)
		busMux = BusMuxInR2;
		
	 else if (R3out)
		busMux = BusMuxInR3;
		
	 else if (R4out)
		busMux = BusMuxInR4;
		
	 else if (R5out)
		busMux = BusMuxInR5;
		
	 else if (R6out)
		busMux = BusMuxInR6;
		
	 else if (R7out)
		busMux = BusMuxInR7;
	
	 else if (R8out)
		busMux = BusMuxInR8;
		
	 else if (R9out)
		busMux = BusMuxInR9;
		
	 else if (R10out)
		busMux = BusMuxInR10;
		
	 else if (R11out)
		busMux = BusMuxInR11;
	
	 else if (R12out)
		busMux = BusMuxInR12;
		
	 else if (R13=out)
		busMux = BusMuxInR13;
		
	 else if (R14out)
		busMux = BusMuxInR14;
	
	 else if (R15out)
		busMux = BusMuxInR15;
		
	 else if (RHIout)
		busMux = BusMuxInRHI;
		
	 else if (RLOout)
		busMux = BusMuxInRLO;
		
	 else if (RZhighout)
		busMux = BusMuxInRZhigh;
		
	 else if (RZlowout)
		busMux = BusMuxInRZlow;
		
	 else if (RPCout)
		busMux = BusMuxInRPC;
		
	 else if (RMDRout)
		busMux = BusMuxInRMDR;  

	 else if (RInPortout)
		busMux = BusMuxInRInPort;
		
	 else if (RCout)
		busMux = C_sign_extended;
		
	 else
      busMux = 32'h00000000;
	 
		
end

endmodule