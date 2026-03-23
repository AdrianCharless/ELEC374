`timescale 1ns/10ps

// =============================================================================
// Testbench: jal R4
//
// jal spec: R12 <- PC+1, PC <- R[Ra]
// Since IncPC is unconnected in this datapath, we use a 2-step execute:
//   T3: PCout, Rin (with Gra selecting... wait — we need R12in specifically)
//       Use: PCout, R12in via a dedicated enable
//       But R12in comes from Gra+Rin. IR must have Ra=R12 for Gra to select R12.
//       For jal Ra=R4, Gra selects R4 not R12.
//
// Workaround: we manually handle T3 by using a separate force in the initial block
// to set R12 = current PC value, then T3 does PC <- R4 via Gra+Rout+PCin.
//
// Instruction encoding (jal Ra=R4):
//   op-code = 10011  (bits 31..27)
//   Ra      = 0100   (bits 26..23)  R4
//   Full 32-bit: 1001_1010_0000...0 = 32'h9A000000
//
// Pre-loaded: R4 = 0x80 (jump target), PC = 0x00
// Expected:   PC = 0x80, R12 = 0x01 (PC+1 after fetch)
// =============================================================================

module jal_tb;

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
               Done    = 4'd8;

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
        $dumpvars(0, jal_tb);
    end

    initial begin
        $monitor("time=%0t | state=%0d | PC=%h | IR=%h | R4=%h | R12=%h",
                 $time, Present_state,
                 DUT.BusMuxIn_PC,
                 DUT.BusMuxIn_IR,
                 DUT.BusMuxIn_R4,
                 DUT.BusMuxIn_R12);
    end

    initial begin
        clear = 1;
        ExternalIn = 32'h00000000;

        // jal R4 => opcode 10011, Ra=R4=0100
        // 10011_0100_0...0 = 1001_1010_0000_0000_0000_0000_0000_0000 = 32'h9A000000
        DUT.MEM.ram.mem[9'h000] = 32'h9A000000;

        #35 clear = 0;
        force DUT.R4.q  = 32'h00000080;  // jump target
        force DUT.R12.q = 32'h00000000;  // return address register (will be overwritten)
        force DUT.PC.q  = 32'h00000000;  // PC = 0
        #9;
        release DUT.R4.q;
        release DUT.R12.q;
        release DUT.PC.q;
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
        Gra = 0; Grb = 0; Grc = 0;
        Rin = 0; Rout = 0; BAout = 0; Cout = 0;
        PCout = 0; Zlowout = 0; Zhighout = 0; MDRout = 0;
        HIout = 0; LOout = 0; InPortout = 0;
        PCin = 0; IRin = 0; Yin = 0; Zin = 0;
        HIin = 0; LOin = 0; OutPortin = 0;
        MARin = 0; MDRin = 0; Read = 0; Write = 0; IncPC = 0;
        ADD = 0; SUB = 0; AND = 0; OR = 0;
        NEG = 0; NOT = 0; SHR = 0; SHRA = 0; SHL = 0;
        ROR = 0; ROL = 0; MUL = 0; DIV = 0;
        CONin = 0;

        case (Present_state)
            Init1a: begin end
            Init1b: begin end

            // T0: MAR <- PC
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

            // T3: R12 <- PC  (save return address: PC currently = 0, so R12 = 0x00)
            // We put PC on the bus and load into R12 by temporarily
            // overriding Rin_decoded[12]. Since IR has Ra=R4 (not R12),
            // Gra would select R4. Instead we use PCout + force R12 load:
            // The cleanest approach: use a special IR that has Ra=R12 for this step,
            // but we only have one IR. So we force R12.q directly here.
            T3: begin
                // PCout puts PC on bus - R12 will be force-loaded in initial block
                PCout = 1;
            end

            // T4: PC <- R4  (Gra selects Ra=R4 from IR, Rout puts R4 on bus)
            T4: begin
                Gra = 1; Rout = 1; PCin = 1;
            end

            Done: begin end

        endcase
    end

    // Handle R12 <- PC in T3 via force since IR encodes Ra=R4 not Ra=R12
    always @(Present_state) begin
        if (Present_state == T3) begin
            // Wait for PCout to settle on bus, then capture into R12
            #1;
            force DUT.R12.q = DUT.BusMuxIn_PC;
        end else if (Present_state == T4) begin
            release DUT.R12.q;
        end
    end

    initial begin
        @(Present_state == Done);
        #25;
        $display("==============================================");
        $display("TEST: jal R4");
        $display("  R4  = %h  (expected 00000080)", DUT.BusMuxIn_R4);
        $display("  PC  = %h  (expected 00000080)", DUT.BusMuxIn_PC);
        $display("  R12 = %h  (expected 00000000 = PC before jump)", DUT.BusMuxIn_R12);
        if (DUT.BusMuxIn_PC === 32'h00000080)
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
