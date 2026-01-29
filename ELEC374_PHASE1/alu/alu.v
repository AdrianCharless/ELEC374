module alu(
    input clear,
    input clock,
    input wire [4:0] opcode,
    input wire [31:0] A,
    input wire [31:0] B,
    output reg [63:0] Z,
);