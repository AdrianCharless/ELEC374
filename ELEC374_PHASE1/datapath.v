module DATAPATH (
    // bus output select signals
    input R0out,  input R1out,  input R2out,  input R3out,
    input R4out,  input R5out,  input R6out,  input R7out,
    input R8out,  input R9out,  input R10out, input R11out,
    input R12out, input R13out, input R14out, input R15out,
    input HIout, input LOout,
    input ZHIout, input ZLOout,
    input PCout, input MDRout,
    input InPortout,
    input Cout,

    // register input/load signals
    input R0in,  input R1in,  input R2in,  input R3in,
    input R4in,  input R5in,  input R6in,  input R7in,
    input R8in,  input R9in,  input R10in, input R11in,
    input R12in, input R13in, input R14in, input R15in,
    input HIin, input LOin,
    input PCin, input IRin, input Yin, input Zin,
    input MARin, input MDRin,

    // ALU control
    input ADD, input SUB, input AND, input OR,
    input SHR, input SHRA, input SHL, input ROR, input ROL,
    input MUL, input DIV, input NEG, input NOT,

    // PC control
    input IncPC,

    // memory control
    input Read,
    input Write,

    // global signals
    input clock,
    input clear,

    // outputs
    output [31:0] IR,
    output [31:0] Outport,

    // debug outputs
    output [31:0] BusMuxOut,
    output [31:0] Zhi,
    output [31:0] Zlo
);

    // =========================
    // Internal bus input wires
    // =========================
    wire [31:0] BusMuxInR0;
    wire [31:0] BusMuxInR1;
    wire [31:0] BusMuxInR2;
    wire [31:0] BusMuxInR3;
    wire [31:0] BusMuxInR4;
    wire [31:0] BusMuxInR5;
    wire [31:0] BusMuxInR6;
    wire [31:0] BusMuxInR7;
    wire [31:0] BusMuxInR8;
    wire [31:0] BusMuxInR9;
    wire [31:0] BusMuxInR10;
    wire [31:0] BusMuxInR11;
    wire [31:0] BusMuxInR12;
    wire [31:0] BusMuxInR13;
    wire [31:0] BusMuxInR14;
    wire [31:0] BusMuxInR15;

    wire [31:0] BusMuxInHI;
    wire [31:0] BusMuxInLO;
    wire [31:0] BusMuxInPC;
    wire [31:0] BusMuxInY;
    wire [31:0] BusMuxInZHI;
    wire [31:0] BusMuxInZLO;
    wire [31:0] BusMuxInMDR;

    // not used yet / placeholders
    wire [31:0] BusMuxInInPort;
    wire [31:0] C_sign_extended;

    assign BusMuxInInPort = 32'b0;
    assign C_sign_extended = 32'b0;

    // memory debug wires
    wire [31:0] MAR_Q_unused;
    wire [31:0] RAM_rdata_unused;

    // =========================
    // General purpose registers
    // =========================
    Register R0  (clear, clock, R0in,  BusMuxOut, BusMuxInR0);
    Register R1  (clear, clock, R1in,  BusMuxOut, BusMuxInR1);
    Register R2  (clear, clock, R2in,  BusMuxOut, BusMuxInR2);
    Register R3  (clear, clock, R3in,  BusMuxOut, BusMuxInR3);
    Register R4  (clear, clock, R4in,  BusMuxOut, BusMuxInR4);
    Register R5  (clear, clock, R5in,  BusMuxOut, BusMuxInR5);
    Register R6  (clear, clock, R6in,  BusMuxOut, BusMuxInR6);
    Register R7  (clear, clock, R7in,  BusMuxOut, BusMuxInR7);
    Register R8  (clear, clock, R8in,  BusMuxOut, BusMuxInR8);
    Register R9  (clear, clock, R9in,  BusMuxOut, BusMuxInR9);
    Register R10 (clear, clock, R10in, BusMuxOut, BusMuxInR10);
    Register R11 (clear, clock, R11in, BusMuxOut, BusMuxInR11);
    Register R12 (clear, clock, R12in, BusMuxOut, BusMuxInR12);
    Register R13 (clear, clock, R13in, BusMuxOut, BusMuxInR13);
    Register R14 (clear, clock, R14in, BusMuxOut, BusMuxInR14);
    Register R15 (clear, clock, R15in, BusMuxOut, BusMuxInR15);

    // =========================
    // Special registers
    // =========================
    Register HIreg (clear, clock, HIin, BusMuxOut, BusMuxInHI);
    Register LOreg (clear, clock, LOin, BusMuxOut, BusMuxInLO);
    Register IRreg (clear, clock, IRin, BusMuxOut, IR);
    Register Yreg  (clear, clock, Yin,  BusMuxOut, BusMuxInY);

    // PC
    PC PCreg (clear, clock, PCin, IncPC, BusMuxOut, BusMuxInPC);

    // =========================
    // Memory subsystem
    // Contains:
    //   - MAR
    //   - MDR
    //   - RAM
    // =========================
    Memory mem (
        .clock(clock),
        .clear(clear),
        .MARin(MARin),
        .MDRin(MDRin),
        .Read(Read),
        .Write(Write),
        .BusMuxOut(BusMuxOut),
        .BusMuxInMDR(BusMuxInMDR),
        .MAR_Q(MAR_Q_unused),
        .RAM_rdata(RAM_rdata_unused)
    );

    // =========================
    // ALU control selection
    // =========================
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

    // =========================
    // ALU
    // =========================
    wire [31:0] alu_ZLo;
    wire [31:0] alu_ZHi;

    ALU alu (
        .opcode(alu_opcode),
        .A(BusMuxInY),
        .B(BusMuxOut),
        .ZLO(alu_ZLo),
        .ZHI(alu_ZHi)
    );

    // =========================
    // Z register
    // =========================
    ZREG Z (
        .clear(clear),
        .clock(clock),
        .Zenable(Zin),
        .Zinput({alu_ZHi, alu_ZLo}),
        .ZHI(BusMuxInZHI),
        .ZLO(BusMuxInZLO)
    );

    assign Zhi = BusMuxInZHI;
    assign Zlo = BusMuxInZLO;

    // =========================
    // Output port placeholder
    // =========================
    assign Outport = 32'b0;

    // =========================
    // Bus
    // =========================
    BUS bus (
        .BusMuxInR0(BusMuxInR0),
        .BusMuxInR1(BusMuxInR1),
        .BusMuxInR2(BusMuxInR2),
        .BusMuxInR3(BusMuxInR3),
        .BusMuxInR4(BusMuxInR4),
        .BusMuxInR5(BusMuxInR5),
        .BusMuxInR6(BusMuxInR6),
        .BusMuxInR7(BusMuxInR7),
        .BusMuxInR8(BusMuxInR8),
        .BusMuxInR9(BusMuxInR9),
        .BusMuxInR10(BusMuxInR10),
        .BusMuxInR11(BusMuxInR11),
        .BusMuxInR12(BusMuxInR12),
        .BusMuxInR13(BusMuxInR13),
        .BusMuxInR14(BusMuxInR14),
        .BusMuxInR15(BusMuxInR15),

        .BusMuxInHI(BusMuxInHI),
        .BusMuxInLO(BusMuxInLO),

        .BusMuxInZHI(BusMuxInZHI),
        .BusMuxInZLO(BusMuxInZLO),

        .BusMuxInPC(BusMuxInPC),
        .BusMuxInMDR(BusMuxInMDR),
        .BusMuxInInPort(BusMuxInInPort),
        .C_sign_extended(C_sign_extended),

        .R0out(R0out),
        .R1out(R1out),
        .R2out(R2out),
        .R3out(R3out),
        .R4out(R4out),
        .R5out(R5out),
        .R6out(R6out),
        .R7out(R7out),
        .R8out(R8out),
        .R9out(R9out),
        .R10out(R10out),
        .R11out(R11out),
        .R12out(R12out),
        .R13out(R13out),
        .R14out(R14out),
        .R15out(R15out),

        .HIout(HIout),
        .LOout(LOout),

        .ZHIout(ZHIout),
        .ZLOout(ZLOout),

        .PCout(PCout),
        .MDRout(MDRout),
        .InPortout(InPortout),
        .Cout(Cout),

        .BusMuxOut(BusMuxOut)
    );

endmodule
