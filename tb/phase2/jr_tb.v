`timescale 1ns/10ps

module jr_tb;

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
               Done    = 4'd7;

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
        $dumpfile("jr_waveforms.vcd");
        $dumpvars(0, jr_tb);
    end

    initial begin
        $monitor("time=%0t | state=%0d | PC=%h | IR=%h | R12=%h",
                  $time, Present_state,
                  DUT.BusMuxIn_PC,
                  DUT.BusMuxIn_IR,
                  DUT.BusMuxIn_R12);
    end

    initial begin
        clear = 1;
        ExternalIn = 32'h00000000;

        // jr R12 = 32'hA6000000
        // opcode=10100(5b) Ra=R12=1100(4b) rest=0
        DUT.MEM.ram.mem[9'h000] = 32'hA6000000;

        // Pre-load: PC=0 (so fetch hits mem[0]), R12=0xFF (jump target)
        #35 clear = 0;
        force DUT.R12.q = 32'h00000050;
        force DUT.PC_reg.q  = 32'h00000004;  // PC=0 so MAR=0 fetches the instruction
        #9;
        release DUT.R12.q;
        release DUT.PC_reg.q;
    end

    always @(posedge clock) begin
        case (Present_state)
            Default : Present_state = Init1a;
            Init1a  : Present_state = Init1b;
            Init1b  : Present_state = T0;
            T0      : Present_state = T1;
            T1      : Present_state = T2;
            T2      : Present_state = T3;
            T3      : Present_state = Done;
            Done    : Present_state = Done;
            default : Present_state = Done;
        endcase
    end

    always @(Present_state) begin
        Gra = 0; Grb = 0; Grc = 0;
        Rin = 0; Rout = 0; BAout = 0; Cout = 0;

        PCout = 0; Zlowout = 0; Zhighout = 0; MDRout = 0;
        HIout = 0; LOout = 0; InPortout = 0;

        PCin = 0; IRin = 0; Yin = 0; Zin = 0;
        HIin = 0; LOin = 0; OutPortin = 0;

        MARin = 0; MDRin = 0;
        Read = 0; Write = 0;
        IncPC = 0;

        ADD = 0; SUB = 0; AND = 0; OR = 0;
        NEG = 0; NOT = 0;
        SHR = 0; SHRA = 0; SHL = 0;
        ROR = 0; ROL = 0;
        MUL = 0; DIV = 0;

        CONin = 0;

        case (Present_state)

            Init1a: begin end
            Init1b: begin end

            // T0: MAR <- PC  (PC=0, so MAR=0, fetches mem[0])
            T0: begin
                PCout = 1; MARin = 1;
            end

            // T1: MDR <- M[MAR]
            T1: begin
                Read = 1; MDRin = 1;
            end

            // T2: IR <- MDR
            T2: begin
                MDRout = 1; IRin = 1;
            end

            // T3: PC <- R12  (Gra selects Ra=R12 from IR)
            T3: begin
                Gra = 1; Rout = 1; PCin = 1;
            end

            Done: begin end

        endcase
    end

    // Check result after propagation
    initial begin
        @(Present_state == Done);
        #25;
        $display("==============================================");
        $display("TEST: jr R12");
        $display("  R12 = %h  (expected 000000FF)", DUT.BusMuxIn_R12);
        $display("  PC  = %h  (expected 000000FF)", DUT.BusMuxIn_PC);
        if (DUT.BusMuxIn_PC === 32'h000000FF)
            $display("  ** PASS **");
        else
            $display("  ** FAIL **");
        $display("==============================================");
        $stop;
    end

    initial begin
        #127500;
        $display("Simulation timeout.");
        $finish;
    end

endmodule
