// ray integrates this with datapath
module control_unit (
    input  wire        clock,
    input  wire        reset,
    input  wire        stop,
    input  wire [31:0] IR,
    input  wire        CON_FF,

    output wire Gra, Grb, Grc,
    output wire Rin, Rout, R12in,
    output wire BAout, Cout,

    output wire PCout, Zlowout, Zhighout, MDRout,
    output wire HIout, LOout, InPortout,

    output wire PCin, IRin, Yin, Zin,
    output wire HIin, LOin,
    output wire OutPortin,

    output wire MARin, MDRin,
    output wire Read, Write,
    output wire IncPC,

    output wire ADD, SUB, AND, OR,
    output wire NEG, NOT,
    output wire SHR, SHRA, SHL,
    output wire ROR, ROL,
    output wire MUL, DIV,

    output wire CONin,

    output wire [6:0] present_state
);

    // internal state wire
    wire [6:0] state;

    // FSM instance (doug made this)
    control_unit_fsm FSM (
        .Clock(clock),
        .Reset(reset),
        .Stop(stop),
        .IR(IR),
        .present_state(state)
    );

    // signal generator for each state (adrian makes this component)
    control_unit_signals SIG (
        .state(state),
        .IR(IR),
        .CON_FF(CON_FF),

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

        .CONin(CONin)
    );

    // expose state
    assign present_state = state;

endmodule