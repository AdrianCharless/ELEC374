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
    .Gra(Gra), .Grb(Grb), .Grc(Grc),
    .Rin(Rin), .Rout(Rout),
    .BAout(BAout),              // was missing
    .Rin_out(Rin_decoded),      // renamed from Rin_decoded
    .Rout_out(Rout_decoded)     // renamed from Rout_decoded
);

// SIGN EXTEND
wire [31:0] C_sign_extended;

sign_extend SE_C(
    .C(BusMuxIn_IR[18:0]),              
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

Register PC(clear, clock, PCin & (CON | ~branch_active), BusMuxOut, BusMuxIn_PC);
Register IR(clear,clock,IRin,BusMuxOut,BusMuxIn_IR);
Register Y (clear,clock,Yin ,BusMuxOut,BusMuxIn_Y);
Register HI(clear,clock,HIin,BusMuxOut,BusMuxIn_HI);
Register LO(clear,clock,LOin,BusMuxOut,BusMuxIn_LO);

// ALU
wire [4:0] ALU_opcode;
assign ALU_opcode = ADD  ? 5'b00000 :
                    SUB  ? 5'b00001 :
                    AND  ? 5'b00010 :
                    OR   ? 5'b00011 :
                    SHR  ? 5'b00100 :
                    SHRA ? 5'b00101 :
                    SHL  ? 5'b00110 :
                    ROR  ? 5'b00111 :
                    ROL  ? 5'b01000 :
                    DIV  ? 5'b01100 :
                    MUL  ? 5'b01101 :
                    NEG  ? 5'b01110 :
                    NOT  ? 5'b01111 :
                    5'b00000;

// ALU outputs (separate ZLO / ZHI, no 64-bit bundle)
wire [31:0] ALU_ZLO, ALU_ZHI;
wire        ALU_div_by_zero;

ALU ALU_inst(               // <-- module name is ALU, instance name ALU_inst
    .opcode(ALU_opcode),
    .A(BusMuxIn_Y),
    .B(BusMuxOut),
    .ZLO(ALU_ZLO),
    .ZHI(ALU_ZHI),
    .div_by_zero(ALU_div_by_zero)
);

// Z REGISTER - takes two 32-bit halves, outputs two 32-bit halves
wire [31:0] BusMuxIn_Zlow, BusMuxIn_Zhigh;

ZREG ZREG_inst(             // <-- module name is ZREG
    .clear(clear),
    .clock(clock),
    .Zenable(Zin),
    .Zinput({ALU_ZHI, ALU_ZLO}),   // pack into 64-bit input
    .ZHI(BusMuxIn_Zhigh),
    .ZLO(BusMuxIn_Zlow)
);

// MEMORY
wire [31:0] BusMuxIn_MDR;
wire [31:0] MAR_Q_unused;
wire [31:0] RAM_rdata_unused;

Memory MEM(
    .clock(clock),
    .clear(clear),
    .MARin(MARin),
    .MDRin(MDRin),
    .Read(Read),
    .Write(Write),
    .BusMuxOut(BusMuxOut),
    .BusMuxInMDR(BusMuxIn_MDR),
    .MAR_Q(MAR_Q_unused),
    .RAM_rdata(RAM_rdata_unused)
);

wire [31:0] BusMuxIn_InPort;   // ensure this is 32-bit, declared before io_ports

wire [31:0] OutPortData;       // also needs to be declared

io_ports IO(
    .clk(clock),
    .Bus(BusMuxOut),
    .InPortData(ExternalIn),
    .InPortout(InPortout),
    .OutPortin(OutPortin),
    .BusOut(BusMuxIn_InPort),
    .OutPortData(OutPortData)
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
    // data inputs
    .BusMuxInR0(BusMuxIn_R0),   .BusMuxInR1(BusMuxIn_R1),
    .BusMuxInR2(BusMuxIn_R2),   .BusMuxInR3(BusMuxIn_R3),
    .BusMuxInR4(BusMuxIn_R4),   .BusMuxInR5(BusMuxIn_R5),
    .BusMuxInR6(BusMuxIn_R6),   .BusMuxInR7(BusMuxIn_R7),
    .BusMuxInR8(BusMuxIn_R8),   .BusMuxInR9(BusMuxIn_R9),
    .BusMuxInR10(BusMuxIn_R10), .BusMuxInR11(BusMuxIn_R11),
    .BusMuxInR12(BusMuxIn_R12), .BusMuxInR13(BusMuxIn_R13),
    .BusMuxInR14(BusMuxIn_R14), .BusMuxInR15(BusMuxIn_R15),
    .BusMuxInHI(BusMuxIn_HI),   .BusMuxInLO(BusMuxIn_LO),
    .BusMuxInZHI(BusMuxIn_Zhigh), .BusMuxInZLO(BusMuxIn_Zlow),
    .BusMuxInPC(BusMuxIn_PC),   .BusMuxInMDR(BusMuxIn_MDR),
    .BusMuxInInPort(BusMuxIn_InPort),
    .C_sign_extended(C_sign_extended),
    // select signals
    .R0out(Rout_decoded[0]),   .R1out(Rout_decoded[1]),
    .R2out(Rout_decoded[2]),   .R3out(Rout_decoded[3]),
    .R4out(Rout_decoded[4]),   .R5out(Rout_decoded[5]),
    .R6out(Rout_decoded[6]),   .R7out(Rout_decoded[7]),
    .R8out(Rout_decoded[8]),   .R9out(Rout_decoded[9]),
    .R10out(Rout_decoded[10]), .R11out(Rout_decoded[11]),
    .R12out(Rout_decoded[12]), .R13out(Rout_decoded[13]),
    .R14out(Rout_decoded[14]), .R15out(Rout_decoded[15]),
    .HIout(HIout),   .LOout(LOout),
    .ZHIout(Zhighout), .ZLOout(Zlowout),
    .PCout(PCout),   .MDRout(MDRout),
    .InPortout(InPortout), .Cout(Cout),
    .BusMuxOut(BusMuxOut)
);

endmodule