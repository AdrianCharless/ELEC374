// immediate_unit.v

module immediate_unit(

    input [31:0] Rb_value,     // register operand
    input [31:0] C_value,      // sign-extended constant

    input ADDI,
    input ANDI,
    input ORI,

    output [31:0] Result

);

assign Result =
       ADDI ? (Rb_value + C_value) :
       ANDI ? (Rb_value & C_value) :
       ORI  ? (Rb_value | C_value) :
       32'b0;

endmodule
