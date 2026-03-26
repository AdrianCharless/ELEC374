`timescale 1ns/1ps
 
module cpu_tb;
 
reg        clock, reset, stop;
reg [31:0] ExternalIn;
wire [31:0] OutPort;
wire        Run;
 
cpu DUT (
    .clock(clock), .reset(reset), .stop(stop),
    .ExternalIn(ExternalIn),
    .OutPort(OutPort),
    .Run(Run)
);
 
initial clock = 0;
always #5 clock = ~clock;
 
// instruction encoding helpers
function [31:0] R_fmt;
    input [4:0] op; input [3:0] Ra, Rb, Rc;
    R_fmt = {op, Ra, Rb, Rc, 15'b0};
endfunction
 
function [31:0] I_fmt;
    input [4:0] op; input [3:0] Ra, Rb; input [18:0] C;
    I_fmt = {op, Ra, Rb, C};
endfunction
 
function [31:0] B_fmt; // C2: 00=brzr 01=brnz 10=brpl 11=brmi
    input [3:0] Ra; input [1:0] C2; input [18:0] C;
    B_fmt = {5'b10101, Ra, 2'b00, C2, C};
endfunction
 
function [31:0] J_fmt;
    input [4:0] op; input [3:0] Ra;
    J_fmt = {op, Ra, 23'b0};
endfunction
 
function [31:0] M_fmt;
    input [4:0] op;
    M_fmt = {op, 27'b0};
endfunction
 
// shorthand for hierarchical signal access
`define PC   DUT.DP.BusMuxIn_PC
`define IR   DUT.DP.BusMuxIn_IR
`define MAR  DUT.DP.MAR_Q
`define MDR  DUT.DP.BusMuxIn_MDR
`define HI   DUT.DP.BusMuxIn_HI
`define LO   DUT.DP.BusMuxIn_LO
`define R0   DUT.DP.BusMuxIn_R0
`define R1   DUT.DP.BusMuxIn_R1
`define R2   DUT.DP.BusMuxIn_R2
`define R3   DUT.DP.BusMuxIn_R3
`define R4   DUT.DP.BusMuxIn_R4
`define R5   DUT.DP.BusMuxIn_R5
`define R6   DUT.DP.BusMuxIn_R6
`define R7   DUT.DP.BusMuxIn_R7
`define R8   DUT.DP.BusMuxIn_R8
`define R9   DUT.DP.BusMuxIn_R9
`define R10  DUT.DP.BusMuxIn_R10
`define R11  DUT.DP.BusMuxIn_R11
`define R12  DUT.DP.BusMuxIn_R12
`define R13  DUT.DP.BusMuxIn_R13
`define R14  DUT.DP.BusMuxIn_R14
`define R15  DUT.DP.BusMuxIn_R15
`define RAM  DUT.DP.MEM.ram.mem
 
integer i;
 
