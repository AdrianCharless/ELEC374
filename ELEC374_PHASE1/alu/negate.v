// ============================================================================
// Negate Module - Two's Complement Negation
// Implements: Result = -A = ~A + 1
// ============================================================================
module negate(
    input [31:0] A,           
    output [31:0] Result      
);

wire [31:0] A_complement;     
reg [31:0] result;            
reg [32:0] Carry;             
integer i;                    

assign A_complement = ~A;

always @(*) begin
    Carry[0] = 1'b1;         
    
    for (i = 0; i < 32; i = i + 1) begin
        result[i] = A_complement[i] ^ Carry[i];
        Carry[i+1] = A_complement[i] & Carry[i];
    endc 
end

assign Result = result;

endmodule
