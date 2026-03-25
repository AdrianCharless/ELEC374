`timescale 1ns/10ps

module jal_tb;

    reg clear, clock;

    reg Gra, Grb, Grc;
    reg Rin, Rout, BAout, Cout, R12in;

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
               Done    = 4'd8;

    reg [3:0] Present_state = Default;

    datapath DUT (
        .clear(clear), .clock(clock),
        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .Rin(Rin), .Rout(Rout), .BAout(BAout), .Cout(Cout), .R12in(R12in),
        .PCout(PCout), .Zlowout(Zlowout), .Zhighout(Zhighout), .MDRout(MDRout),
        .HIout(HIout), .LOout(LOout), .InPortout(InPortout),
        .PCin(PCin), .IRin(IRin), .Yin(Yin), .Zin(Zin),
        .HIin(HIin), .LOin(LOin), .OutPortin(OutPortin),
        .MARin(MARin), .MDRin(MDRin), .Read(Read), .Write(Write), .IncPC(IncPC),
        .ADD(ADD), .SUB(SUB), .AND(AND), .OR(OR),
        .NEG(NEG), .NOT(NOT), .SHR(SHR), .SHRA(SHRA), .SHL(SHL),
        .ROR(ROR), .ROL(ROL), .MUL(MUL), .DIV(DIV),
        .CONin(CONin), .ExternalIn(ExternalIn)
    );

    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end

    initial begin
        $dumpfile("waveforms.vcd");
        $dumpvars(0, jal_tb);
    end

    initial begin
        $monitor("time=%0t | state=%0d | PC=%h | IR=%h | R5=%h | R12=%h",
                 $time, Present_state,
                 DUT.BusMuxIn_PC,
                 DUT.BusMuxIn_IR,
                 DUT.BusMuxIn_R5,
                 DUT.BusMuxIn_R12);
    end

    initial begin
        clear = 1;
        ExternalIn = 32'h00000000;

        // jal R5 => opcode 10011, Ra=R5=0101
        // 10011_0101_0...0 = 32'h9A800000
        DUT.MEM.ram.mem[9'h010] = 32'h9A800000;

        #35 clear = 0;
        force DUT.R5.q  = 32'h000000FF;  // jump target
        force DUT.R12.q = 32'h00000000;  // return address reg, set to PC+1 in T3
        force DUT.PC_reg.q  = 32'h00000010;  // PC=0x10, fetch hits mem[0x10] — load mem there if needed
        #9;
        release DUT.R5.q;
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
            T3      : Present_state = T4;
            T4      : Present_state = Done;
            Done    : Present_state = Done;
            default : Present_state = Done;
        endcase
    end

    always @(Present_state) begin
        Gra = 0;        Grb = 0;        Grc = 0;
        Rin = 0;        Rout = 0;       BAout = 0;      Cout = 0;
        R12in = 0;

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
            Init1a: begin end
            Init1b: begin end

            // T0: MAR <- PC, PC <- PC + 1 (0x10 -> 0x11)
            T0: begin
                PCout = 1; MARin = 1; IncPC = 1;
            end

            // T1: MDR <- M[MAR]
            T1: begin
                Read = 1; MDRin = 1;
            end

            // T2: IR <- MDR
            T2: begin
                MDRout = 1; IRin = 1;
            end

            // T3: R12 <- PC (PC is now 0x11 after IncPC in T0)
            T3: begin
                PCout = 1;
                R12in = 1;
            end

            // T4: PC <- R5 (R5 = 0xFF)
            T4: begin
                Gra = 1; Rout = 1; PCin = 1;
            end

            Done: begin end

        endcase
    end

    initial begin
        @(Present_state == Done);
        #25;
        $display("jal R5 result:");
        $display("  R12 = %h  (expected 00000011)", DUT.BusMuxIn_R12);  // PC was 0x10, IncPC -> 0x11
        $display("  PC  = %h  (expected 000000ff)", DUT.BusMuxIn_PC);   // R5 = 0xFF
        $finish;
    end

    initial begin
        #127500;
        $display("Simulation complete.");
        $finish;
    end

endmodule