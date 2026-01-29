module or_immediate(
    input wire [31:0] A,
    input wire [31:0] B,
    output wire [31:0] result
);

    // genvar i;
    // generate
        
    //     for(i = 0; i < 32; i = i + 1)begin
    //         assign result[i] = A[i] | B[i];
    //     end
    // endgenerate
    // Apparently this line is good enough but if it isnt then use the above
    assign result = A | B;

endmodule
