// datpath_tb_shra.v
`timescale 1ns/10ps

module datapath_tb_shra;

  // Control / datapath signals
  reg PCout, Zlowout, MDRout, R0out, R4out;
  reg MARin, Zin, PCin, MDRin, IRin, Yin;
  reg IncPC, Read, SHRA, R7in, R0in, R4in;

  reg Clock;
  reg [31:0] Mdatain;

  // FSM states
  parameter Default    = 4'b0000,
            Reg_load1a = 4'b0001, Reg_load1b = 4'b0010,   // load R0
            Reg_load2a = 4'b0011, Reg_load2b = 4'b0100,   // load R4
            Reg_load3a = 4'b0101, Reg_load3b = 4'b0110,   // optional load R7
            T0         = 4'b0111,
            T1         = 4'b1000,
            T2         = 4'b1001,
            T3         = 4'b1010,
            T4         = 4'b1011,
            T5         = 4'b1100;

  reg [3:0] Present_state;

  // DUT (positional mapping; must match your DATAPATH module port order)
  DATAPATH DUT(
    PCout, Zlowout, MDRout, R0out, R4out,
    MARin, Zin, PCin, MDRin, IRin, Yin,
    IncPC, Read, SHRA, R7in, R0in, R4in,
    Clock, Mdatain
  );

  // Clock
  initial begin
    Clock = 1'b0;
    forever #10 Clock = ~Clock;
  end

  // State register
  initial begin
    Present_state = Default;
  end

  // Advance state each rising edge
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

  // Control outputs (combinational)
  always @(*) begin
    // Default deassert EVERYTHING each state to avoid “sticky” signals
    PCout=0; Zlowout=0; MDRout=0; R0out=0; R4out=0;
    MARin=0; Zin=0; PCin=0; MDRin=0; IRin=0; Yin=0;
    IncPC=0; Read=0; SHRA=0; R7in=0; R0in=0; R4in=0;
    Mdatain = 32'h00000000;

    case (Present_state)

      Default: begin
        // nothing special; everything already cleared
      end

      // Preload R0 = 0x34
      Reg_load1a: begin
        Mdatain = 32'h00000034;
        Read    = 1;
        MDRin   = 1;
      end
      Reg_load1b: begin
        MDRout = 1;
        R0in   = 1;
      end

      // Preload R4 = 0x45  (shift count)
      Reg_load2a: begin
        Mdatain = 32'h00000045;
        Read    = 1;
        MDRin   = 1;
      end
      Reg_load2b: begin
        MDRout = 1;
        R4in   = 1;
      end

      // Optional: preload R7 = 0x67 (destination gets overwritten later anyway)
      Reg_load3a: begin
        Mdatain = 32'h00000067;
        Read    = 1;
        MDRin   = 1;
      end
      Reg_load3b: begin
        MDRout = 1;
        R7in   = 1;
      end

      // === Instruction fetch ===
      T0: begin
        PCout = 1; MARin = 1; IncPC = 1; Zin = 1;
      end
      T1: begin
        Zlowout = 1; PCin = 1; Read = 1; MDRin = 1;
        Mdatain = 32'h2B820000; // shra R7, R0, R4
      end
      T2: begin
        MDRout = 1; IRin = 1;
      end

      // === Execute SHRA ===
      T3: begin
        R0out = 1; Yin = 1;          // Y <- R0
      end
      T4: begin
        R4out = 1; SHRA = 1; Zin = 1; // Z <- Y >>> R4 (arith)
      end
      T5: begin
        Zlowout = 1; R7in = 1;       // R7 <- Zlow
      end

    endcase
  end

endmodule





// datpath_tb_rol.v
`timescale 1ns/10ps

