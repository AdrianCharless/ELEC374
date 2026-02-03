// rotate right
module ROR(
    input [31:0] A,           // Value to rotate
    input [31:0] count,       // How many positions to rotate
    output [31:0] Result      // Rotated result
);

reg [31:0] result;
integer i;
reg [4:0] actual_count;

always @(*) begin
    actual_count = count[4:0];
    
    if (actual_count == 5'd0) begin
        result = A;
    end
    else begin
        result = {A[actual_count-1:0], A[31:actual_count]};
    end
end

assign Result = result;

endmodule
