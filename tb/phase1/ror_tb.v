// ============================================================================
// ROR (Rotate Right) Datapath Testbench - Phase 1
// Tests: ror R7, R0, R4
// Same pattern as OR/SHRA: named ports + tie-off
// ============================================================================

`timescale 1ns/10ps

module ror_tb;

  reg PCout, Zlowout, MDRout, R0out, R4out;
  reg MARin, Zin, PCin, MDRin, IRin, Yin;
  reg IncPC, Read, ROR, R7in, R0in, R4in;

  reg Clock;
  reg [31:0] Mdatain;

  parameter Default    = 4'b0000,
            Reg_load1a = 4'b0001, Reg_load1b = 4'b0010,   // load R0
            Reg_load2a = 4'b0011, Reg_load2b = 4'b0100,   // load R4 (rotate count)
            Reg_load3a = 4'b0101, Reg_load3b = 4'b0110,   // optional load R7
            T0         = 4'b0111,
            T1         = 4'b1000,
            T2         = 4'b1001,
            T3         = 4'b1010,
            T4         = 4'b1011,
            T5         = 4'b1100;

  reg [3:0] Present_state;

  wire [31:0] IR, Outport, BusMuxOut, Zhi, Zlo;

  DATAPATH DUT(
    .PCout(PCout),
    .ZLOout(Zlowout),
    .MDRout(MDRout),
    .R0out(R0out),
    .R4out(R4out),

    .MARin(MARin),
    .Zin(Zin),
    .PCin(PCin),
    .MDRin(MDRin),
    .IRin(IRin),
    .Yin(Yin),
    .R7in(R7in),
    .R0in(R0in),
    .R4in(R4in),

    .ROR(ROR),

    .Read(Read),
    .Mdatain(Mdatain),

    .clock(Clock),
    .clear(1'b0),

    .IR(IR),
    .Outport(Outport),
    .BusMuxOut(BusMuxOut),
    .Zhi(Zhi),
    .Zlo(Zlo),

    .R1out(1'b0), .R2out(1'b0), .R3out(1'b0),
    .R5out(1'b0), .R6out(1'b0), .R7out(1'b0),
    .R8out(1'b0), .R9out(1'b0), .R10out(1'b0), .R11out(1'b0),
    .R12out(1'b0), .R13out(1'b0), .R14out(1'b0), .R15out(1'b0),
    .HIout(1'b0), .LOout(1'b0), .ZHIout(1'b0),
    .InPortout(1'b0), .Cout(1'b0),

    .R1in(1'b0), .R2in(1'b0), .R3in(1'b0),
    .R5in(1'b0), .R6in(1'b0),
    .R8in(1'b0), .R9in(1'b0), .R10in(1'b0), .R11in(1'b0),
    .R12in(1'b0), .R13in(1'b0), .R14in(1'b0), .R15in(1'b0),
    .HIin(1'b0), .LOin(1'b0),

    .ADD(1'b0), .SUB(1'b0), .AND(1'b0), .OR(1'b0), .SHRA(1'b0),
    .SHR(1'b0), .SHL(1'b0), .ROL(1'b0),
    .MUL(1'b0), .DIV(1'b0), .NEG(1'b0), .NOT(1'b0),

    .IncPC(IncPC)
  );

  initial begin
    Clock = 1'b0;
    forever #10 Clock = ~Clock;
  end

  initial begin
    Present_state = Default;
  end

  always @(posedge Clock) begin
    case (Present_state)
      Default:    Present_state <= Reg_load1a;
      Reg_load1a: Present_state <= Reg_load1b;
      Reg_load1b: Present_state <= Reg_load2a;
      Reg_load2a: Present_state <= Reg_load2b;
      Reg_load2b: Present_state <= Reg_load3a;
      Reg_load3a: Present_state <= Reg_load3b;
      Reg_load3b: Present_state <= T0;
      T0:         Present_state <= T1;
      T1:         Present_state <= T2;
      T2:         Present_state <= T3;
      T3:         Present_state <= T4;
      T4:         Present_state <= T5;
      T5:         Present_state <= T5;   // hold at end
      default:    Present_state <= Default;
    endcase
  end

  always @(*) begin
    PCout=0; Zlowout=0; MDRout=0; R0out=0; R4out=0;
    MARin=0; Zin=0; PCin=0; MDRin=0; IRin=0; Yin=0;
    IncPC=0; Read=0; ROR=0; R7in=0; R0in=0; R4in=0;
    Mdatain = 32'h00000000;

    case (Present_state)

      Default: begin
        // nothing special; everything already cleared
      end

      // Preload R0 = 0x12 (18)
      Reg_load1a: begin
        Mdatain = 32'h00000012;
        Read    = 1;
        MDRin   = 1;
      end
      Reg_load1b: begin
        MDRout = 1;
        R0in   = 1;
      end

      // Preload R4 = 4 (rotate count)
      Reg_load2a: begin
        Mdatain = 32'h00000004;
        Read    = 1;
        MDRin   = 1;
      end
      Reg_load2b: begin
        MDRout = 1;
        R4in   = 1;
      end

      // Optional preload R7
      Reg_load3a: begin
        Mdatain = 32'h00000055;
        Read    = 1;
        MDRin   = 1;
      end
      Reg_load3b: begin
        MDRout = 1;
        R7in   = 1;
      end

      // Fetch
      T0: begin
        PCout = 1; MARin = 1; IncPC = 1; Zin = 1;
      end
      T1: begin
        Zlowout = 1; PCin = 1; Read = 1; MDRin = 1;
        Mdatain = 32'h3B820000;  // ror R7, R0, R4
      end
      T2: begin
        MDRout = 1; IRin = 1;
      end

      // Execute ROR
      T3: begin
        R0out = 1; Yin = 1;
      end
      T4: begin
        R4out = 1; ROR = 1; Zin = 1;
      end
      T5: begin
        Zlowout = 1; R7in = 1;
      end

    endcase
  end

endmodule
