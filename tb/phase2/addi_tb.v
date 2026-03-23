`timescale 1ns/10ps
 
// =============================================================================
// Testbench: addi R7, R4, -9
//
// Instruction encoding (addi Ra=R7, Rb=R4, C=-9):
//   op-code = 01001  (bits 31..27)
//   Ra      = 0111   (bits 26..23)  R7
//   Rb      = 0100   (bits 22..19)  R4
//   C       = -9 in 19-bit two's complement
//   Full 32-bit: 32'h4BA7FFF7
//
// Pre-loaded: R4 = 0x19 (25 decimal), PC = 0
// Expected:   R7 = 25 + (-9) = 16 = 32'h00000010
//
// Simplified fetch (IncPC not connected in this datapath):
//   T0: PCout, MARin
//   T1: Read, MDRin
//   T2: MDRout, IRin
//   T3: Grb, Rout, Yin
//   T4: Cout, ADD, Zin
//   T5: Zlowout, Gra, Rin
// =============================================================================
 
module addi_tb;
 
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
 
    parameter   Default = 4'd0,
                Init1a  = 4'd1,
                Init1b  = 4'd2,
                T0      = 4'd3,
                T1      = 4'd4,
                T2      = 4'd5,
                T3      = 4'd6,
                T4      = 4'd7,
                T5      = 4'd8,
                Done    = 4'd9;
 
    reg [3:0] Present_state = Default;
 
    datapath DUT (
        .clear(clear),       .clock(clock),
        .Gra(Gra),           .Grb(Grb),         .Grc(Grc),
        .Rin(Rin),           .Rout(Rout),
        .BAout(BAout),       .Cout(Cout),
        .PCout(PCout),       .Zlowout(Zlowout),  .Zhighout(Zhighout), .MDRout(MDRout),
        .HIout(HIout),       .LOout(LOout),       .InPortout(InPortout),
        .PCin(PCin),         .IRin(IRin),         .Yin(Yin),           .Zin(Zin),
        .HIin(HIin),         .LOin(LOin),         .OutPortin(OutPortin),
        .MARin(MARin),       .MDRin(MDRin),
        .Read(Read),         .Write(Write),
        .IncPC(IncPC),
        .ADD(ADD),           .SUB(SUB),           .AND(AND),           .OR(OR),
        .NEG(NEG),           .NOT(NOT),
        .SHR(SHR),           .SHRA(SHRA),         .SHL(SHL),
        .ROR(ROR),           .ROL(ROL),
        .MUL(MUL),           .DIV(DIV),
        .CONin(CONin),
        .ExternalIn(ExternalIn)
    );
 
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end
 
    initial begin
        $dumpfile("waveforms_addi.vcd");
        $dumpvars(0, addi_tb);
    end
 
    initial begin
        $monitor(
            "time=%0t | state=%0d | PC=%h | IR=%h | R4=%h | R7=%h | Zlo=%h",
            $time,
            Present_state,
            DUT.BusMuxIn_PC,
            DUT.BusMuxIn_IR,
            DUT.BusMuxIn_R4,
            DUT.BusMuxIn_R7,
            DUT.BusMuxIn_Zlow
        );
    end
 
    initial begin
        clear = 1;
        ExternalIn = 32'h00000000;
 
        // addi R7, R4, -9 = 32'h4BA7FFF7
        DUT.MEM.ram.mem[9'h000] = 32'h4BA7FFF7;
 
        // Drop clear, then force registers before T0
        #35 clear = 0;
        force DUT.R4.q = 32'h00000019;   // R4 = 25
        force DUT.PC.q = 32'h00000000;   // PC = 0
        #9;
        release DUT.R4.q;
        release DUT.PC.q;
    end
 
    // State sequencer
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
 
            // T0: MAR <- PC  (simplified: no IncPC/Zin since IncPC unconnected)
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
 
            // T3: Y <- R4  (Grb selects Rb=R4 from IR)
            T3: begin
                Grb = 1; Rout = 1; Yin = 1;
            end
 
            // T4: Z <- Y + sign_ext(C),  C = -9
            T4: begin
                Cout = 1; ADD = 1; Zin = 1;
            end
 
            // T5: R7 <- Zlow  (Gra selects Ra=R7 from IR)
            T5: begin
                Zlowout = 1; Gra = 1; Rin = 1;
            end
 
            Done: begin
                $display("==============================================");
                $display("TEST: addi R7, R4, -9");
                $display("  R4  = %h  (expected 00000019)", DUT.BusMuxIn_R4);
                $display("  R7  = %h  (expected 00000010)", DUT.BusMuxIn_R7);
                if (DUT.BusMuxIn_R7 === 32'h00000010)
                    $display("  ** PASS **");
                else
                    $display("  ** FAIL **");
                $display("==============================================");
                #20 $stop;
            end
 
        endcase
    end
 
    initial begin
        #127500;
        $display("Simulation timeout.");
        $finish;
    end
 
endmodule