initial begin
    stop = 0; ExternalIn = 0; reset = 1;
 
    for (i = 0; i < 512; i = i + 1)
        `RAM[i] = 32'h0;
 
    // data init
    `RAM[8'h89] = 32'h000000A7;
    `RAM[8'hA3] = 32'h00000068;
 
    // program (negative 19-bit constants: -8=19'h7FFF8, -3=19'h7FFFD, -4=19'h7FFFC)
    `RAM[0]   = I_fmt(5'b10001, 4'd5,  4'd0,  19'd67);       // ldi R5, 0x43
    `RAM[1]   = I_fmt(5'b10001, 4'd5,  4'd5,  19'd6);        // ldi R5, 6(R5)
    `RAM[2]   = I_fmt(5'b10000, 4'd4,  4'd0,  19'd137);      // ld R4, 0x89
    `RAM[3]   = I_fmt(5'b10001, 4'd4,  4'd4,  19'd4);        // ldi R4, 4(R4)
    `RAM[4]   = I_fmt(5'b10000, 4'd0,  4'd4,  19'h7FFF8);    // ld R0, -8(R4)
    `RAM[5]   = I_fmt(5'b10001, 4'd2,  4'd0,  19'd4);        // ldi R2, 4
    `RAM[6]   = I_fmt(5'b10001, 4'd5,  4'd0,  19'd135);      // ldi R5, 0x87
    `RAM[7]   = B_fmt(4'd5, 2'b11, 19'd3);                   // brmi R5, 3 (no branch)
    `RAM[8]   = I_fmt(5'b10001, 4'd5,  4'd5,  19'd5);        // ldi R5, 5(R5)
    `RAM[9]   = I_fmt(5'b10000, 4'd1,  4'd5,  19'h7FFFD);    // ld R1, -3(R5)
    `RAM[10]  = M_fmt(5'b11010);                             // nop
    `RAM[11]  = B_fmt(4'd1, 2'b10, 19'd2);                   // brpl R1, 2 (branches to 14)
    `RAM[12]  = I_fmt(5'b10001, 4'd3,  4'd5,  19'd7);        // ldi R3, 7(R5) -- skipped
    `RAM[13]  = I_fmt(5'b10001, 4'd7,  4'd3,  19'h7FFFC);    // ldi R7, -4(R3) -- skipped
    `RAM[14]  = R_fmt(5'b00000, 4'd7,  4'd5,  4'd2);         // add R7, R5, R2
    `RAM[15]  = I_fmt(5'b01001, 4'd1,  4'd1,  19'd3);        // addi R1, R1, 3
    `RAM[16]  = I_fmt(5'b01110, 4'd1,  4'd1,  19'd0);        // neg R1, R1
    `RAM[17]  = I_fmt(5'b01111, 4'd1,  4'd1,  19'd0);        // not R1, R1
    `RAM[18]  = I_fmt(5'b01010, 4'd1,  4'd1,  19'hF);        // andi R1, R1, 0xF
    `RAM[19]  = R_fmt(5'b00111, 4'd4,  4'd0,  4'd2);         // ror R4, R0, R2
    `RAM[20]  = I_fmt(5'b01011, 4'd1,  4'd4,  19'd5);        // ori R1, R4, 5
    `RAM[21]  = R_fmt(5'b00101, 4'd4,  4'd1,  4'd2);         // shra R4, R1, R2
    `RAM[22]  = R_fmt(5'b00100, 4'd5,  4'd5,  4'd2);         // shr R5, R5, R2
    `RAM[23]  = I_fmt(5'b10010, 4'd5,  4'd0,  19'd163);      // st 0xA3, R5
    `RAM[24]  = R_fmt(5'b01000, 4'd5,  4'd0,  4'd2);         // rol R5, R0, R2
    `RAM[25]  = R_fmt(5'b00011, 4'd7,  4'd2,  4'd0);         // or R7, R2, R0
    `RAM[26]  = R_fmt(5'b00010, 4'd4,  4'd5,  4'd0);         // and R4, R5, R0
    `RAM[27]  = I_fmt(5'b10010, 4'd7,  4'd4,  19'd137);      // st 0x89(R4), R7
    `RAM[28]  = R_fmt(5'b00001, 4'd0,  4'd5,  4'd7);         // sub R0, R5, R7
    `RAM[29]  = R_fmt(5'b00110, 4'd4,  4'd5,  4'd2);         // shl R4, R5, R2
    `RAM[30]  = I_fmt(5'b10001, 4'd7,  4'd0,  19'd7);        // ldi R7, 7
    `RAM[31]  = I_fmt(5'b10001, 4'd3,  4'd0,  19'd25);       // ldi R3, 0x19
    `RAM[32]  = I_fmt(5'b01101, 4'd3,  4'd7,  19'd0);        // mul R3, R7
    `RAM[33]  = J_fmt(5'b11000, 4'd1);                       // mfhi R1
    `RAM[34]  = J_fmt(5'b11001, 4'd6);                       // mflo R6
    `RAM[35]  = I_fmt(5'b01100, 4'd3,  4'd7,  19'd0);        // div R3, R7
    `RAM[36]  = I_fmt(5'b10001, 4'd8,  4'd7,  19'd2);        // ldi R8, 2(R7)
    `RAM[37]  = I_fmt(5'b10001, 4'd9,  4'd3,  19'h7FFFC);    // ldi R9, -4(R3)
    `RAM[38]  = I_fmt(5'b10001, 4'd10, 4'd6,  19'd3);        // ldi R10, 3(R6)
    `RAM[39]  = I_fmt(5'b10001, 4'd11, 4'd1,  19'd5);        // ldi R11, 5(R1)
    `RAM[40]  = J_fmt(5'b10011, 4'd10);                      // jal R10
    `RAM[41]  = M_fmt(5'b11011);                             // halt
 
    // subA at 0xB2
    `RAM[178] = R_fmt(5'b00000, 4'd14, 4'd8,  4'd10);        // add R14, R8, R10
    `RAM[179] = R_fmt(5'b00001, 4'd13, 4'd9,  4'd11);        // sub R13, R9, R11
    `RAM[180] = R_fmt(5'b00001, 4'd14, 4'd14, 4'd13);        // sub R14, R14, R13
    `RAM[181] = J_fmt(5'b10100, 4'd12);                      // jr R12
 
    $display("--- memory before ---");
    $display("Mem[0x89] = %h (expect 000000A7)", `RAM[8'h89]);
    $display("Mem[0xA3] = %h (expect 00000068)", `RAM[8'hA3]);
 
    @(posedge clock); #1;
    @(posedge clock); #1;
    reset = 0;
 
    begin : run_loop
        integer timeout;
        timeout = 0;
        while (Run && timeout < 3000) begin
            @(posedge clock); #1;
            timeout = timeout + 1;
        end
        if (timeout >= 3000)
            $display("WARNING: timed out, state = %0d", DUT.present_state);
    end
 
    $display("\n--- registers after ---");
    $display("R0  = %h  (expect 00000614)", `R0);
    $display("R1  = %h  (expect 00000000)", `R1);
    $display("R2  = %h  (expect 00000004)", `R2);
    $display("R3  = %h  (expect 00000019)", `R3);
    $display("R4  = %h  (expect 00006800)", `R4);
    $display("R5  = %h  (expect 00000680)", `R5);
    $display("R6  = %h  (expect 000000AF)", `R6);
    $display("R7  = %h  (expect 00000007)", `R7);
    $display("R8  = %h  (expect 00000009)", `R8);
    $display("R9  = %h  (expect 00000015)", `R9);
    $display("R10 = %h  (expect 000000B2)", `R10);
    $display("R11 = %h  (expect 00000005)", `R11);
    $display("R12 = %h  (expect 00000029)", `R12);
    $display("R13 = %h  (expect 00000010)", `R13);
    $display("R14 = %h  (expect 000000AB)", `R14);
    $display("R15 = %h  (expect 00000000)", `R15);
    $display("HI  = %h  (expect 00000004)", `HI);
    $display("LO  = %h  (expect 00000003)", `LO);
 
    $display("\n--- pass/fail ---");
    if (`R0  !== 32'h00000614) $display("FAIL R0  got %h", `R0);  else $display("PASS R0");
    if (`R1  !== 32'h00000000) $display("FAIL R1  got %h", `R1);  else $display("PASS R1");
    if (`R2  !== 32'h00000004) $display("FAIL R2  got %h", `R2);  else $display("PASS R2");
    if (`R3  !== 32'h00000019) $display("FAIL R3  got %h", `R3);  else $display("PASS R3");
    if (`R4  !== 32'h00006800) $display("FAIL R4  got %h", `R4);  else $display("PASS R4");
    if (`R5  !== 32'h00000680) $display("FAIL R5  got %h", `R5);  else $display("PASS R5");
    if (`R6  !== 32'h000000AF) $display("FAIL R6  got %h", `R6);  else $display("PASS R6");
    if (`R7  !== 32'h00000007) $display("FAIL R7  got %h", `R7);  else $display("PASS R7");
    if (`R8  !== 32'h00000009) $display("FAIL R8  got %h", `R8);  else $display("PASS R8");
    if (`R9  !== 32'h00000015) $display("FAIL R9  got %h", `R9);  else $display("PASS R9");
    if (`R10 !== 32'h000000B2) $display("FAIL R10 got %h", `R10); else $display("PASS R10");
    if (`R11 !== 32'h00000005) $display("FAIL R11 got %h", `R11); else $display("PASS R11");
    if (`R12 !== 32'h00000029) $display("FAIL R12 got %h", `R12); else $display("PASS R12");
    if (`R13 !== 32'h00000010) $display("FAIL R13 got %h", `R13); else $display("PASS R13");
    if (`R14 !== 32'h000000AB) $display("FAIL R14 got %h", `R14); else $display("PASS R14");
    if (`HI  !== 32'h00000004) $display("FAIL HI  got %h", `HI);  else $display("PASS HI");
    if (`LO  !== 32'h00000003) $display("FAIL LO  got %h", `LO);  else $display("PASS LO");
 
    $display("\n--- memory after ---");
    $display("Mem[0x89] = %h  (expect 0000006C)", `RAM[8'h89]);
    $display("Mem[0xA3] = %h  (expect 00000008)", `RAM[8'hA3]);
    if (`RAM[8'h89] !== 32'h0000006C) $display("FAIL Mem[0x89] got %h", `RAM[8'h89]); else $display("PASS Mem[0x89]");
    if (`RAM[8'hA3] !== 32'h00000008) $display("FAIL Mem[0xA3] got %h", `RAM[8'hA3]); else $display("PASS Mem[0xA3]");
 
    $display("\ndone. Run=%b state=%0d", Run, DUT.present_state);
    $stop;
end
 
initial begin
    $dumpfile("cpu_phase3.vcd");
    $dumpvars(0, cpu_tb);
end
 
endmodule
