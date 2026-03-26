`timescale 1ns/10ps

// =============================================================================
// Testbench: brzr R3, 48
//
// Encoding: 32'hA9800030
// Pre-loaded: R3=0 (branch taken), PC=0
// Expected: PC = PC+1+C = 0+1+48 = 49 = 0x31
//
// Note: In this datapath, IncPC is connected to the PC module and increments
// the PC internally. Fetch therefore does NOT use Z to compute PC+1.
// =============================================================================
module brzr_tb;

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
        .clear(clear), .clock(clock),
        .Gra(Gra), .Grb(Grb), .Grc(Grc),
        .Rin(Rin), .Rout(Rout), .BAout(BAout), .Cout(Cout),
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
        $dumpvars(0, brzr_tb);
    end

    initial begin
        $monitor(
            "time=%0t | state=%0d | PC=%h | IR=%h | R3=%h | Zlo=%h | CON=%b",
            $time, Present_state,
            DUT.BusMuxIn_PC,
            DUT.BusMuxIn_IR,
            DUT.BusMuxIn_R3,
            DUT.BusMuxIn_Zlow,
            DUT.CON
        );
    end

    initial begin
        clear = 1;
        ExternalIn = 32'h00000000;

        // brzr R3, 48 = 32'hA9800030
        DUT.MEM.ram.mem[9'h000] = 32'hA9800030;

        #35 clear = 0;
        force DUT.R3.q = 32'h00000000;  // R3=0 -> branch taken
        force DUT.PC_reg.q = 32'h00000000;
        #9;
        release DUT.R3.q;
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
            T4      : Present_state = T5;
            T5      : Present_state = T6;
            T6      : Present_state = Done;
            Done    : Present_state = Done;
            default : Present_state = Done;
        endcase
    end

    always @(Present_state) begin
    Gra = 0;    Grb = 0;    Grc = 0;
    Rin = 0;    Rout = 0;   BAout = 0;  Cout = 0;
    PCout = 0;  Zlowout = 0; Zhighout = 0; MDRout = 0;
    HIout = 0;  LOout = 0;  InPortout = 0;
    PCin = 0;   IRin = 0;   Yin = 0;    Zin = 0;
    HIin = 0;   LOin = 0;   OutPortin = 0;
    MARin = 0;  MDRin = 0;
    Read = 0;   Write = 0;  IncPC = 0;
    ADD = 0;    SUB = 0;    AND = 0;    OR = 0;
    NEG = 0;    NOT = 0;
    SHR = 0;    SHRA = 0;   SHL = 0;
    ROR = 0;    ROL = 0;    MUL = 0;    DIV = 0;
    CONin = 0;

    case (Present_state)
        Init1a: begin end
        Init1b: begin end

        // Fetch:
        // MAR <- PC, PC <- PC + 1
        T0: begin
            PCout = 1;
            MARin = 1;
            IncPC = 1;
        end

        // Memory read into MDR
        T1: begin
            Read = 1;
            MDRin = 1;
        end

        // IR <- MDR
        T2: begin
            MDRout = 1;
            IRin = 1;
        end

        // Evaluate branch condition using R3
        T3: begin
            Gra = 1;
            Rout = 1;
            CONin = 1;
        end

        // Y <- PC  (PC is already PC+1 here)
        T4: begin
            PCout = 1;
            Yin = 1;
        end

        // Z <- Y + C
        T5: begin
            Cout = 1;
            ADD = 1;
            Zin = 1;
        end

        // If CON=1, PC <- Zlow
        T6: begin
            if (DUT.CON) begin
                Zlowout = 1;
                PCin    = 1;
            end
        end

        Done: begin end
    endcase
end

    initial begin
        @(Present_state == Done);
        #25;
        $display("==============================================");
        $display("TEST: brzr R3, 48  (branch taken, R3=0)");
        $display("  R3  = %h  (expected 00000000)", DUT.BusMuxIn_R3);
        $display("  CON = %b  (expected 1)", DUT.CON);
        $display("  PC  = %h  (expected 00000031)", DUT.BusMuxIn_PC);
        if (DUT.BusMuxIn_PC === 32'h00000031)
            $display("  ** PASS **");
        else
            $display("  ** FAIL **");
        $display("==============================================");
        $finish;
    end

    initial begin
        #127500;
        $display("Simulation timeout.");
        $finish;
    end

endmodule
