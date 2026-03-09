`timescale 1ns/1ps

module branch_condition_tb;

reg [31:0] Bus;
reg [1:0] C2;
wire condition_result;

branch_condition DUT (
    .Bus(Bus),
    .C2(C2),
    .condition_result(condition_result)
);

initial begin

    $display("Testing branch_condition");

    // Test brzr
    Bus = 0;
    C2 = 2'b00;
    #10;
    $display("brzr, Bus=0 → result=%b (expected 1)", condition_result);

    // Test brnz
    Bus = 5;
    C2 = 2'b01;
    #10;
    $display("brnz, Bus=5 → result=%b (expected 1)", condition_result);

    // Test brpl
    Bus = 3;
    C2 = 2'b10;
    #10;
    $display("brpl, Bus=3 → result=%b (expected 1)", condition_result);

    // Test brmi
    Bus = -1;
    C2 = 2'b11;
    #10;
    $display("brmi, Bus=-1 → result=%b (expected 1)", condition_result);

    $finish;
end

endmodule