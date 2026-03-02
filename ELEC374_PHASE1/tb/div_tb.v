`timescale 1ns/10ps

// ============================================================
// div_tb : DIV R3, R1  (opcode = 32'h61880000)
// Updated to:
//  1) connect DATAPATH div_by_zero_flag output
//  2) optionally test divide-by-zero and signed division
// ============================================================
module div_tb;

  reg PCout, Zlowout, Zhighout, MDRout, R3out, R1out;
  reg MARin, Zin, PCin, MDRin, IRin, Yin;
  reg IncPC, Read, DIV, LOin, HIin, R3in, R1in;

  reg Clock;
  reg [31:0] Mdatain;

  parameter Default    = 4'b0000,
            Reg_load1a = 4'b0001, Reg_load1b = 4'b0010, // load R3
            Reg_load2a = 4'b0011, Reg_load2b = 4'b0100, // load R1
            T0         = 4'b0111,
            T1         = 4'b1000,
            T2         = 4'b1001,
            T3         = 4'b1010,
            T4         = 4'b1011,
            T5         = 4'b1100,
            T6         = 4'b1101;

  reg [3:0] Present_state;

  wire [31:0] IR, Outport, BusMuxOut, Zhi, Zlo;
  wire        div_by_zero_flag;   // NEW: exposed from DATAPATH

  // ------------------------------------------------------------
  // DUT
  // ------------------------------------------------------------
  DATAPATH DUT(
    .PCout(PCout),
    .ZLOout(Zlowout),
    .ZHIout(Zhighout),
    .MDRout(MDRout),
    .R3out(R3out),
    .R1out(R1out),

    .MARin(MARin),
    .Zin(Zin),
    .PCin(PCin),
    .MDRin(MDRin),
    .IRin(IRin),
    .Yin(Yin),
    .LOin(LOin),
    .HIin(HIin),
    .R3in(R3in),
    .R1in(R1in),

    .DIV(DIV),

    .Read(Read),
    .Mdatain(Mdatain),

    .clock(Clock),
    .clear(1'b0),

    .IR(IR),
    .Outport(Outport),
    .BusMuxOut(BusMuxOut),
    .Zhi(Zhi),
    .Zlo(Zlo),

    // NEW output
    .div_by_zero_flag(div_by_zero_flag),

    .R0out(1'b0), .R2out(1'b0), .R4out(1'b0), .R5out(1'b0), .R6out(1'b0),
    .R7out(1'b0), .R8out(1'b0), .R9out(1'b0), .R10out(1'b0), .R11out(1'b0),
    .R12out(1'b0), .R13out(1'b0), .R14out(1'b0), .R15out(1'b0),
    .HIout(1'b0), .LOout(1'b0),
    .InPortout(1'b0), .Cout(1'b0),

    .R0in(1'b0), .R2in(1'b0), .R4in(1'b0), .R5in(1'b0), .R6in(1'b0),
    .R7in(1'b0), .R8in(1'b0), .R9in(1'b0), .R10in(1'b0), .R11in(1'b0),
    .R12in(1'b0), .R13in(1'b0), .R14in(1'b0), .R15in(1'b0),

    .ADD(1'b0), .SUB(1'b0), .AND(1'b0), .OR(1'b0), .SHRA(1'b0),
    .SHR(1'b0), .SHL(1'b0), .ROR(1'b0), .ROL(1'b0),
    .MUL(1'b0), .NEG(1'b0), .NOT(1'b0),

    .IncPC(IncPC)
  );

  // ------------------------------------------------------------
  // Clock
  // ------------------------------------------------------------
  initial begin
    Clock = 1'b0;
    forever #10 Clock = ~Clock;
  end

  // ------------------------------------------------------------
  // State init
  // ------------------------------------------------------------
  initial begin
    Present_state = Default;
  end

  // ------------------------------------------------------------
  // State transitions
  // ------------------------------------------------------------
  always @(posedge Clock) begin
    case (Present_state)
      Default:    Present_state <= Reg_load1a;
      Reg_load1a: Present_state <= Reg_load1b;
      Reg_load1b: Present_state <= Reg_load2a;
      Reg_load2a: Present_state <= Reg_load2b;
      Reg_load2b: Present_state <= T0;
      T0:         Present_state <= T1;
      T1:         Present_state <= T2;
      T2:         Present_state <= T3;
      T3:         Present_state <= T4;
      T4:         Present_state <= T5;
      T5:         Present_state <= T6;
      T6:         Present_state <= T6;
      default:    Present_state <= Default;
    endcase
  end

  // ------------------------------------------------------------
  // Control signal generation
  // ------------------------------------------------------------
  always @(*) begin
    PCout=0; Zlowout=0; Zhighout=0; MDRout=0; R3out=0; R1out=0;
    MARin=0; Zin=0; PCin=0; MDRin=0; IRin=0; Yin=0;
    IncPC=0; Read=0; DIV=0; LOin=0; HIin=0; R3in=0; R1in=0;
    Mdatain = 32'h00000000;

    case (Present_state)

      Default: begin
        // nothing special; everything already cleared
      end

      // --------------------------------------------------------
      // Choose your test values here:
      //
      // 1) Normal unsigned: 0x34 / 0x05  => 52/5  => Q=0x0A, R=0x02
      // 2) Divide by zero:  0x34 / 0x00  => flag=1, Q=0xFFFFFFFF, R=0
      // 3) Signed example: -7 / 3:
      //      A = 0xFFFFFFF9, B=0x00000003 => Q=0xFFFFFFFE (-2), R=0xFFFFFFFF (-1)
      // --------------------------------------------------------

      // preload R3 = dividend
      Reg_load1a: begin
        // Mdatain = 32'h00000034;   // 52
        Mdatain = 32'hFFFFFFF9;      // -7  (signed test)
        Read=1; MDRin=1;
      end
      Reg_load1b: begin MDRout=1; R3in=1; end

      // preload R1 = divisor
      Reg_load2a: begin
        // Mdatain = 32'h00000005;   // 5  (normal)
        // Mdatain = 32'h00000000;   // 0  (divide by zero)
        Mdatain = 32'h00000003;      // 3  (signed test)
        Read=1; MDRin=1;
      end
      Reg_load2b: begin MDRout=1; R1in=1; end

      // fetch
      T0: begin PCout=1; MARin=1; IncPC=1; Zin=1; end
      T1: begin
        Zlowout=1; PCin=1; Read=1; MDRin=1;
        Mdatain=32'h61880000; // div R3, R1
      end
      T2: begin MDRout=1; IRin=1; end

      // execute DIV
      T3: begin R3out=1; Yin=1; end
      T4: begin R1out=1; DIV=1; Zin=1; end

      // write results
      T5: begin Zlowout=1;  LOin=1; end   // LO <= quotient
      T6: begin Zhighout=1; HIin=1; end   // HI <= remainder

    endcase
  end

endmodule
