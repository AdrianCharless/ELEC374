module ALU(
    // input clear,          // ALU is combinational so it doesnt need a clear or clock signal
    // input clock,
    input [4:0]     opcode,
    input [31:0]    A,
    input [31:0]    B,
    // output reg [63:0] Z,  // would prob be easier to work a Z output that is split as two HI/LO 32 bit outputs
    // also output is a wire not reg. ZReg is a reg, Z is just a wire feeding into ZReg
    output [31:0]   ZLo,    // holds Z[31:0] which is produced in ALL operations
    output [31:0]   ZHi    // holds Z[63:32] which is ONLY used for mul & div
);


endmodule