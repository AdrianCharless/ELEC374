// hi_lo_unit.v

module hi_lo_unit(

    input [31:0] HI,
    input [31:0] LO,

    input HIout,
    input LOout,

    output [31:0] Bus

);

assign Bus =
        HIout ? HI :
        LOout ? LO :
        32'hz;

endmodule
