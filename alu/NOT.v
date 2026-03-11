module NOT(
    input wire [31:0] A,
    output wire [31:0] Result
);

// Simple assign - much cleaner than generate block
assign Result = ~A;

endmodule
