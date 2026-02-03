module rol (
    input  [31:0] in,
    input  [31:0] shift_amt_in,   // shift amount comes from a reg [Rc]
    output [31:0] out
);

    wire [4:0] shift_amt;
    assign shift_amt = shift_amt_in[4:0];
    // we use low 5 bits of whatever is in regC because essentially mod 32
    // aka. cant no point in shifting by 33 because thats the same as shifting by 1 since data is 32 bits wide

    assign out = (shift_amt == 5'd0) ? in : ((in << shift_amt) | (in >> (5'd32 - shift_amt)));
    // rotate left: (in << shamt) OR (in >> (32 - shamt))
    // edgecase: if shift amt = 0, then output = input to avoid shifting by 32 (undefined in verilog)
endmodule