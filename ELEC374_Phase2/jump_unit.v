// jump_unit.v

module jump_unit(

    input [31:0] Bus,      // jump target
    input [31:0] PC,

    input JR,
    input JAL,

    output [31:0] PC_next,
    output [31:0] RA_value

);

assign PC_next =
        JR  ? Bus :
        JAL ? Bus :
        PC;

assign RA_value =
        JAL ? PC :
        32'b0;

endmodule
