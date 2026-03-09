`timescale 1ns/10ps

module hi_lo_unit_tb;

    reg  [31:0] HI;
    reg  [31:0] LO;
    reg         HIout;
    reg         LOout;

    wire [31:0] Bus;

    hi_lo_unit DUT (
        .HI(HI),
        .LO(LO),
        .HIout(HIout),
        .LOout(LOout),
        .Bus(Bus)
    );

    initial begin
        // initialize
        HI    = 32'h12345678;
        LO    = 32'hABCDEF01;
        HIout = 1'b0;
        LOout = 1'b0;

        // nothing selected -> Bus should be high impedance
        #10;

        // test HI output
        HIout = 1'b1;
        #10;

        HIout = 1'b0;
        #10;

        // test LO output
        LOout = 1'b1;
        #10;

        LOout = 1'b0;
        #10;

        $finish;
    end

endmodule