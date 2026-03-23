module ROL (
    input  [31:0] A,              // Value to rotate (was "in")
    input  [31:0] count,          // Shift amount (was "shift_amt_in")
    output [31:0] Result          // Output (was "out")
);

    wire [4:0] shift_amt;
    assign shift_amt = count[4:0];
    // Use low 5 bits (mod 32) - no point shifting by 33 (same as 1)

    assign Result = (shift_amt == 5'd0) ? A : ((A << shift_amt) | (A >> (32 - shift_amt)));
    // Rotate left: (A << shamt) OR (A >> (32 - shamt))
    // Edge case: if shift amt = 0, output = input to avoid shifting by 32 (undefined in verilog)
    
endmodule