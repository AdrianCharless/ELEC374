// datapath wo select/encode logic, CON FF, memory chip, I/O
// phase 1 uses simulated control signals

module DATAPATH (
    // bus select signals from control unit (select/encode) (simulated in phase 1)
    input R0out,  input R1out,  input R2out,  input R3out,
    input R4out,  input R5out,  input R6out,  input R7out,
    input R8out,  input R9out,  input R10out, input R11out,
    input R12out, input R13out, input R14out, input R15out,
    input HIout, input LOout,
    input ZHIout, input ZLOout,
    input PCout, input MDRout,
    input InPortout,  // not used in Phase 1, but BUS.v has it
    input Cout,       // not used in Phase 1, but BUS.v has it

    // register load enable signals from control unit (select/encode) (simulated in phase 1)
    input R0in,  input R1in,  input R2in,  input R3in,
    input R4in,  input R5in,  input R6in,  input R7in,
    input R8in,  input R9in,  input R10in, input R11in,
    input R12in, input R13in, input R14in, input R15in,
    input HIin, input LOin,
    input PCin, input IRin, input Yin, input Zin,
    input MARin, input MDRin,

    // ALU ops from control unit (simulated in phase 1)
    input ADD, input SUB, input AND, input OR,
    input SHR, input SHRA, input SHL, input ROR, input ROL,
    input MUL, input DIV, input NEG, input NOT,

    // increment PC signal from control unit (simulated in phase 1)
    input IncPC,

    // memory/MDR
    input Read,
    input [31:0] Mdatain,

    // clock and clear
    input clock,
    input clear,

    // not used in phase 1
    output [31:0] IR,
    output [31:0] Outport,

    // for phase 1 debugging (can remove later)
    output [31:0] BusMuxOut,
    output [31:0] Zhi,
    output [31:0] Zlo,

    // NEW: expose divide-by-zero flag to top level
    output        div_by_zero_flag
);

    // internal wires connecting components to bus
    wire [31:0] BusMuxInR0,  BusMuxInR1,  BusMuxInR2,  BusMuxInR3;
    wire [31:0] BusMuxInR4,  BusMuxInR5,  BusMuxInR6,  BusMuxInR7;
    wire [31:0] BusMuxInR8,  BusMuxInR9,  BusMuxInR10, BusMuxInR11;
    wire [31:0] BusMuxInR12, BusMuxInR13, BusMuxInR14, BusMuxInR15;
    wire [31:0] BusMuxInHI, BusMuxInLO;
    wire [31:0] BusMuxInPC;
    wire [31:0] BusMuxInMDR;
    wire [31:0] BusMuxInMAR;
    wire [31:0] BusMuxInY;
    wire [31:0] BusMuxInZHI, BusMuxInZLO;

    // not used in phase 1
    wire [31:0] BusMuxInInPort = 32'b0;
    wire [31:0] C_sign_extended = 32'b0;

    // instantiate registers R0-R15 (each loads from BusMuxOut)
    Register R0 (clear, clock, R0in, BusMuxOut, BusMuxInR0);
    Register R1 (clear, clock, R1in, BusMuxOut, BusMuxInR1);
    Register R2 (clear, clock, R2in, BusMuxOut, BusMuxInR2);
    Register R3 (clear, clock, R3in, BusMuxOut, BusMuxInR3);
    Register R4 (clear, clock, R4in, BusMuxOut, BusMuxInR4);
    Register R5 (clear, clock, R5in, BusMuxOut, BusMuxInR5);
    Register R6 (clear, clock, R6in, BusMuxOut, BusMuxInR6);
    Register R7 (clear, clock, R7in, BusMuxOut, BusMuxInR7);
    Register R8 (clear, clock, R8in, BusMuxOut, BusMuxInR8);
    Register R9 (clear, clock, R9in, BusMuxOut, BusMuxInR9);
    Register R10(clear, clock, R10in, BusMuxOut, BusMuxInR10);
    Register R11(clear, clock, R11in, BusMuxOut, BusMuxInR11);
    Register R12(clear, clock, R12in, BusMuxOut, BusMuxInR12);
    Register R13(clear, clock, R13in, BusMuxOut, BusMuxInR13);
    Register R14(clear, clock, R14in, BusMuxOut, BusMuxInR14);
    Register R15(clear, clock, R15in, BusMuxOut, BusMuxInR15);

    // HI/LO
    Register HI (clear, clock, HIin, BusMuxOut, BusMuxInHI);
    Register LO (clear, clock, LOin, BusMuxOut, BusMuxInLO);

    // IR
    Register IRreg (clear, clock, IRin, BusMuxOut, IR);

    // Y
    Register Yreg (clear, clock, Yin, BusMuxOut, BusMuxInY);

    // MAR
    Register MAR (clear, clock, MARin, BusMuxOut, BusMuxInMAR);

    // PC
    PC PCreg (clear, clock, PCin, IncPC, BusMuxOut, BusMuxInPC);

    // MDR
    MDR mdr (clear, clock, MDRin, Read, BusMuxOut, Mdatain, BusMuxInMDR);

    // opcode select
    reg [4:0] alu_opcode;
    always @(*) begin
        alu_opcode = 5'b00000; // default ADD

        if (ADD)       alu_opcode = 5'b00000;
        else if (SUB)  alu_opcode = 5'b00001;
        else if (AND)  alu_opcode = 5'b00010;
        else if (OR)   alu_opcode = 5'b00011;
        else if (SHR)  alu_opcode = 5'b00100;
        else if (SHRA) alu_opcode = 5'b00101;
        else if (SHL)  alu_opcode = 5'b00110;
        else if (ROR)  alu_opcode = 5'b00111;
        else if (ROL)  alu_opcode = 5'b01000;
        else if (DIV)  alu_opcode = 5'b01100;
        else if (MUL)  alu_opcode = 5'b01101;
        else if (NEG)  alu_opcode = 5'b01110;
        else if (NOT)  alu_opcode = 5'b01111;
    end

    // ALU outputs (go into Z)
    wire [31:0] alu_ZLo, alu_ZHi;

    // NEW: div-by-zero flag from ALU
    wire div_by_zero_internal;

    ALU alu (
        .opcode(alu_opcode),
        .A(BusMuxInY),     // A operand comes from Y register
        .B(BusMuxOut),     // B operand is on the bus
        .ZLO(alu_ZLo),
        .ZHI(alu_ZHi),
        .div_by_zero(div_by_zero_internal)   // NEW
    );

    // NEW: expose it at datapath level
    assign div_by_zero_flag = div_by_zero_internal;

    // Z register store 64 bit ALU result
    ZREG Z (
        .clear(clear),
        .clock(clock),
        .Zenable(Zin),
        .Zinput({alu_ZHi, alu_ZLo}),
        .ZHI(BusMuxInZHI),
        .ZLO(BusMuxInZLO)
    );

    // expose Zhi/Zlo
    assign Zhi = BusMuxInZHI;
    assign Zlo = BusMuxInZLO;

    // bus
    BUS bus (
        .BusMuxInR0(BusMuxInR0),   .BusMuxInR1(BusMuxInR1),   .BusMuxInR2(BusMuxInR2),   .BusMuxInR3(BusMuxInR3),
        .BusMuxInR4(BusMuxInR4),   .BusMuxInR5(BusMuxInR5),   .BusMuxInR6(BusMuxInR6),   .BusMuxInR7(BusMuxInR7),
        .BusMuxInR8(BusMuxInR8),   .BusMuxInR9(BusMuxInR9),   .BusMuxInR10(BusMuxInR10), .BusMuxInR11(BusMuxInR11),
        .BusMuxInR12(BusMuxInR12), .BusMuxInR13(BusMuxInR13), .BusMuxInR14(BusMuxInR14), .BusMuxInR15(BusMuxInR15),
        .BusMuxInHI(BusMuxInHI), .BusMuxInLO(BusMuxInLO),
        .BusMuxInZHI(BusMuxInZHI), .BusMuxInZLO(BusMuxInZLO),
        .BusMuxInPC(BusMuxInPC),
        .BusMuxInMDR(BusMuxInMDR),
        .BusMuxInInPort(BusMuxInInPort),
        .C_sign_extended(C_sign_extended),

        .R0out(R0out), .R1out(R1out), .R2out(R2out), .R3out(R3out),
        .R4out(R4out), .R5out(R5out), .R6out(R6out), .R7out(R7out),
        .R8out(R8out), .R9out(R9out), .R10out(R10out), .R11out(R11out),
        .R12out(R12out), .R13out(R13out), .R14out(R14out), .R15out(R15out),
        .HIout(HIout), .LOout(LOout),
        .ZHIout(ZHIout), .ZLOout(ZLOout),
        .PCout(PCout), .MDRout(MDRout),
        .InPortout(InPortout),
        .Cout(Cout),

        .BusMuxOut(BusMuxOut)
    );

endmodule
