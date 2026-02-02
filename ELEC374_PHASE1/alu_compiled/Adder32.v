module Adder32 (
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] Sum,
    output        Cout
);

    wire [32:0] Carry;
    assign Carry[0] = 1'b0;   // no initial carry for ADD / ADDI

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : ADDER_LOOP
            FullAdder FA (
                .a   (A[i]),
                .b   (B[i]),
                .cIn (Carry[i]),
                .sum (Sum[i]),
                .cOut(Carry[i+1])
            );
        end
    endgenerate

    assign Cout = Carry[32];

endmodule
