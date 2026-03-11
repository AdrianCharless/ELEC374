module SHR(
    input wire [31:0] A,
    // Only 5 bits because anything more would 31 would be the same as 31
    input wire [4:0] B,
    output wire [31:0] result
    );

assign result = A >> B;

endmodule