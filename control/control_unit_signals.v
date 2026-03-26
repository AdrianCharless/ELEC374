`timescale 1ns/1ps
 
module control_unit_signals(
    input  wire [6:0] state,
    input  wire [31:0] IR,
    input  wire        CON_FF,
 
    output reg Gra, Grb, Grc,
    output reg Rin, Rout, R12in,
    output reg BAout, Cout,
 
    output reg PCout, Zlowout, Zhighout, MDRout,
    output reg HIout, LOout, InPortout,
 
    output reg PCin, IRin, Yin, Zin,
    output reg HIin, LOin,
    output reg OutPortin,
 
    output reg MARin, MDRin,
    output reg Read, Write,
    output reg IncPC,
 
    output reg ADD, SUB, AND, OR,
    output reg NEG, NOT,
    output reg SHR, SHRA, SHL,
    output reg ROR, ROL,
    output reg MUL, DIV,
 
    output reg CONin
);
 
    localparam [6:0]
        S_RESET  = 7'd0,
        S_FETCH0 = 7'd1,
        S_FETCH1 = 7'd2,
        S_FETCH2 = 7'd3,
        S_HALT   = 7'd4,
        S_FETCH3 = 7'd78,   
 
        S_ADD3   = 7'd5,
        S_ADD4   = 7'd6,
        S_ADD5   = 7'd7,
 
        S_SUB3   = 7'd8,
        S_SUB4   = 7'd9,
        S_SUB5   = 7'd10,
 
        S_AND3   = 7'd11,
        S_AND4   = 7'd12,
        S_AND5   = 7'd13,
 
        S_OR3    = 7'd14,
        S_OR4    = 7'd15,
        S_OR5    = 7'd16,
 
        S_SHR3   = 7'd17,
        S_SHR4   = 7'd18,
        S_SHR5   = 7'd19,
 
        S_SHRA3  = 7'd20,
        S_SHRA4  = 7'd21,
        S_SHRA5  = 7'd22,
 
        S_SHL3   = 7'd23,
        S_SHL4   = 7'd24,
        S_SHL5   = 7'd25,
 
        S_ROR3   = 7'd26,
        S_ROR4   = 7'd27,
        S_ROR5   = 7'd28,
 
        S_ROL3   = 7'd29,
        S_ROL4   = 7'd30,
        S_ROL5   = 7'd31,
 
        S_NEG3   = 7'd32,
        S_NEG4   = 7'd33,
 
        S_NOT3   = 7'd34,
        S_NOT4   = 7'd35,
 
        S_MUL3   = 7'd36,
        S_MUL4   = 7'd37,
        S_MUL5   = 7'd38,
        S_MUL6   = 7'd39,
 
        S_DIV3   = 7'd40,
        S_DIV4   = 7'd41,
        S_DIV5   = 7'd42,
        S_DIV6   = 7'd43,
 
        S_LD3    = 7'd44,
        S_LD4    = 7'd45,
        S_LD5    = 7'd46,
        S_LD6    = 7'd47,
        S_LD7    = 7'd48,
 
        S_LDI3   = 7'd49,
        S_LDI4   = 7'd50,
        S_LDI5   = 7'd51,
 
        S_ST3    = 7'd52,
        S_ST4    = 7'd53,
        S_ST5    = 7'd54,
        S_ST6    = 7'd55,
        S_ST7    = 7'd56,
 
        S_ADDI3  = 7'd57,
        S_ADDI4  = 7'd58,
        S_ADDI5  = 7'd59,
 
        S_ANDI3  = 7'd60,
        S_ANDI4  = 7'd61,
        S_ANDI5  = 7'd62,
 
        S_ORI3   = 7'd63,
        S_ORI4   = 7'd64,
        S_ORI5   = 7'd65,
 
        S_BR3    = 7'd66,
        S_BR4    = 7'd67,
        S_BR5    = 7'd68,
        S_BR6    = 7'd69,
 
        S_JR3    = 7'd70,
 
        S_JAL3   = 7'd71,
        S_JAL4   = 7'd72,
 
        S_MFHI3  = 7'd73,
        S_MFLO3  = 7'd74,
 
        S_IN3    = 7'd75,
        S_OUT3   = 7'd76,
 
        S_NOP3   = 7'd77;
 
    always @(*) begin
        Gra = 0; Grb = 0; Grc = 0;
        Rin = 0; Rout = 0; R12in = 0;
        BAout = 0; Cout = 0;
 
        PCout = 0; Zlowout = 0; Zhighout = 0; MDRout = 0;
        HIout = 0; LOout = 0; InPortout = 0;
 
        PCin = 0; IRin = 0; Yin = 0; Zin = 0;
        HIin = 0; LOin = 0;
        OutPortin = 0;
 
        MARin = 0; MDRin = 0;
        Read = 0; Write = 0;
        IncPC = 0;
 
        ADD = 0; SUB = 0; AND = 0; OR = 0;
        NEG = 0; NOT = 0;
        SHR = 0; SHRA = 0; SHL = 0;
        ROR = 0; ROL = 0;
        MUL = 0; DIV = 0;
 
        CONin = 0;
 
        case (state)
 
            S_RESET: begin
            end
 
            S_HALT: begin
            end
 
            // T0: MAR <- PC, PC <- PC + 1 
            S_FETCH0: begin
                PCout = 1;
                MARin = 1;
                IncPC = 1;
            end
 
            // T1: MDR <- M[MAR]
            S_FETCH1: begin
                Read  = 1;
                MDRin = 1;
            end
 
            // T2: IR <- MDR
            S_FETCH2: begin
                MDRout = 1;
                IRin   = 1;
            end
 
            // add Ra <- Rb + Rc
            S_ADD3: begin Grb = 1; Rout = 1; Yin = 1; end
            S_ADD4: begin Grc = 1; Rout = 1; ADD = 1; Zin = 1; end
            S_ADD5: begin Gra = 1; Rin = 1; Zlowout = 1; end
 
            // sub Ra <- Rb - Rc
            S_SUB3: begin Grb = 1; Rout = 1; Yin = 1; end
            S_SUB4: begin Grc = 1; Rout = 1; SUB = 1; Zin = 1; end
            S_SUB5: begin Gra = 1; Rin = 1; Zlowout = 1; end
 
            // and Ra <- Rb & Rc
            S_AND3: begin Grb = 1; Rout = 1; Yin = 1; end
            S_AND4: begin Grc = 1; Rout = 1; AND = 1; Zin = 1; end
            S_AND5: begin Gra = 1; Rin = 1; Zlowout = 1; end
 
            // or Ra <- Rb | Rc
            S_OR3: begin Grb = 1; Rout = 1; Yin = 1; end
            S_OR4: begin Grc = 1; Rout = 1; OR = 1; Zin = 1; end
            S_OR5: begin Gra = 1; Rin = 1; Zlowout = 1; end
 
            // shr Ra <- Rb >> Rc
            S_SHR3: begin Grb = 1; Rout = 1; Yin = 1; end
            S_SHR4: begin Grc = 1; Rout = 1; SHR = 1; Zin = 1; end
            S_SHR5: begin Gra = 1; Rin = 1; Zlowout = 1; end
 
            // shra
            S_SHRA3: begin Grb = 1; Rout = 1; Yin = 1; end
            S_SHRA4: begin Grc = 1; Rout = 1; SHRA = 1; Zin = 1; end
            S_SHRA5: begin Gra = 1; Rin = 1; Zlowout = 1; end
 
            // shl
            S_SHL3: begin Grb = 1; Rout = 1; Yin = 1; end
            S_SHL4: begin Grc = 1; Rout = 1; SHL = 1; Zin = 1; end
            S_SHL5: begin Gra = 1; Rin = 1; Zlowout = 1; end
 
            // ror
            S_ROR3: begin Grb = 1; Rout = 1; Yin = 1; end
            S_ROR4: begin Grc = 1; Rout = 1; ROR = 1; Zin = 1; end
            S_ROR5: begin Gra = 1; Rin = 1; Zlowout = 1; end
 
            // rol
            S_ROL3: begin Grb = 1; Rout = 1; Yin = 1; end
            S_ROL4: begin Grc = 1; Rout = 1; ROL = 1; Zin = 1; end
            S_ROL5: begin Gra = 1; Rin = 1; Zlowout = 1; end
 
            // neg Ra <- -Rb
            S_NEG3: begin Grb = 1; Rout = 1; NEG = 1; Zin = 1; end
            S_NEG4: begin Gra = 1; Rin = 1; Zlowout = 1; end
 
            // not Ra <- ~Rb
            S_NOT3: begin Grb = 1; Rout = 1; NOT = 1; Zin = 1; end
            S_NOT4: begin Gra = 1; Rin = 1; Zlowout = 1; end
 
            // mul HI:LO <- Ra * Rb
            S_MUL3: begin Gra = 1; Rout = 1; Yin = 1; end
            S_MUL4: begin Grb = 1; Rout = 1; MUL = 1; Zin = 1; end
            S_MUL5: begin Zlowout = 1; LOin = 1; end
            S_MUL6: begin Zhighout = 1; HIin = 1; end
 
            // div LO <- Ra/Rb, HI <- Ra%Rb
            S_DIV3: begin Gra = 1; Rout = 1; Yin = 1; end
            S_DIV4: begin Grb = 1; Rout = 1; DIV = 1; Zin = 1; end
            S_DIV5: begin Zlowout = 1; LOin = 1; end
            S_DIV6: begin Zhighout = 1; HIin = 1; end
 
            // ld Ra <- M[Rb + C]
            S_LD3: begin Grb = 1; BAout = 1; Yin = 1; end
            S_LD4: begin Cout = 1; ADD = 1; Zin = 1; end
            S_LD5: begin Zlowout = 1; MARin = 1; end
            S_LD6: begin Read = 1; MDRin = 1; end
            S_LD7: begin Gra = 1; Rin = 1; MDRout = 1; end
 
            // ldi Ra <- Rb + C
            S_LDI3: begin Grb = 1; BAout = 1; Yin = 1; end
            S_LDI4: begin Cout = 1; ADD = 1; Zin = 1; end
            S_LDI5: begin Gra = 1; Rin = 1; Zlowout = 1; end
 
            // st M[Rb + C] <- Ra
            S_ST3: begin Grb = 1; BAout = 1; Yin = 1; end
            S_ST4: begin Cout = 1; ADD = 1; Zin = 1; end
            S_ST5: begin Zlowout = 1; MARin = 1; end
            S_ST6: begin Gra = 1; Rout = 1; MDRin = 1; end
            S_ST7: begin Write = 1; end
 
            // addi Ra <- Rb + C
            S_ADDI3: begin Grb = 1; Rout = 1; Yin = 1; end
            S_ADDI4: begin Cout = 1; ADD = 1; Zin = 1; end
            S_ADDI5: begin Gra = 1; Rin = 1; Zlowout = 1; end
 
            // andi Ra <- Rb & C
            S_ANDI3: begin Grb = 1; Rout = 1; Yin = 1; end
            S_ANDI4: begin Cout = 1; AND = 1; Zin = 1; end
            S_ANDI5: begin Gra = 1; Rin = 1; Zlowout = 1; end
 
            // ori Ra <- Rb | C
            S_ORI3: begin Grb = 1; Rout = 1; Yin = 1; end
            S_ORI4: begin Cout = 1; OR = 1; Zin = 1; end
            S_ORI5: begin Gra = 1; Rin = 1; Zlowout = 1; end
 
            // branch
            S_BR3: begin Gra = 1; Rout = 1; CONin = 1; end
            S_BR4: begin PCout = 1; Yin = 1; end
            S_BR5: begin Cout = 1; ADD = 1; Zin = 1; end
            S_BR6: begin Zlowout = 1; PCin = CON_FF; end
 
            // jr PC <- Ra
            S_JR3: begin Gra = 1; Rout = 1; PCin = 1; end
 
            // jal R12 <- PC, PC <- Ra
            S_JAL3: begin PCout = 1; R12in = 1; end
            S_JAL4: begin Gra = 1; Rout = 1; PCin = 1; end
 
            // mfhi Ra <- HI
            S_MFHI3: begin HIout = 1; Gra = 1; Rin = 1; end
 
            // mflo Ra <- LO
            S_MFLO3: begin LOout = 1; Gra = 1; Rin = 1; end
 
            // in Ra <- InPort
            S_IN3: begin Gra = 1; Rin = 1; InPortout = 1; end
 
            // out OutPort <- Ra
            S_OUT3: begin Gra = 1; Rout = 1; OutPortin = 1; end
 
            S_NOP3: begin end
 
            
            S_FETCH3: begin end
 
            default: begin end
 
        endcase
    end
 
endmodule
