`timescale 1ns/10ps

module st_tb;

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

    parameter  Default    = 5'd0,
               Init1a     = 5'd1,
               Init1b     = 5'd2,
               T0         = 5'd3,
               T1         = 5'd4,
               T2         = 5'd5,
               T3         = 5'd6,
               T4         = 5'd7,
               T5         = 5'd8,
               T6         = 5'd9,
               T7         = 5'd10,
               T0_2       = 5'd11,
               T1_2       = 5'd12,
               T2_2       = 5'd13,
               T3_2       = 5'd14,
               T4_2       = 5'd15,
               T5_2       = 5'd16,
               T6_2       = 5'd17,
               T7_2       = 5'd18,
               Done       = 5'd19;

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
            "time=%0t | PC=%h | R0=%h | R2=%h | R6=%h | R7=%h",
            $time,
            DUT.BusMuxIn_PC,
            DUT.BusMuxIn_R0,
            DUT.BusMuxIn_R2,
            DUT.BusMuxIn_R6,
            DUT.BusMuxIn_R7
        );
    end

    initial begin
        clear = 1;
        ExternalIn = 32'h00000000;

        // placing instructions in memory
        DUT.MEM.mem[9'h000] = 32'h9300001F;   // st 0x1F, R6
        DUT.MEM.mem[9'h001] = 32'h9330001F;   // st 0x1F(R6), R6

        // placing data in memory
        DUT.MEM.mem[9'h01F] = 32'h000000D4;   // initial value
        DUT.MEM.mem[9'h082] = 32'h000000A7;   // initial value

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
            T6      : Present_state = T7;
            T7      : Present_state = T0_2;

            T0_2    : Present_state = T1_2;
            T1_2    : Present_state = T2_2;
            T2_2    : Present_state = T3_2;
            T3_2    : Present_state = T4_2;
            T4_2    : Present_state = T5_2;
            T5_2    : Present_state = T6_2;
            T6_2    : Present_state = T7_2;
            T7_2    : Present_state = Done;

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

            Init1a: begin
                DUT.BusMuxIn_R6 = 32'h00000063;
            end

            Init1b: begin
                DUT.BusMuxIn_PC = 32'h00000000;
            end

            // Case 1: st 0x1F, R6
            // inferred from ld
            T0: begin
                PCout = 1;
                MARin = 1;
                IncPC = 1;
                Zin = 1;
            end

            T1: begin
                Zlowout = 1;
                PCin = 1;
                Read = 1;
                MDRin = 1;
            end

            T2: begin
                MDRout = 1;
                IRin = 1;
            end

            T3: begin
                Grb = 1;
                BAout = 1;
                Yin = 1;
            end

            T4: begin
                Cout = 1;
                ADD = 1;
                Zin = 1;
            end

            T5: begin
                Zlowout = 1;
                MARin = 1;
            end

            T6: begin
                Gra = 1;
                Rout = 1;
                MDRin = 1;
            end

            T7: begin
                Write = 1;
            end

            // Case 2: st 0x1F(R6), R6
            T0_2: begin
                PCout = 1;
                MARin = 1;
                IncPC = 1;
                Zin = 1;
            end

            T1_2: begin
                Zlowout = 1;
                PCin = 1;
                Read = 1;
                MDRin = 1;
            end

            T2_2: begin
                MDRout = 1;
                IRin = 1;
            end

            T3_2: begin
                Grb = 1;
                BAout = 1;
                Yin = 1;
            end

            T4_2: begin
                Cout = 1;
                ADD = 1;
                Zin = 1;
            end

            T5_2: begin
                Zlowout = 1;
                MARin = 1;
            end

            T6_2: begin
                Gra = 1;
                Rout = 1;
                MDRin = 1;
            end

            T7_2: begin
                Write = 1;
            end

            Done: begin
                $display("ST Case 1 result: mem[01F] = %h (expected 00000063)", DUT.MEM.mem[9'h01F]);
                $display("ST Case 2 result: mem[082] = %h (expected 00000063)", DUT.MEM.mem[9'h082]);
                #20 $stop;
            end
        endcase
    end

endmodule