`timescale 1ns/1ps

// =============================================================
// cpu.v
// Person 3: CPU top-level integration + probe-enabled datapath
//
// Assumes these existing modules are already in the project:
//   control_unit, select_encode, sign_extend, R0_register,
//   Register, PC, ALU, ZREG, Memory, io_ports, con_ff, BUS
// =============================================================

module cpu (
    input  wire        clock,
    input  wire        reset,
    input  wire        stop,
    input  wire [31:0] ExternalIn,

    // Debug / probe outputs
    output wire [31:0] out_PC,
    output wire [31:0] out_IR,
    output wire [31:0] out_MAR,
    output wire [31:0] out_MDR,
    output wire [31:0] out_HI,
    output wire [31:0] out_LO,
    output wire [31:0] out_R0,
    output wire [31:0] out_R1,
    output wire [31:0] out_R2,
    output wire [31:0] out_R3,
    output wire [31:0] out_R4,
    output wire [31:0] out_R5,
    output wire [31:0] out_R6,
    output wire [31:0] out_R7,
    output wire [31:0] out_R8,
    output wire [31:0] out_R9,
    output wire [31:0] out_R10,
    output wire [31:0] out_R11,
    output wire [31:0] out_R12,
    output wire [31:0] out_R13,
    output wire [31:0] out_R14,
    output wire [31:0] out_R15,
    output wire [31:0] out_OutPort,
    output wire [6:0]  out_state,
    output wire        Run
);

    // ---------------------------------------------------------
    // CU -> datapath control wires
    // ---------------------------------------------------------
    wire Gra, Grb, Grc;
    wire Rin, Rout, R12in;
    wire BAout, Cout;

    wire PCout, Zlowout, Zhighout, MDRout;
    wire HIout, LOout, InPortout;

    wire PCin, IRin, Yin, Zin;
    wire HIin, LOin;
    wire OutPortin;

    wire MARin, MDRin;
    wire Read, Write;
    wire IncPC;

    wire ADD, SUB, AND, OR;
    wire NEG, NOT;
    wire SHR, SHRA, SHL;
    wire ROR, ROL;
    wire MUL, DIV;

    wire CONin;

    // ---------------------------------------------------------
    // datapath -> CU feedback
    // ---------------------------------------------------------
    wire [31:0] IR_fb;
    wire        CON_FF_fb;
    wire [6:0]  present_state;

    // ---------------------------------------------------------
    // Branch fix:
    // Only gate PCin with CON_FF during the branch commit state.
    // State 69 = S_BR6 in control_unit_signals/control_unit_fsm.
    // All other PC writes (fetch, jr, jal, etc.) pass through.
    // ---------------------------------------------------------
    localparam [6:0] S_BR6 = 7'd69;
    wire PCin_to_dp;
    assign PCin_to_dp = (present_state == S_BR6) ? (PCin & CON_FF_fb) : PCin;

    assign out_state = present_state;
    assign Run       = (present_state != 7'd4);   // S_HALT = 4

    // ---------------------------------------------------------
    // Control Unit
    // ---------------------------------------------------------
    control_unit CU (
        .clock(clock),
        .reset(reset),
        .stop(stop),
        .IR(IR_fb),
        .CON_FF(CON_FF_fb),

        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .Rin(Rin), .Rout(Rout), .R12in(R12in),
        .BAout(BAout), .Cout(Cout),

        .PCout(PCout), .Zlowout(Zlowout), .Zhighout(Zhighout), .MDRout(MDRout),
        .HIout(HIout), .LOout(LOout), .InPortout(InPortout),

        .PCin(PCin), .IRin(IRin), .Yin(Yin), .Zin(Zin),
        .HIin(HIin), .LOin(LOin),
        .OutPortin(OutPortin),

        .MARin(MARin), .MDRin(MDRin),
        .Read(Read), .Write(Write),
        .IncPC(IncPC),

        .ADD(ADD), .SUB(SUB), .AND(AND), .OR(OR),
        .NEG(NEG), .NOT(NOT),
        .SHR(SHR), .SHRA(SHRA), .SHL(SHL),
        .ROR(ROR), .ROL(ROL),
        .MUL(MUL), .DIV(DIV),

        .CONin(CONin),
        .present_state(present_state)
    );

    // ---------------------------------------------------------
    // Probe-enabled datapath
    // ---------------------------------------------------------
    datapath_probed DP (
        .clear(reset),
        .clock(clock),

        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .Rin(Rin), .Rout(Rout), .R12in(R12in),
        .BAout(BAout), .Cout(Cout),

        .PCout(PCout), .Zlowout(Zlowout), .Zhighout(Zhighout), .MDRout(MDRout),
        .HIout(HIout), .LOout(LOout), .InPortout(InPortout),

        .PCin(PCin_to_dp), .IRin(IRin), .Yin(Yin), .Zin(Zin),
        .HIin(HIin), .LOin(LOin),
        .OutPortin(OutPortin),

        .MARin(MARin), .MDRin(MDRin),
        .Read(Read), .Write(Write),
        .IncPC(IncPC),

        .ADD(ADD), .SUB(SUB), .AND(AND), .OR(OR),
        .NEG(NEG), .NOT(NOT),
        .SHR(SHR), .SHRA(SHRA), .SHL(SHL),
        .ROR(ROR), .ROL(ROL),
        .MUL(MUL), .DIV(DIV),

        .CONin(CONin),
        .ExternalIn(ExternalIn),

        .IR_out(IR_fb),
        .CON_FF_out(CON_FF_fb),

        .out_PC(out_PC),
        .out_IR(out_IR),
        .out_MAR(out_MAR),
        .out_MDR(out_MDR),
        .out_HI(out_HI),
        .out_LO(out_LO),
        .out_R0(out_R0), .out_R1(out_R1), .out_R2(out_R2), .out_R3(out_R3),
        .out_R4(out_R4), .out_R5(out_R5), .out_R6(out_R6), .out_R7(out_R7),
        .out_R8(out_R8), .out_R9(out_R9), .out_R10(out_R10), .out_R11(out_R11),
        .out_R12(out_R12), .out_R13(out_R13), .out_R14(out_R14), .out_R15(out_R15),
        .out_OutPort(out_OutPort)
    );

endmodule


module datapath_probed(
    input wire clear,
    input wire clock,

    // control signals
    input wire Gra, Grb, Grc,
    input wire Rin, Rout, R12in,
    input wire BAout,
    input wire Cout,

    input wire PCout, Zlowout, Zhighout, MDRout,
    input wire HIout, LOout, InPortout,

    input wire PCin, IRin, Yin, Zin,
    input wire HIin, LOin,
    input wire OutPortin,

    input wire MARin, MDRin,
    input wire Read, Write,
    input wire IncPC,

    // ALU control
    input wire ADD, SUB, AND, OR,
    input wire NEG, NOT,
    input wire SHR, SHRA, SHL,
    input wire ROR, ROL,
    input wire MUL, DIV,

    input wire CONin,
    input wire [31:0] ExternalIn,

    // feedback to CU
    output wire [31:0] IR_out,
    output wire        CON_FF_out,

    // debug probes
    output wire [31:0] out_PC,
    output wire [31:0] out_IR,
    output wire [31:0] out_MAR,
    output wire [31:0] out_MDR,
    output wire [31:0] out_HI,
    output wire [31:0] out_LO,
    output wire [31:0] out_R0,
    output wire [31:0] out_R1,
    output wire [31:0] out_R2,
    output wire [31:0] out_R3,
    output wire [31:0] out_R4,
    output wire [31:0] out_R5,
    output wire [31:0] out_R6,
    output wire [31:0] out_R7,
    output wire [31:0] out_R8,
    output wire [31:0] out_R9,
    output wire [31:0] out_R10,
    output wire [31:0] out_R11,
    output wire [31:0] out_R12,
    output wire [31:0] out_R13,
    output wire [31:0] out_R14,
    output wire [31:0] out_R15,
    output wire [31:0] out_OutPort
);

wire [31:0] BusMuxOut;

// SELECT & ENCODE
wire [15:0] Rin_decoded;
wire [15:0] Rout_decoded;

select_encode SE(
    .IR(IR_out),
    .Gra(Gra), .Grb(Grb), .Grc(Grc),
    .Rin(Rin), .Rout(Rout),
    .BAout(BAout),
    .Rin_out(Rin_decoded),
    .Rout_out(Rout_decoded)
);

// SIGN EXTEND
wire [31:0] C_sign_extended;

sign_extend SE_C(
    .C(IR_out[18:0]),
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

R0_register R0(
    clear,
    clock,
    Rin_decoded[0],
    BAout,
    BusMuxOut,
    BusMuxIn_R0
);

Register R1 (clear, clock, Rin_decoded[1],  BusMuxOut, BusMuxIn_R1);
Register R2 (clear, clock, Rin_decoded[2],  BusMuxOut, BusMuxIn_R2);
Register R3 (clear, clock, Rin_decoded[3],  BusMuxOut, BusMuxIn_R3);
Register R4 (clear, clock, Rin_decoded[4],  BusMuxOut, BusMuxIn_R4);
Register R5 (clear, clock, Rin_decoded[5],  BusMuxOut, BusMuxIn_R5);
Register R6 (clear, clock, Rin_decoded[6],  BusMuxOut, BusMuxIn_R6);
Register R7 (clear, clock, Rin_decoded[7],  BusMuxOut, BusMuxIn_R7);
Register R8 (clear, clock, Rin_decoded[8],  BusMuxOut, BusMuxIn_R8);
Register R9 (clear, clock, Rin_decoded[9],  BusMuxOut, BusMuxIn_R9);
Register R10(clear, clock, Rin_decoded[10], BusMuxOut, BusMuxIn_R10);
Register R11(clear, clock, Rin_decoded[11], BusMuxOut, BusMuxIn_R11);
Register R12(clear, clock, (Rin_decoded[12] | R12in), BusMuxOut, BusMuxIn_R12);
Register R13(clear, clock, Rin_decoded[13], BusMuxOut, BusMuxIn_R13);
Register R14(clear, clock, Rin_decoded[14], BusMuxOut, BusMuxIn_R14);
Register R15(clear, clock, Rin_decoded[15], BusMuxOut, BusMuxIn_R15);

// PC / IR / Y / HI / LO
wire [31:0] BusMuxIn_PC;
wire [31:0] BusMuxIn_IR;
wire [31:0] BusMuxIn_Y;
wire [31:0] BusMuxIn_HI;
wire [31:0] BusMuxIn_LO;

PC PC_reg(
    .clear(clear),
    .clock(clock),
    .PCin(PCin),
    .IncPC(IncPC),
    .BusMuxOut(BusMuxOut),
    .BusMuxInPC(BusMuxIn_PC)
);

Register IR(clear, clock, IRin, BusMuxOut, BusMuxIn_IR);
Register Y (clear, clock, Yin,  BusMuxOut, BusMuxIn_Y);
Register HI(clear, clock, HIin, BusMuxOut, BusMuxIn_HI);
Register LO(clear, clock, LOin, BusMuxOut, BusMuxIn_LO);

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

wire [31:0] ALU_ZLO, ALU_ZHI;
wire        ALU_div_by_zero;

ALU ALU_inst(
    .opcode(ALU_opcode),
    .A(BusMuxIn_Y),
    .B(BusMuxOut),
    .ZLO(ALU_ZLO),
    .ZHI(ALU_ZHI),
    .div_by_zero(ALU_div_by_zero)
);

// Z register
wire [31:0] BusMuxIn_Zlow, BusMuxIn_Zhigh;

ZREG ZREG_inst(
    .clear(clear),
    .clock(clock),
    .Zenable(Zin),
    .Zinput({ALU_ZHI, ALU_ZLO}),
    .ZHI(BusMuxIn_Zhigh),
    .ZLO(BusMuxIn_Zlow)
);

// MEMORY
wire [31:0] BusMuxIn_MDR;
wire [31:0] MAR_Q;
wire [31:0] RAM_rdata;

Memory MEM(
    .clock(clock),
    .clear(clear),
    .MARin(MARin),
    .MDRin(MDRin),
    .Read(Read),
    .Write(Write),
    .BusMuxOut(BusMuxOut),
    .BusMuxInMDR(BusMuxIn_MDR),
    .MAR_Q(MAR_Q),
    .RAM_rdata(RAM_rdata)
);

// I/O ports
wire [31:0] BusMuxIn_InPort;
wire [31:0] OutPortData;

io_ports IO(
    .clk(clock),
    .Bus(BusMuxOut),
    .InPortData(ExternalIn),
    .InPortout(InPortout),
    .OutPortin(OutPortin),
    .BusOut(BusMuxIn_InPort),
    .OutPortData(OutPortData)
);

// CON flip-flop
wire CON_internal;

con_ff CONFF(
    .clear(clear),
    .clock(clock),
    .CONin(CONin),
    .BusMuxOut(BusMuxOut),
    .IR_C2(BusMuxIn_IR[22:19]),
    .CON(CON_internal)
);

// BUS
BUS BUSMUX(
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

    .R0out(Rout_decoded[0]),   .R1out(Rout_decoded[1]),
    .R2out(Rout_decoded[2]),   .R3out(Rout_decoded[3]),
    .R4out(Rout_decoded[4]),   .R5out(Rout_decoded[5]),
    .R6out(Rout_decoded[6]),   .R7out(Rout_decoded[7]),
    .R8out(Rout_decoded[8]),   .R9out(Rout_decoded[9]),
    .R10out(Rout_decoded[10]), .R11out(Rout_decoded[11]),
    .R12out(Rout_decoded[12]), .R13out(Rout_decoded[13]),
    .R14out(Rout_decoded[14]), .R15out(Rout_decoded[15]),
    .HIout(HIout), .LOout(LOout),
    .ZHIout(Zhighout), .ZLOout(Zlowout),
    .PCout(PCout), .MDRout(MDRout),
    .InPortout(InPortout), .Cout(Cout),
    .BusMuxOut(BusMuxOut)
);

// -------------------------------------------------------------
// Feedback outputs to CU
// -------------------------------------------------------------
assign IR_out     = BusMuxIn_IR;
assign CON_FF_out = CON_internal;

// -------------------------------------------------------------
// Probe outputs
// -------------------------------------------------------------
assign out_PC      = BusMuxIn_PC;
assign out_IR      = BusMuxIn_IR;
assign out_MAR     = MAR_Q;
assign out_MDR     = BusMuxIn_MDR;
assign out_HI      = BusMuxIn_HI;
assign out_LO      = BusMuxIn_LO;
assign out_R0      = BusMuxIn_R0;
assign out_R1      = BusMuxIn_R1;
assign out_R2      = BusMuxIn_R2;
assign out_R3      = BusMuxIn_R3;
assign out_R4      = BusMuxIn_R4;
assign out_R5      = BusMuxIn_R5;
assign out_R6      = BusMuxIn_R6;
assign out_R7      = BusMuxIn_R7;
assign out_R8      = BusMuxIn_R8;
assign out_R9      = BusMuxIn_R9;
assign out_R10     = BusMuxIn_R10;
assign out_R11     = BusMuxIn_R11;
assign out_R12     = BusMuxIn_R12;
assign out_R13     = BusMuxIn_R13;
assign out_R14     = BusMuxIn_R14;
assign out_R15     = BusMuxIn_R15;
assign out_OutPort = OutPortData;

endmodule
