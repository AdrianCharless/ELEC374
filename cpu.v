`timescale 1ns/1ps
 
module cpu (
    input  wire        clock,
    input  wire        reset,
    input  wire        stop,
    input  wire [31:0] ExternalIn,
    output wire [31:0] OutPort,
    output wire        Run
);
 
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
 
    wire [31:0] IR_fb;
    wire        CON_FF_fb;
    wire [6:0]  present_state;
 

    // this is already handled in control unit so datapath wiring should be .PCin(PCin) - doug

    // localparam [6:0] S_BR6 = 7'd69;
    // wire PCin_to_dp;
    // assign PCin_to_dp = (present_state == S_BR6) ? (PCin & CON_FF_fb) : PCin;

    assign Run = (present_state != 7'd4);
 
    control_unit CU (
        .clock(clock), .reset(reset), .stop(stop),
        .IR(IR_fb), .CON_FF(CON_FF_fb),
        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .Rin(Rin), .Rout(Rout), .R12in(R12in),
        .BAout(BAout), .Cout(Cout),
        .PCout(PCout), .Zlowout(Zlowout), .Zhighout(Zhighout), .MDRout(MDRout),
        .HIout(HIout), .LOout(LOout), .InPortout(InPortout),
        .PCin(PCin), .IRin(IRin), .Yin(Yin), .Zin(Zin),
        .HIin(HIin), .LOin(LOin), .OutPortin(OutPortin),
        .MARin(MARin), .MDRin(MDRin), .Read(Read), .Write(Write), .IncPC(IncPC),
        .ADD(ADD), .SUB(SUB), .AND(AND), .OR(OR),
        .NEG(NEG), .NOT(NOT),
        .SHR(SHR), .SHRA(SHRA), .SHL(SHL),
        .ROR(ROR), .ROL(ROL),
        .MUL(MUL), .DIV(DIV),
        .CONin(CONin),
        .present_state(present_state)
    );
 
    datapath DP (
        .clear(reset), .clock(clock),
        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .Rin(Rin), .Rout(Rout), .R12in(R12in),
        .BAout(BAout), .Cout(Cout),
        .PCout(PCout), .Zlowout(Zlowout), .Zhighout(Zhighout), .MDRout(MDRout),
        .HIout(HIout), .LOout(LOout), .InPortout(InPortout),
        // .PCin(PCin_to_dp),
        .PCin(PCin),
        .IRin(IRin), .Yin(Yin), .Zin(Zin),
        .HIin(HIin), .LOin(LOin), .OutPortin(OutPortin),
        .MARin(MARin), .MDRin(MDRin), .Read(Read), .Write(Write), .IncPC(IncPC),
        .ADD(ADD), .SUB(SUB), .AND(AND), .OR(OR),
        .NEG(NEG), .NOT(NOT),
        .SHR(SHR), .SHRA(SHRA), .SHL(SHL),
        .ROR(ROR), .ROL(ROL),
        .MUL(MUL), .DIV(DIV),
        .CONin(CONin),
        .ExternalIn(ExternalIn),
        .IR_out(IR_fb),
        .CON_FF_out(CON_FF_fb),
        .OutPort(OutPort)
    );
 
endmodule
