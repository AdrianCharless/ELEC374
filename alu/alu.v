// ============================================================================
// Integrated ALU Module for Mini SRC Phase 1
// FULLY COMBINATIONAL - All operations complete immediately
// Supports: add, sub, mul, div, and, or, shr, shra, shl, ror, rol, neg, not
// ============================================================================

module ALU(
    input [4:0]         opcode,     // 5-bit opcode from IR[31:27]
    input [31:0]        A,          // First operand (from Y register)
    input [31:0]        B,          // Second operand (from bus)
    output [31:0]       ZLO,        // Lower 32 bits of result
    output [31:0]       ZHI,        // Upper 32 bits (used for mul/div)
    output              div_by_zero // NEW
);

    // ========================================================================
    // Opcode Definitions (from CPU Specification)
    // ========================================================================
    localparam OP_ADD  = 5'b00000;
    localparam OP_SUB  = 5'b00001;
    localparam OP_AND  = 5'b00010;
    localparam OP_OR   = 5'b00011;
    localparam OP_SHR  = 5'b00100;
    localparam OP_SHRA = 5'b00101;
    localparam OP_SHL  = 5'b00110;
    localparam OP_ROR  = 5'b00111;
    localparam OP_ROL  = 5'b01000;
    localparam OP_MUL  = 5'b01101;
    localparam OP_DIV  = 5'b01100;
    localparam OP_NEG  = 5'b01110;
    localparam OP_NOT  = 5'b01111;

    // ========================================================================
    // Wires for each operation's output
    // ========================================================================
    wire [31:0] add_result;
    wire [4:0] add_cout;
    wire [31:0] sub_result;
    wire [31:0] and_result;
    wire [31:0] or_result;
    wire [31:0] shr_result;
    wire [31:0] shra_result;
    wire [31:0] shl_result;
    wire [31:0] ror_result;
    wire [31:0] rol_result;
    wire [31:0] mul_hi, mul_lo;
    wire [31:0] div_quotient, div_remainder;
    wire [31:0] neg_result;
    wire [31:0] not_result;

    // NEW: internal div-by-zero from DIV module
    wire div_by_zero_internal;

    // ========================================================================
    // Instantiate all ALU operation modules
    // ========================================================================

    // Addition
    ADD32 adder_inst (
        .A(A),
        .B(B),
        .Sum(add_result),
        .Cout(add_cout)
    );

    // Subtraction
    SUB sub_inst (
        .A(A),
        .B(B),
        .Result(sub_result)
    );

    // Logical AND
    AND and_inst (
        .A(A),
        .B(B),
        .out(and_result)
    );

    // Logical OR
    OR or_inst (
        .A(A),
        .B(B),
        .out(or_result)
    );

    // Shift Right Logical
    SHR shr_inst (
        .A(A),
        .B(B[4:0]),
        .result(shr_result)
    );

    // Shift Right Arithmetic
    SHRA shra_inst (
        .A(A),
        .B(B[4:0]),
        .result(shra_result)
    );

    // Shift Left Logical
    SHL shl_inst (
        .A(A),
        .B(B),
        .result(shl_result)
    );

    // Rotate Right
    ROR ror_inst (
        .A(A),
        .count(B),
        .Result(ror_result)
    );

    // Rotate Left
    ROL rol_inst (
        .A(A),
        .count(B),
        .Result(rol_result)
    );

    // Multiplication (produces 64-bit result)
    MUL mul_inst (
        .A(A),
        .B(B),
        .HI(mul_hi),
        .LO(mul_lo)
    );

    // Division (combinational - produces quotient and remainder)
    DIV div_inst (
        .A(A),
        .B(B),
        .quotient(div_quotient),
        .remainder(div_remainder),
        .div_by_zero(div_by_zero_internal)   // NEW
    );

    // Negate (2's complement)
    NEG neg_inst (
        .A(B),
        .Result(neg_result)
    );

    // NOT (1's complement)
    NOT not_inst (
        .A(B),
        .Result(not_result)
    );

    // ========================================================================
    // Output Multiplexer - Select result based on opcode
    // ========================================================================
    reg [31:0] result_lo;
    reg [31:0] result_hi;

    always @(*) begin
        // Default values
        result_lo = 32'h00000000;
        result_hi = 32'h00000000;

        case (opcode)
            OP_ADD: begin
                result_lo = add_result;
                result_hi = 32'h00000000;
            end

            OP_SUB: begin
                result_lo = sub_result;
                result_hi = 32'h00000000;
            end

            OP_AND: begin
                result_lo = and_result;
                result_hi = 32'h00000000;
            end

            OP_OR: begin
                result_lo = or_result;
                result_hi = 32'h00000000;
            end

            OP_SHR: begin
                result_lo = shr_result;
                result_hi = 32'h00000000;
            end

            OP_SHRA: begin
                result_lo = shra_result;
                result_hi = 32'h00000000;
            end

            OP_SHL: begin
                result_lo = shl_result;
                result_hi = 32'h00000000;
            end

            OP_ROR: begin
                result_lo = ror_result;
                result_hi = 32'h00000000;
            end

            OP_ROL: begin
                result_lo = rol_result;
                result_hi = 32'h00000000;
            end

            OP_MUL: begin
                result_lo = mul_lo;
                result_hi = mul_hi;
            end

            OP_DIV: begin
                result_lo = div_quotient;   // Quotient
                result_hi = div_remainder;  // Remainder
            end

            OP_NEG: begin
                result_lo = neg_result;
                result_hi = 32'h00000000;
            end

            OP_NOT: begin
                result_lo = not_result;
                result_hi = 32'h00000000;
            end

            default: begin
                result_lo = 32'h00000000;
                result_hi = 32'h00000000;
            end
        endcase
    end

    // Assign outputs
    assign ZLO = result_lo;
    assign ZHI = result_hi;

    // NEW: expose flag (best practice: only meaningful for DIV)
    assign div_by_zero = (opcode == OP_DIV) ? div_by_zero_internal : 1'b0;

endmodule
