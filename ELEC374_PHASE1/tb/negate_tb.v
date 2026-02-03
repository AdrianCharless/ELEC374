// ============================================================================
// NEG (Negate) Datapath Testbench - Phase 1
// Following control sequence from Section 3.12 (Page 15) of CPU Phase 1 PDF
// Tests: neg R4, R7
// ============================================================================

`timescale 1ns/10ps

module neg_datapath_tb;

    // Control signals for datapath
    reg R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out;
    reg R8out, R9out, R10out, R11out, R12out, R13out, R14out, R15out;
    reg HIout, LOout, ZHIout, ZLOout, PCout, MDRout, InPortout, Cout;
    
    reg R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in;
    reg R8in, R9in, R10in, R11in, R12in, R13in, R14in, R15in;
    reg HIin, LOin, PCin, IRin, Yin, Zin, MARin, MDRin;
    
    reg ADD, SUB, AND, OR, SHR, SHRA, SHL, ROR, ROL, MUL, DIV, NEG, NOT;
    reg IncPC, Read;
    reg [31:0] Mdatain;
    reg clock, clear;
    
    // Outputs from datapath
    wire [31:0] IR, Outport, BusMuxOut, Zhi, Zlo;
    
    // State machine parameters
    parameter Default = 4'b0000, Reg_load1a = 4'b0001, Reg_load1b = 4'b0010,
              Reg_load2a = 4'b0011, Reg_load2b = 4'b0100, T0 = 4'b0101,
              T1 = 4'b0110, T2 = 4'b0111, T3 = 4'b1000, T4 = 4'b1001;
    
    reg [3:0] Present_state = Default;
    
    // Instantiate the datapath
    DATAPATH DUT (
        .R0out(R0out), .R1out(R1out), .R2out(R2out), .R3out(R3out),
        .R4out(R4out), .R5out(R5out), .R6out(R6out), .R7out(R7out),
        .R8out(R8out), .R9out(R9out), .R10out(R10out), .R11out(R11out),
        .R12out(R12out), .R13out(R13out), .R14out(R14out), .R15out(R15out),
        .HIout(HIout), .LOout(LOout), .ZHIout(ZHIout), .ZLOout(ZLOout),
        .PCout(PCout), .MDRout(MDRout), .InPortout(InPortout), .Cout(Cout),
        
        .R0in(R0in), .R1in(R1in), .R2in(R2in), .R3in(R3in),
        .R4in(R4in), .R5in(R5in), .R6in(R6in), .R7in(R7in),
        .R8in(R8in), .R9in(R9in), .R10in(R10in), .R11in(R11in),
        .R12in(R12in), .R13in(R13in), .R14in(R14in), .R15in(R15in),
        .HIin(HIin), .LOin(LOin), .PCin(PCin), .IRin(IRin),
        .Yin(Yin), .Zin(Zin), .MARin(MARin), .MDRin(MDRin),
        
        .ADD(ADD), .SUB(SUB), .AND(AND), .OR(OR),
        .SHR(SHR), .SHRA(SHRA), .SHL(SHL), .ROR(ROR), .ROL(ROL),
        .MUL(MUL), .DIV(DIV), .NEG(NEG), .NOT(NOT),
        
        .IncPC(IncPC), .Read(Read), .Mdatain(Mdatain),
        .clock(clock), .clear(clear),
        
        .IR(IR), .Outport(Outport), .BusMuxOut(BusMuxOut),
        .Zhi(Zhi), .Zlo(Zlo)
    );
    
    // Clock generation
    initial begin
        clock = 0;
        forever #10 clock = ~clock;
    end
    
    // State machine
    always @(posedge clock) begin
        case (Present_state)
            Default    : Present_state = Reg_load1a;
            Reg_load1a : Present_state = Reg_load1b;
            Reg_load1b : Present_state = Reg_load2a;
            Reg_load2a : Present_state = Reg_load2b;
            Reg_load2b : Present_state = T0;
            T0         : Present_state = T1;
            T1         : Present_state = T2;
            T2         : Present_state = T3;
            T3         : Present_state = T4;
        endcase
    end
    
    // State actions
    always @(Present_state) begin
        case (Present_state)
            Default: begin
                // Initialize all signals
                R0out = 0; R1out = 0; R2out = 0; R3out = 0; R4out = 0; R5out = 0; R6out = 0; R7out = 0;
                R8out = 0; R9out = 0; R10out = 0; R11out = 0; R12out = 0; R13out = 0; R14out = 0; R15out = 0;
                HIout = 0; LOout = 0; ZHIout = 0; ZLOout = 0; PCout = 0; MDRout = 0; InPortout = 0; Cout = 0;
                
                R0in = 0; R1in = 0; R2in = 0; R3in = 0; R4in = 0; R5in = 0; R6in = 0; R7in = 0;
                R8in = 0; R9in = 0; R10in = 0; R11in = 0; R12in = 0; R13in = 0; R14in = 0; R15in = 0;
                HIin = 0; LOin = 0; PCin = 0; IRin = 0; Yin = 0; Zin = 0; MARin = 0; MDRin = 0;
                
                ADD = 0; SUB = 0; AND = 0; OR = 0; SHR = 0; SHRA = 0; SHL = 0; ROR = 0; ROL = 0;
                MUL = 0; DIV = 0; NEG = 0; NOT = 0;
                
                IncPC = 0; Read = 0; Mdatain = 32'h00000000;
                clear = 1;
                #10 clear = 0;
            end
            
            Reg_load1a: begin
                Mdatain <= 32'h0000002A;  // Load 42 into R7
                Read = 0; MDRin = 0;
                Read <= 1; MDRin <= 1;
                #15 Read <= 0; MDRin <= 0;
            end
            
            Reg_load1b: begin
                MDRout <= 1; R7in <= 1;
                #15 MDRout <= 0; R7in <= 0;  // R7 = 0x0000002A (42 decimal)
            end
            
            Reg_load2a: begin
                Mdatain <= 32'h00000099;  // Load arbitrary value into R4 (will be overwritten)
                Read <= 1; MDRin <= 1;
                #15 Read <= 0; MDRin <= 0;
            end
            
            Reg_load2b: begin
                MDRout <= 1; R4in <= 1;
                #15 MDRout <= 0; R4in <= 0;  // R4 = 0x00000099 (initial)
            end
            
            // Control Sequence for: neg R4, R7
            T0: begin
                PCout <= 1; MARin <= 1; IncPC <= 1; Zin <= 1;
            end
            
            T1: begin
                ZLOout <= 1; PCin <= 1; Read <= 1; MDRin <= 1;
                Mdatain <= 32'h71C00000;  // Opcode for "neg R4, R7"
                                          // 0111 0001 1100 0000 0000 ...
                                          // NEG=01110, Ra=0100, Rb=0111
            end
            
            T2: begin
                MDRout <= 1; IRin <= 1;
            end
            
            T3: begin
                R7out <= 1; NEG <= 1; Zin <= 1;
            end
            
            T4: begin
                ZLOout <= 1; R4in <= 1;
                // Result: R4 should contain -R7 = -42 = 0xFFFFFFD6
            end
        endcase
    end

endmodule
