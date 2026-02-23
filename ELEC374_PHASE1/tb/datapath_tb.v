// datpath_tb_shra.v
`timescale 1ns/10ps

module and_tb;

    // ---- TB control signals (subset used by this test) ----
    reg PCout, Zlowout, MDRout, R5out, R6out;
    reg MARin, Zin, PCin, MDRin, IRin, Yin;
    reg IncPC, Read, AND, R2in, R5in, R6in;
    reg Clock;
    reg [31:0] Mdatain;

    // ---- FSM states ----
    parameter   Default    = 4'b0000,
                Reg_load1a = 4'b0001,
                Reg_load1b = 4'b0010,
                Reg_load2a = 4'b0011,
                Reg_load2b = 4'b0100,
                Reg_load3a = 4'b0101,
                Reg_load3b = 4'b0110,
                T0         = 4'b0111,
                T1         = 4'b1000,
                T2         = 4'b1001,
                T3         = 4'b1010,
                T4         = 4'b1011,
                T5         = 4'b1100;

    reg [3:0] Present_state;

    // ---- DUT observable outputs ----
    wire [31:0] IR, Outport, BusMuxOut, Zhi, Zlo;

    // ---- Instantiate DUT ----
    DATAPATH DUT(
        // outs to bus
        .PCout(PCout),
        .ZLOout(Zlowout),
        .MDRout(MDRout),
        .R5out(R5out),
        .R6out(R6out),

        // ins (register enables)
        .MARin(MARin),
        .Zin(Zin),
        .PCin(PCin),
        .MDRin(MDRin),
        .IRin(IRin),
        .Yin(Yin),
        .R2in(R2in),
        .R5in(R5in),
        .R6in(R6in),

        // ALU op
        .AND(AND),

        // memory/MDR interface
        .Read(Read),
        .Mdatain(Mdatain),

        // clock/reset
        .clock(Clock),
        .clear(1'b0),

        // exposed outputs
        .IR(IR),
        .Outport(Outport),
        .BusMuxOut(BusMuxOut),
        .Zhi(Zhi),
        .Zlo(Zlo),

        // unused outs
        .R0out(1'b0), .R1out(1'b0), .R2out(1'b0), .R3out(1'b0), .R4out(1'b0),
        .R7out(1'b0), .R8out(1'b0), .R9out(1'b0), .R10out(1'b0), .R11out(1'b0),
        .R12out(1'b0), .R13out(1'b0), .R14out(1'b0), .R15out(1'b0),
        .HIout(1'b0), .LOout(1'b0), .ZHIout(1'b0),
        .InPortout(1'b0), .Cout(1'b0),

        // unused ins
        .R0in(1'b0), .R1in(1'b0), .R3in(1'b0), .R4in(1'b0),
        .R7in(1'b0), .R8in(1'b0), .R9in(1'b0), .R10in(1'b0), .R11in(1'b0),
        .R12in(1'b0), .R13in(1'b0), .R14in(1'b0), .R15in(1'b0),
        .HIin(1'b0), .LOin(1'b0),

        // unused ALU ops
        .ADD(1'b0), .SUB(1'b0), .OR(1'b0), .SHRA(1'b0),
        .SHR(1'b0), .SHL(1'b0), .ROR(1'b0), .ROL(1'b0),
        .MUL(1'b0), .DIV(1'b0), .NEG(1'b0), .NOT(1'b0),

        // PC increment
        .IncPC(IncPC)
    );

    // ---- Clock generation ----
    initial begin
        Clock = 1'b0;
        forever #10 Clock = ~Clock; // 20ns period
    end

    // ---- Initialize state (prevents X state) ----
    initial begin
        Present_state = Default;
    end

    // ---- State register: update on negedge so controls settle before posedge ----
    always @(negedge Clock) begin
        case (Present_state)
            Default    : Present_state <= Reg_load1a;
            Reg_load1a : Present_state <= Reg_load1b;
            Reg_load1b : Present_state <= Reg_load2a;
            Reg_load2a : Present_state <= Reg_load2b;
            Reg_load2b : Present_state <= Reg_load3a;
            Reg_load3a : Present_state <= Reg_load3b;
            Reg_load3b : Present_state <= T0;
            T0         : Present_state <= T1;
            T1         : Present_state <= T2;
            T2         : Present_state <= T3;
            T3         : Present_state <= T4;
            T4         : Present_state <= T5;
            T5         : Present_state <= T5;     // hold
            default    : Present_state <= Default;
        endcase
    end

    // ---- Control decode (combinational): defaults prevent stuck signals ----
    always @(*) begin
        // defaults (everything deasserted)
        PCout   = 0;  Zlowout = 0;  MDRout  = 0;  R5out  = 0;  R6out  = 0;
        MARin   = 0;  Zin     = 0;  PCin    = 0;  MDRin  = 0;  IRin   = 0;  Yin = 0;
        IncPC   = 0;  Read    = 0;  AND     = 0;
        R2in    = 0;  R5in    = 0;  R6in    = 0;
        Mdatain = 32'h00000000;

        case (Present_state)
            Default: begin
                // keep everything low
            end

            // Load R5 = 0x34
            Reg_load1a: begin
                Mdatain = 32'h00000034;
                Read    = 1;
                MDRin   = 1; // latch into MDR on next posedge
            end
            Reg_load1b: begin
                MDRout = 1;
                R5in   = 1; // latch into R5 on next posedge
            end

            // Load R6 = 0x45
            Reg_load2a: begin
                Mdatain = 32'h00000045;
                Read    = 1;
                MDRin   = 1;
            end
            Reg_load2b: begin
                MDRout = 1;
                R6in   = 1;
            end

            // Load R2 = 0x67 (pre-load destination to show overwrite)
            Reg_load3a: begin
                Mdatain = 32'h00000067;
                Read    = 1;
                MDRin   = 1;
            end
            Reg_load3b: begin
                MDRout = 1;
                R2in   = 1;
            end

            // ---- Instruction fetch/execute micro-ops ----
            // T0: MAR <- PC ; Z <- PC + 1
            T0: begin
                PCout = 1;
                MARin = 1;
                IncPC = 1;
                Zin   = 1;
            end

            // T1: PC <- ZLO ; MDR <- M[MAR]  (simulated memory via Mdatain)
            T1: begin
                Zlowout = 1;
                PCin    = 1;

                Read    = 1;
                MDRin   = 1;
                Mdatain = 32'h112B0000; // "and R2, R5, R6" (your encoding)
            end

            // T2: IR <- MDR
            T2: begin
                MDRout = 1;
                IRin   = 1;
            end

            // T3: Y <- R5
            T3: begin
                R5out = 1;
                Yin   = 1;
            end

            // T4: Z <- Y AND R6
            T4: begin
                R6out = 1;
                AND   = 1;
                Zin   = 1;
            end

            // T5: R2 <- ZLO
            T5: begin
                Zlowout = 1;
                R2in    = 1;
            end
        endcase
    end

    // ---- Optional: Bus contention detector (prints if multiple outs enabled) ----
    always @(*) begin
        integer outs;
        outs = PCout + Zlowout + MDRout + R5out + R6out;
        if (outs > 1) $display("BUS CONTENTION @ time %0t (outs=%0d)", $time, outs);
    end

    // ---- Dump waves ----
    initial begin
        $dumpfile("waveforms.vcd");
        $dumpvars(0, and_tb);
    end

    // ---- End sim ----
    initial begin
        #500; // enough to run through states several cycles
        $display("Simulation complete.");
        $finish;
    end

endmodule