// 64 bit carry save adder
module CarrySaveAdder64 (
    input  [63:0] A,
    input  [63:0] B,
    input  [63:0] C,
    output [63:0] S,
    output [63:0] Cout
);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : CSA_BITS
            FullAdder fa (
                .a   (A[i]),
                .b   (B[i]),
                .cIn (C[i]),
                .sum (S[i]),
                .cOut(Cout[i])
            );
        end
    endgenerate
endmodule