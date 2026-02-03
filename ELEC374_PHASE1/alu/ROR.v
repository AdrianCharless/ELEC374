module rotate_right(
    input [31:0] A,           // Value to rotate
    input [31:0] count,       // How many positions to rotate
    output [31:0] Result      // Rotated result
);

wire [4:0] rotate_amount;
assign rotate_amount = count[4:0];  // Only use lower 5 bits (0-31)

// Rotate right: (A >> n) | (A << (32-n))
// Edge case: if rotate_amount = 0, output = input to avoid shifting by 32
assign Result = (rotate_amount == 5'd0) ? A : ((A >> rotate_amount) | (A << (5'd32 - rotate_amount)));

endmodule
