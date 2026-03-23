

// ============================================================================
// Testbench: ori R7, R4, 0x71
//
// Expected: R7 = R4 | 0x71 = 0x14 | 0x71 = 0x75
// ============================================================================

module ori_tb;

    reg clear, clock;

    reg Gra, Grb, Grc;
    reg Rin, Rout, BAout, Cout;

    reg PCout, Zlowout, Zhighout, MDRout;
    reg HIout, LOout, InPortout;

    reg PCin, IRin, Yin, Zin;
    reg HIin, LOin, OutPortin;

    reg MARin, MDRin;
    reg Read, Write;
    reg IncPC;

    reg ADD, SUB, AND, OR;
    reg NEG, NOT;
    reg SHR, SHRA, SHL;
    reg ROR, ROL;
    reg MUL, DIV;

    reg CONin;

    reg [31:0] ExternalIn;

    parameter  Default = 5'd0,
               Init1a  = 5'd1,
               Init1b  = 5'd2,
               T0      = 5'd3,
               T1      = 5'd4,
               T2      = 5'd5,
               T3      = 5'd6,
               T4      = 5'd7,
               T5      = 5'd8,
               Done    = 5'd9;

    reg [4:0] Present_state = Default;

    datapath DUT (
        .clear(clear),
        .clock(clock),

        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .Rin(Rin), .Rout(Rout),
        .BAout(BAout), .Cout(Cout),

        .PCout(PCout), .Zlowout(Zlowout), .Zhighout(Zhighout), .MDRout(MDRout),
        .HIout(HIout), .LOout(LOout), .InPortout(InPortout),

        .PCin(PCin), .IRin(IRin), .Yin(Yin), .Zin(Zin),
        .HIin(HIin), .LOin(LOin), .OutPortin(OutPortin),

        .MARin(MARin), .MDRin(MDRin),
        .Read(Read), .Write(Write),
        .IncPC(IncPC),

        .ADD(ADD), .SUB(SUB), .AND(AND), .OR(OR),
        .NEG(NEG), .NOT(NOT),
        .SHR(SHR), .SHRA(SHRA), .SHL(SHL),
        .ROR(ROR), .ROL(ROL),
        .MUL(MUL), .DIV(DIV),

        .CONin(CONin),
        .ExternalIn(ExternalIn)
    );

    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    initial begin
        $monitor(
            "time=%0t | PC=%h | R4=%h | R7=%h",
            $time,
            DUT.BusMuxIn_PC,
            DUT.BusMuxIn_R4,
            DUT.BusMuxIn_R7
        );
    end

    initial begin
        clear = 1;
        ExternalIn = 32'h00000000;

        // ori R7, R4, 0x71
        // opcode=01011, Ra=R7=0111, Rb=R4=0100, C=0x71=19'b000_0000_0111_0001
        // full IR = 01011_0111_0100_0000000001110001 = 32'h5AA00071
        DUT.MEM.mem[9'h000] = 32'h5AA00071;

        #15 clear = 0;
    end

    always @(posedge clock) begin
        case (Present_state)
            Default : Present_state = Init1a;
            Init1a  : Present_state = Init1b;
            Init1b  : Present_state = T0;

            T0      : Present_state = T1;
            T1      : Present_state = T2;
            T2      : Present_state = T3;
            T3      : Present_state = T4;
            T4      : Present_state = T5;
            T5      : Present_state = Done;

            Done    : Present_state = Done;
            default : Present_state = Done;
        endcase
    end

    always @(Present_state) begin
        // default deassertion
        Gra = 0;        Grb = 0;        Grc = 0;
        Rin = 0;        Rout = 0;       BAout = 0;      Cout = 0;

        PCout = 0;      Zlowout = 0;    Zhighout = 0;   MDRout = 0;
        HIout = 0;      LOout = 0;      InPortout = 0;

        PCin = 0;       IRin = 0;       Yin = 0;        Zin = 0;
        HIin = 0;       LOin = 0;       OutPortin = 0;

        MARin = 0;      MDRin = 0;
        Read = 0;       Write = 0;
        IncPC = 0;

        ADD = 0;        SUB = 0;        AND = 0;        OR = 0;
        NEG = 0;        NOT = 0;
        SHR = 0;        SHRA = 0;       SHL = 0;
        ROR = 0;        ROL = 0;
        MUL = 0;        DIV = 0;

        CONin = 0;

        case (Present_state)

            // preload R4 = 20 = 0x14
            Init1a: begin
                DUT.BusMuxIn_R4 = 32'h00000014;
            end

            // preload PC = 0
            Init1b: begin
                DUT.BusMuxIn_PC = 32'h00000000;
            end

            // ori R7, R4, 0x71
            // T0-T2: instruction fetch
            T0: begin
                PCout = 1;
                MARin = 1;
                IncPC = 1;
                Zin   = 1;
            end

            T1: begin
                Zlowout = 1;
                PCin    = 1;
                Read    = 1;
                MDRin   = 1;
            end

            T2: begin
                MDRout = 1;
                IRin   = 1;
            end

            // T3: Grb, Rout, Yin -- put R4 on bus, latch into Y
            T3: begin
                Grb  = 1;
                Rout = 1;
                Yin  = 1;
            end

            // T4: Cout, OR, Zin -- C_sign_extended(0x71) on bus, Y|Bus -> Z
            T4: begin
                Cout = 1;
                OR   = 1;
                Zin  = 1;
            end

            // T5: Zlowout, Gra, Rin -- Zlow -> R7
            T5: begin
                Zlowout = 1;
                Gra     = 1;
                Rin     = 1;
            end

            Done: begin
                $display("ORI result: R7 = %h (expected 00000075)", DUT.BusMuxIn_R7);
                #20 $stop;
            end
        endcase
    end

endmodule
