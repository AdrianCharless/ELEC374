`timescale 1ns/10ps
 
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
 
    parameter  Default = 4'd0,
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
        $dumpfile("waveforms.vcd");
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
 
        // addi R7, R4, -9
        // op=01001 Ra=R7=0111 Rb=R4=0100 C=-9 => 32'h4BA7FFF7
        DUT.MEM.ram.mem[9'h000] = 32'h4BA7FFF7;
 
        #35 clear = 0;
        // preload R4 = 0x14 (20 decimal), PC = 0
        force DUT.R4.q = 32'h00000014;
        force DUT.PC.q = 32'h00000000;
        #9;
        release DUT.R4.q;
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
            T4      : Present_state = T5;
            T5      : Present_state = Done;
            Done    : Present_state = Done;
            default : Present_state = Done;
        endcase
    end
 
    always @(Present_state) begin
        Gra = 0;        Grb = 0;        Grc = 0;
        Rin = 0;        Rout = 0;       BAout = 0;      Cout = 0;
 
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
 
            T0: begin
                PCout = 1;
                MARin = 1;
            end
 
            T1: begin
                Read  = 1;
                MDRin = 1;
            end
 
            T2: begin
                MDRout = 1;
                IRin   = 1;
            end
 
            // R4 -> bus -> Y
            T3: begin
                Grb  = 1;
                Rout = 1;
                Yin  = 1;
            end
 
            // Z <- Y + sign_ext(C)  [20 + (-9) = 11 = 0x0B]
            T4: begin
                Cout = 1;
                ADD  = 1;
                Zin  = 1;
            end
 
            // R7 <- Zlow
            T5: begin
                Zlowout = 1;
                Gra     = 1;
                Rin     = 1;
            end
 
            Done: begin
                $display("addi R7, R4, -9 result: R7 = %h (expected 0000000B)", DUT.BusMuxIn_R7);
                #20 $stop;
            end
 
        endcase
    end
 
    initial begin
        #127500;
        $display("Simulation complete.");
        $finish;
    end
 
endmodule
