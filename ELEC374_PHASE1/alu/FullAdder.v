module FullAdder (
    input  a,
    input  b,
    input  cIn,
    output sum,
    output cOut
);

    wire sum1;
    wire carry1;
    wire carry2;

    // first half adder: a + b
    HalfAdder HA1 (
        .a(b),
        .b(cIn),
        .sum(sum1),
        .carry(carry1)
    );

    // second half adder: (a XOR b) + cin
    HalfAdder HA2 (
        .a(a),
        .b(sum1),
        .sum(sum),
        .carry(carry2)
    );

    // carry out
    assign cOut = carry1 | carry2;

endmodule