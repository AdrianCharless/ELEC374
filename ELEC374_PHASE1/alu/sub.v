// ============================================================================
// Subtraction Module: A - B = A + (-B)
// ============================================================================

module SUB(
    input [31:0] A, // number we are subtracting from
	 input [31:0] B, //number we subtract
    output [31:0] Result      
);

wire [31:0] B_complement;     
reg [31:0] result;            
reg [32:0] Carry;             
integer i;                    

NEG neg_module(
    .A(B),                    // Input: B
    .Result(B_complement)            // Output: -B
	 
												//dont necessarily need to use B_complement
);

always @(*) begin
    Carry[0] = 1'b0;         
    
    for (i = 0; i < 32; i = i + 1) begin
        result[i] = A[i] ^ B_complement[i] ^ Carry[i]; //^ is xor
		  // Carry out: (A[i] AND neg_B[i]) OR (Carry[i] AND (A[i] XOR neg_B[i]))
        Carry[i+1] = (B_complement[i] & A[i]) | (Carry[i] & (A[i]^B_complement[i]));  
    end
	
end 

assign Result = result;

endmodule
