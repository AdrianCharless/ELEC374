module Add64 (
    input  [63:0] A,
    input  [63:0] B,
    output [63:0] Sum,
    output        Cout
);

    wire [64:0] Carry;
    assign Carry[0] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : ADD64_BITS
            FullAdder fa (
                .a   (A[i]),
                .b   (B[i]),
                .cIn (Carry[i]),
                .sum (Sum[i]),
                .cOut(Carry[i+1])
            );
        end
    endgenerate

    assign Cout = Carry[64];
    
endmodule