module datapath_tb_rol;

  reg PCout, Zlowout, MDRout, R0out, R4out;
  reg MARin, Zin, PCin, MDRin, IRin, Yin;
  reg IncPC, Read, ROL, R7in, R0in, R4in;

  reg Clock;
  reg [31:0] Mdatain;

  parameter Default    = 4'b0000,
            Reg_load1a = 4'b0001, Reg_load1b = 4'b0010,
            Reg_load2a = 4'b0011, Reg_load2b = 4'b0100,
            Reg_load3a = 4'b0101, Reg_load3b = 4'b0110,
            T0         = 4'b0111,
            T1         = 4'b1000,
            T2         = 4'b1001,
            T3         = 4'b1010,
            T4         = 4'b1011,
            T5         = 4'b1100;

  reg [3:0] Present_state;

  DATAPATH DUT(
    PCout, Zlowout, MDRout, R0out, R4out,
    MARin, Zin, PCin, MDRin, IRin, Yin,
    IncPC, Read, ROL, R7in, R0in, R4in,
    Clock, Mdatain
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
      T5:         Present_state <= T5;
      default:    Present_state <= Default;
    endcase
  end

  always @(*) begin
    PCout=0; Zlowout=0; MDRout=0; R0out=0; R4out=0;
    MARin=0; Zin=0; PCin=0; MDRin=0; IRin=0; Yin=0;
    IncPC=0; Read=0; ROL=0; R7in=0; R0in=0; R4in=0;
    Mdatain = 32'h00000000;

    case (Present_state)
      Reg_load1a: begin Mdatain=32'h00000034; Read=1; MDRin=1; end
      Reg_load1b: begin MDRout=1; R0in=1; end

      Reg_load2a: begin Mdatain=32'h00000045; Read=1; MDRin=1; end
      Reg_load2b: begin MDRout=1; R4in=1; end

      Reg_load3a: begin Mdatain=32'h00000067; Read=1; MDRin=1; end
      Reg_load3b: begin MDRout=1; R7in=1; end

      T0: begin PCout=1; MARin=1; IncPC=1; Zin=1; end
      T1: begin
        Zlowout=1; PCin=1; Read=1; MDRin=1;
        Mdatain=32'h43820000; // rol R7, R0, R4
      end
      T2: begin MDRout=1; IRin=1; end

      T3: begin R0out=1; Yin=1; end
      T4: begin R4out=1; ROL=1; Zin=1; end
      T5: begin Zlowout=1; R7in=1; end
    endcase
  end

endmodule




// datapath_tb_mul.v
`timescale 1ns/10ps

module datapath_tb_mul;

  reg PCout, Zlowout, Zhighout, MDRout, R3out, R1out;
  reg MARin, Zin, PCin, MDRin, IRin, Yin;
  reg IncPC, Read, MUL, LOin, HIin, R3in, R1in;

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

  // DUT: this port order must match YOUR mul-capable datapath top
  DATAPATH DUT(
    PCout, Zlowout, Zhighout, MDRout, R3out, R1out,
    MARin, Zin, PCin, MDRin, IRin, Yin,
    IncPC, Read, MUL, LOin, HIin, R3in, R1in,
    Clock, Mdatain
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

  always @(*) begin
    PCout=0; Zlowout=0; Zhighout=0; MDRout=0; R3out=0; R1out=0;
    MARin=0; Zin=0; PCin=0; MDRin=0; IRin=0; Yin=0;
    IncPC=0; Read=0; MUL=0; LOin=0; HIin=0; R3in=0; R1in=0;
    Mdatain = 32'h00000000;

    case (Present_state)

      // preload R3 = 0x34
      Reg_load1a: begin Mdatain=32'h00000034; Read=1; MDRin=1; end
      Reg_load1b: begin MDRout=1; R3in=1; end

      // preload R1 = 0x45
      Reg_load2a: begin Mdatain=32'h00000045; Read=1; MDRin=1; end
      Reg_load2b: begin MDRout=1; R1in=1; end

      // fetch
      T0: begin PCout=1; MARin=1; IncPC=1; Zin=1; end
      T1: begin
        Zlowout=1; PCin=1; Read=1; MDRin=1;
        Mdatain=32'h69880000; // mul R3, R1
      end
      T2: begin MDRout=1; IRin=1; end

      // execute
      T3: begin R3out=1; Yin=1; end
      T4: begin R1out=1; MUL=1; Zin=1; end

      // write results
      T5: begin Zlowout=1; LOin=1; end
      T6: begin Zhighout=1; HIin=1; end

    endcase
  end

endmodule
