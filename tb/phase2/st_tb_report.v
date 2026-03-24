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
        $dumpvars(0, st_tb);
    end

    // monitor
    initial begin
        $monitor(
            "time=%0t | state=%0d | PC=%h | IR=%h | Y=%h | ZLOW=%h | MAR=%h | MDR=%h | R0=%h | R2=%h | R3=%h | R6=%h | MEM[01F]=%h | MEM[00C]=%h",
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
            DUT.BusMuxIn_R3,
            DUT.BusMuxIn_R6,
            DUT.MEM.ram.mem[9'h01F],
            DUT.MEM.ram.mem[9'h00C]
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


        // instruction memory - case 1
        DUT.MEM.ram.mem[9'h000] = 32'h9300001F; // st 0x1F(R0), R6

        // data memory - case 1
        DUT.MEM.ram.mem[9'h01F] = 32'h00000000; // before write

        // instruction memory - case 2
        DUT.MEM.ram.mem[9'h001] = 32'h9197FFFC; // st -4(R2), R3

        // data memory - case 2
        DUT.MEM.ram.mem[9'h00C] = 32'h00000000; // before write



        // release reset
        #15 clear = 0;

        #16 DUT.R6.q = 32'hABCD1234;
        #16 DUT.R0.q = 32'h00000000; // base register

        #16 DUT.R2.q = 32'h00000010;
        #16 DUT.R3.q = 32'h12345678;

        $display("Before ST Case 1: MEM[01F] = %h", DUT.MEM.ram.mem[9'h01F]);
        $display("Before ST Case 2: MEM[00C] = %h", DUT.MEM.ram.mem[9'h00C]);
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

            // CASE 1: st 0x1F, R6
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
                Gra   = 1;
                Rout  = 1;
                MDRin = 1;
            end

            T7: begin
                Write = 1;
            end

            // manually load PC = 1 before case 2
            SetPC1: begin
                ExternalIn = 32'h00000001;
                InPortout  = 1;
                PCin       = 1;
            end

            SetPC1b: begin
            end

            // CASE 2: st 0x1F(R6), R0
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

            // effective address = R6 + C
            T3_2: begin
                Grb  = 1;
                Rout = 1;
                Yin  = 1;
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

            // source register to store = Ra
            T6_2: begin
                Gra   = 1;
                Rout  = 1;
                MDRin = 1;
            end

            T7_2: begin
                Write = 1;
            end

            Done: begin
                $display("After ST Case 1: MEM[01F] = %h (expected ABCD1234)", DUT.MEM.ram.mem[9'h01F]);
                $display("ST Case 1 result: MEM[01F] = %h (written from R6)", DUT.MEM.ram.mem[9'h01F]);

                $display("After ST Case 2: MEM[00C] = %h (expected 12345678)", DUT.MEM.ram.mem[9'h00C]);
                $display("ST Case 2 result: MEM[00C] = %h (written from R3)", DUT.MEM.ram.mem[9'h00C]);
                #20 $finish;
            end
        endcase
    end

endmodule