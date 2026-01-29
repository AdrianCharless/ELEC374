module HalfAdder (
	input	a,
	input	b,
	output	sum,
	output	carry
);

assign sum = a^b;
// sum = a XOR b
assign carry = a&b;
// carry = a AND b

endmodule