`timescale 1ns/10ps

module ld_tb;

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

    parameter Default   = 5'd0,
              Init1     = 5'd1,
              T0        = 5'd2,
              T1        = 5'd3,
              T2        = 5'd4,
              T3        = 5'd5,
              T4        = 5'd6,
              T5        = 5'd7,
              T6        = 5'd8,
              T7        = 5'd9,
              SetPC1    = 5'd10,
              SetPC1b   = 5'd11,
              T0_2      = 5'd12,
              T1_2      = 5'd13,
              T2_2      = 5'd14,
              T3_2      = 5'd15,
              T4_2      = 5'd16,
              T5_2      = 5'd17,
              T6_2      = 5'd18,
              T7_2      = 5'd19,
              Done      = 5'd20;

    reg [4:0] Present_state;

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

    // clock
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    // dump
    initial begin
        $dumpfile("waveforms.vcd");
        $dumpvars(0, ld_tb);
    end

    // monitor
    initial begin
        $monitor(
            "time=%0t | state=%0d | PC=%h | IR=%h | Y=%h | ZLOW=%h | MAR=%h | MDR=%h | R0=%h | R2=%h | R7=%h | MEM[065]=%h | MEM[0C9]=%h",
            $time,
            Present_state,
            DUT.BusMuxIn_PC,
            DUT.BusMuxIn_IR,
            DUT.BusMuxIn_Y,
            DUT.BusMuxIn_Zlow,
            DUT.MAR_Q_unused,
            DUT.BusMuxIn_MDR,
            DUT.BusMuxIn_R0,
            DUT.BusMuxIn_R2,
            DUT.BusMuxIn_R7,
            DUT.MEM.ram.mem[9'h065],
            DUT.MEM.ram.mem[9'h0C9]
        );
    end

    // init
    initial begin
        Present_state = Default;
        clear         = 1;
        ExternalIn    = 32'h00000000;

        // deassert all controls
        Gra = 0; Grb = 0; Grc = 0;
        Rin = 0; Rout = 0; BAout = 0; Cout = 0;
        PCout = 0; Zlowout = 0; Zhighout = 0; MDRout = 0;
        HIout = 0; LOout = 0; InPortout = 0;
        PCin = 0; IRin = 0; Yin = 0; Zin = 0;
        HIin = 0; LOin = 0; OutPortin = 0;
        MARin = 0; MDRin = 0;
        Read = 0; Write = 0; IncPC = 0;
        ADD = 0; SUB = 0; AND = 0; OR = 0;
        NEG = 0; NOT = 0;
        SHR = 0; SHRA = 0; SHL = 0;
        ROR = 0; ROL = 0;
        MUL = 0; DIV = 0;
        CONin = 0;

        // instruction memory
        DUT.MEM.ram.mem[9'h000] = 32'h83800065; // ld R7, 0x65
        DUT.MEM.ram.mem[9'h001] = 32'h80100072; // ld R0, 0x72(R2)

        // data memory
        DUT.MEM.ram.mem[9'h065] = 32'h00000084; // (0x65) = 0x84
        DUT.MEM.ram.mem[9'h0C9] = 32'h0000002B; // (0xC9) = 0x2B

        // release reset
        #15 clear = 0;

        // preload R2 = 0x57 for case 2
        #16 DUT.R2.q = 32'h00000057;

        $display("Before LD Case 1: MEM[065] = %h", DUT.MEM.ram.mem[9'h065]);
        $display("Before LD Case 2: MEM[0C9] = %h", DUT.MEM.ram.mem[9'h0C9]);
    end

    // state progression
    always @(posedge clock) begin
        if (clear)
            Present_state <= Default;
        else begin
            case (Present_state)
                Default : Present_state <= Init1;

                Init1   : Present_state <= T0;

                T0      : Present_state <= T1;
                T1      : Present_state <= T2;
                T2      : Present_state <= T3;
                T3      : Present_state <= T4;
                T4      : Present_state <= T5;
                T5      : Present_state <= T6;
                T6      : Present_state <= T7;
                T7      : Present_state <= SetPC1;

                SetPC1  : Present_state <= SetPC1b;
                SetPC1b : Present_state <= T0_2;

                T0_2    : Present_state <= T1_2;
                T1_2    : Present_state <= T2_2;
                T2_2    : Present_state <= T3_2;
                T3_2    : Present_state <= T4_2;
                T4_2    : Present_state <= T5_2;
                T5_2    : Present_state <= T6_2;
                T6_2    : Present_state <= T7_2;
                T7_2    : Present_state <= Done;

                Done    : Present_state <= Done;
                default : Present_state <= Done;
            endcase
        end
    end

    // output logic
    always @(*) begin
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
        ExternalIn = 32'h00000000;

        case (Present_state)

            // no-op settle state after reset
            Init1: begin
            end

            // CASE 1: ld R7, 0x65
            // fetch instruction at PC = 0
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

            // effective address = 0 + C
            T3: begin
                Grb   = 1;
                BAout = 1;
                Yin   = 1;
            end

            T4: begin
                Cout = 1;
                ADD  = 1;
                Zin  = 1;
            end

            T5: begin
                Zlowout = 1;
                MARin   = 1;
            end

            T6: begin
                Read  = 1;
                MDRin = 1;
            end

            T7: begin
                MDRout = 1;
                Gra    = 1;
                Rin    = 1;
            end

            // manually load PC = 1 before case 2
            SetPC1: begin
                ExternalIn = 32'h00000001;
                InPortout  = 1;
                PCin       = 1;
            end

            SetPC1b: begin
            end

            // CASE 2: ld R0, 0x72(R2)
            // fetch instruction at PC = 1
            T0_2: begin
                PCout = 1;
                MARin = 1;
                IncPC = 1;
                Zin   = 1;
            end

            T1_2: begin
                Zlowout = 1;
                PCin    = 1;
                Read    = 1;
                MDRin   = 1;
            end

            T2_2: begin
                MDRout = 1;
                IRin   = 1;
            end

            // effective address = R2 + C = 0x57 + 0x72 = 0xC9
            T3_2: begin
                Grb   = 1;
                BAout = 1;
                Yin   = 1;
            end

            T4_2: begin
                Cout = 1;
                ADD  = 1;
                Zin  = 1;
            end

            T5_2: begin
                Zlowout = 1;
                MARin   = 1;
            end

            T6_2: begin
                Read  = 1;
                MDRin = 1;
            end

            T7_2: begin
                MDRout = 1;
                Gra    = 1;
                Rin    = 1;
            end

            Done: begin
                #1;
                $display("After LD Case 1:  MEM[065] = %h (expected 00000084)", DUT.MEM.ram.mem[9'h065]);
                $display("After LD Case 2:  MEM[0C9] = %h (expected 0000002B source unchanged)", DUT.MEM.ram.mem[9'h0C9]);
                $display("LD Case 1 result: R7 = %h (expected 00000084)", DUT.BusMuxIn_R7);
                $display("LD Case 2 result: R0 = %h (expected 0000002B)", DUT.BusMuxIn_R0);
                #19 $finish;
            end
        endcase
    end

endmodule