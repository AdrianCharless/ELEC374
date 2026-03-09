`timescale 1ns/10ps

module jump_unit_tb;

    reg  [31:0] Bus;
    reg  [31:0] PC;
    reg         JR;
    reg         JAL;

    wire [31:0] PC_next;
    wire [31:0] RA_value;

    jump_unit DUT (
        .Bus(Bus),
        .PC(PC),
        .JR(JR),
        .JAL(JAL),
        .PC_next(PC_next),
        .RA_value(RA_value)
    );

    initial begin
        // initialize
        Bus = 32'h00000000;
        PC  = 32'h00000020;
        JR  = 1'b0;
        JAL = 1'b0;

        // no jump active
        #10;

        // test jr: PC_next should become Bus
        Bus = 32'h00000080;
        JR  = 1'b1;
        #10;
        JR  = 1'b0;

        // test jal: PC_next should become Bus, RA_value should become PC
        #10;
        Bus = 32'h00000100;
        PC  = 32'h00000024;
        JAL = 1'b1;
        #10;
        JAL = 1'b0;

        #10;
        $finish;
    end

endmodule