`timescale 1ns/10ps

module brmi_tb;

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

    parameter  Default = 4'd0,
               Init1a  = 4'd1,
               Init1b  = 4'd2,
               T0      = 4'd3,
               T1      = 4'd4,
               T2      = 4'd5,
               T3      = 4'd6,
               T4      = 4'd7,
               T5      = 4'd8,
               T6      = 4'd9,
               Done    = 4'd10;

    reg [3:0] Present_state = Default;

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
        $dumpfile("waveforms.vcd");
        $dumpvars(0, brmi_tb);
    end

    initial begin
        $monitor(
            "time=%0t | state=%0d | PC=%h | IR=%h | R3=%h | Zlo=%h | CON=%b",
            $time,
            Present_state,
            DUT.BusMuxIn_PC,
            DUT.IR,
            DUT.BusMuxIn_R3,
            DUT.BusMuxIn_Zlow,
            DUT.CON
        );
    end

    initial begin
        clear = 1;
        ExternalIn = 32'h00000000;

        // Replace this with the actual encoding for: brmi R3,48
        DUT.MEM.mem[9'h000] = 32'hXXXXXXXX;

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
            T5      : Present_state = T6;
            T6      : Present_state = Done;
            Done    : Present_state = Done;
            default : Present_state = Done;
        endcase
    end

    always @(Present_state) begin
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

            // preload R3 = -1 so brmi is taken
            Init1a: begin
                DUT.BusMuxIn_R3 = 32'hFFFFFFFF;
            end

            // preload PC = 0
            Init1b: begin
                DUT.BusMuxIn_PC = 32'h00000000;
            end

            // T0: MAR <- PC ; Z <- PC + 1
            T0: begin
                PCout = 1;
                MARin = 1;
                IncPC = 1;
                Zin   = 1;
            end

            // T1: PC <- Zlow ; MDR <- M[MAR]
            T1: begin
                Zlowout = 1;
                PCin    = 1;
                Read    = 1;
                MDRin   = 1;
            end

            // T2: IR <- MDR
            T2: begin
                MDRout = 1;
                IRin   = 1;
            end

            // T3: Gra, Rout, CONin
            // R3 -> Bus, evaluate brmi, store result in CON
            T3: begin
                Gra   = 1;
                Rout  = 1;
                CONin = 1;
            end

            // T4: PCout, Yin
            T4: begin
                PCout = 1;
                Yin   = 1;
            end

            // T5: Cout, ADD, Zin
            // Z <- PC + 48
            T5: begin
                Cout = 1;
                ADD  = 1;
                Zin  = 1;
            end

            // T6: Zlowout, PCin
            // should only update PC if CON = 1
            T6: begin
                Zlowout = 1;
                PCin    = 1;
            end

            Done: begin
                $display("Final PC  = %h", DUT.BusMuxIn_PC);
                $display("Final R3  = %h", DUT.BusMuxIn_R3);
                $display("Final CON = %b", DUT.CON);
                $display("Expected for taken brmi with PC=0, offset=48: PC should go 0 -> 1 -> 49 (0x31)");
                #20 $stop;
            end
        endcase
    end

endmodule