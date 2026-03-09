`timescale 1ns/10ps

module immediate_unit_tb;

    reg  [31:0] Rb_value;
    reg  [31:0] C_value;
    reg         ADDI;
    reg         ANDI;
    reg         ORI;

    wire [31:0] Result;

    immediate_unit DUT (
        .Rb_value(Rb_value),
        .C_value(C_value),
        .ADDI(ADDI),
        .ANDI(ANDI),
        .ORI(ORI),
        .Result(Result)
    );

    initial begin
        // initialize
        Rb_value = 32'h00000000;
        C_value  = 32'h00000000;
        ADDI     = 1'b0;
        ANDI     = 1'b0;
        ORI      = 1'b0;

        // test addi: 10 + 5 = 15
        #10;
        Rb_value = 32'h0000000A;
        C_value  = 32'h00000005;
        ADDI     = 1'b1;
        #10;
        ADDI     = 1'b0;

        // test andi: 0xF & 0x3 = 0x3
        #10;
        Rb_value = 32'h0000000F;
        C_value  = 32'h00000003;
        ANDI     = 1'b1;
        #10;
        ANDI     = 1'b0;

        // test ori: 0xC | 0x3 = 0xF
        #10;
        Rb_value = 32'h0000000C;
        C_value  = 32'h00000003;
        ORI      = 1'b1;
        #10;
        ORI      = 1'b0;

        // test addi with negative value: -4 + (-1) = -5
        #10;
        Rb_value = 32'hFFFFFFFC;
        C_value  = 32'hFFFFFFFF;
        ADDI     = 1'b1;
        #10;
        ADDI     = 1'b0;

        #10;
        $finish;
    end

endmodule