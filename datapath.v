module datapath(
    input clear,
    input clock,

    // control signals
    input Gra, Grb, Grc,
    input Rin, Rout,
    input BAout,
    input Cout,

    input PCout, Zlowout, Zhighout, MDRout,
    input HIout, LOout, InPortout,

    input PCin, IRin, Yin, Zin,
    input HIin, LOin,
    input OutPortin,

    input MARin, MDRin,
    input Read, Write,
    input IncPC,

    // ALU control
    input ADD, SUB, AND, OR,
    input NEG, NOT,
    input SHR, SHRA, SHL,
    input ROR, ROL,
    input MUL, DIV,

    input CONin,

    input [31:0] ExternalIn
);

wire [31:0] BusMuxOut;

// SELECT & ENCODE
wire [15:0] Rin_decoded;
wire [15:0] Rout_decoded;

select_encode SE(
    .IR(BusMuxIn_IR),
    .Gra(Gra),
    .Grb(Grb),
    .Grc(Grc),
    .Rin(Rin),
    .Rout(Rout),
    .Rin_decoded(Rin_decoded),
    .Rout_decoded(Rout_decoded)
);

// SIGN EXTEND
wire [31:0] C_sign_extended;

sign_extend SE_C(
    .C_in(BusMuxIn_IR[18:0]),
    .C_sign_extended(C_sign_extended)
);

// REGISTER FILE
wire [31:0] BusMuxIn_R0;
wire [31:0] BusMuxIn_R1;
wire [31:0] BusMuxIn_R2;
wire [31:0] BusMuxIn_R3;
wire [31:0] BusMuxIn_R4;
wire [31:0] BusMuxIn_R5;
wire [31:0] BusMuxIn_R6;
wire [31:0] BusMuxIn_R7;
wire [31:0] BusMuxIn_R8;
wire [31:0] BusMuxIn_R9;
wire [31:0] BusMuxIn_R10;
wire [31:0] BusMuxIn_R11;
wire [31:0] BusMuxIn_R12;
wire [31:0] BusMuxIn_R13;
wire [31:0] BusMuxIn_R14;
wire [31:0] BusMuxIn_R15;

// R0 special register
R0_register R0(
    clear,
    clock,
    Rin_decoded[0],
    BAout,
    BusMuxOut,
    BusMuxIn_R0
);

// normal registers
Register R1(clear,clock,Rin_decoded[1],BusMuxOut,BusMuxIn_R1);
Register R2(clear,clock,Rin_decoded[2],BusMuxOut,BusMuxIn_R2);
Register R3(clear,clock,Rin_decoded[3],BusMuxOut,BusMuxIn_R3);
Register R4(clear,clock,Rin_decoded[4],BusMuxOut,BusMuxIn_R4);
Register R5(clear,clock,Rin_decoded[5],BusMuxOut,BusMuxIn_R5);
Register R6(clear,clock,Rin_decoded[6],BusMuxOut,BusMuxIn_R6);
Register R7(clear,clock,Rin_decoded[7],BusMuxOut,BusMuxIn_R7);
Register R8(clear,clock,Rin_decoded[8],BusMuxOut,BusMuxIn_R8);
Register R9(clear,clock,Rin_decoded[9],BusMuxOut,BusMuxIn_R9);
Register R10(clear,clock,Rin_decoded[10],BusMuxOut,BusMuxIn_R10);
Register R11(clear,clock,Rin_decoded[11],BusMuxOut,BusMuxIn_R11);
Register R12(clear,clock,Rin_decoded[12],BusMuxOut,BusMuxIn_R12);
Register R13(clear,clock,Rin_decoded[13],BusMuxOut,BusMuxIn_R13);
Register R14(clear,clock,Rin_decoded[14],BusMuxOut,BusMuxIn_R14);
Register R15(clear,clock,Rin_decoded[15],BusMuxOut,BusMuxIn_R15);

// PC / IR / Y / HI / LO
wire [31:0] BusMuxIn_PC;
wire [31:0] BusMuxIn_IR;
wire [31:0] BusMuxIn_Y;
wire [31:0] BusMuxIn_HI;
wire [31:0] BusMuxIn_LO;

Register PC(clear,clock,PCin,BusMuxOut,BusMuxIn_PC);
Register IR(clear,clock,IRin,BusMuxOut,BusMuxIn_IR);
Register Y (clear,clock,Yin ,BusMuxOut,BusMuxIn_Y);
Register HI(clear,clock,HIin,BusMuxOut,BusMuxIn_HI);
Register LO(clear,clock,LOin,BusMuxOut,BusMuxIn_LO);

// ALU
wire [63:0] ALU_result;

alu ALU(
    .A(BusMuxIn_Y),
    .B(BusMuxOut),
    .ADD(ADD),
    .SUB(SUB),
    .AND(AND),
    .OR(OR),
    .NEG(NEG),
    .NOT(NOT),
    .SHR(SHR),
    .SHRA(SHRA),
    .SHL(SHL),
    .ROR(ROR),
    .ROL(ROL),
    .MUL(MUL),
    .DIV(DIV),
    .C(ALU_result)
);

// Z REGISTER
wire [63:0] Zout;
ZReg ZREG(
    clear,
    clock,
    Zin,
    ALU_result,
    Zout
);

wire [31:0] BusMuxIn_Zlow  = Zout[31:0];
wire [31:0] BusMuxIn_Zhigh = Zout[63:32];

// MEMORY
wire [31:0] BusMuxIn_MDR;

Memory MEM(
    clear,
    clock,
    MARin,
    MDRin,
    Read,
    Write,
    BusMuxOut,
    BusMuxIn_MDR
);

// IO PORTS
wire [31:0] BusMuxIn_InPort;

io_ports IO(
    clear,
    clock,
    OutPortin,
    BusMuxOut,
    ExternalIn,
    BusMuxIn_InPort,
    OutPortData
);

// CON FF
wire CON;

con_ff CONFF(
    clear,
    clock,
    CONin,
    BusMuxOut,
    BusMuxIn_IR[22:19],
    CON
);

// BUS
BUS BUSMUX(
    Rout_decoded,
    HIout,
    LOout,
    Zhighout,
    Zlowout,
    PCout,
    MDRout,
    InPortout,
    Cout,

    BusMuxIn_R0,
    BusMuxIn_R1,
    BusMuxIn_R2,
    BusMuxIn_R3,
    BusMuxIn_R4,
    BusMuxIn_R5,
    BusMuxIn_R6,
    BusMuxIn_R7,
    BusMuxIn_R8,
    BusMuxIn_R9,
    BusMuxIn_R10,
    BusMuxIn_R11,
    BusMuxIn_R12,
    BusMuxIn_R13,
    BusMuxIn_R14,
    BusMuxIn_R15,

    BusMuxIn_HI,
    BusMuxIn_LO,
    BusMuxIn_Zhigh,
    BusMuxIn_Zlow,
    BusMuxIn_PC,
    BusMuxIn_MDR,
    BusMuxIn_InPort,
    C_sign_extended,

    BusMuxOut
);

endmodule