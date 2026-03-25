`timescale 1ns/1ps

module control_unit_fsm (
    input  wire        Clock,
    input  wire        Reset,
    input  wire        Stop,
    input  wire [31:0] IR,

    output reg  [6:0]  present_state
);

    // opcode definitions from CPU specification
    // IR[31:27]
    localparam [4:0]
        OP_ADD  = 5'b00000,
        OP_SUB  = 5'b00001,
        OP_AND  = 5'b00010,
        OP_OR   = 5'b00011,
        OP_SHR  = 5'b00100,
        OP_SHRA = 5'b00101,
        OP_SHL  = 5'b00110,
        OP_ROR  = 5'b00111,
        OP_ROL  = 5'b01000,

        OP_ADDI = 5'b01001,
        OP_ANDI = 5'b01010,
        OP_ORI  = 5'b01011,

        OP_DIV  = 5'b01100,
        OP_MUL  = 5'b01101,
        OP_NEG  = 5'b01110,
        OP_NOT  = 5'b01111,

        OP_LD   = 5'b10000,
        OP_LDI  = 5'b10001,
        OP_ST   = 5'b10010,

        OP_JAL  = 5'b10011,
        OP_JR   = 5'b10100,
        OP_BR   = 5'b10101,

        OP_IN   = 5'b10110,
        OP_OUT  = 5'b10111,
        OP_MFHI = 5'b11000,
        OP_MFLO = 5'b11001,

        OP_NOP  = 5'b11010,
        OP_HALT = 5'b11011;

    // state definitions
    localparam [6:0]
        S_RESET  = 7'd0,
        S_FETCH0 = 7'd1,
        S_FETCH1 = 7'd2,
        S_FETCH2 = 7'd3,
        S_HALT   = 7'd4,

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

    reg [6:0] next_state;

    wire [4:0] opcode;
    assign opcode = IR[31:27];

    // state register
    // reset has highest priority.
    // stop behaves like halt.
    always @(posedge Clock or posedge Reset) begin
        if (Reset)
            present_state <= S_RESET;
        else
            present_state <= next_state;
    end

    // next-state logic
    always @(*) begin
        // default: hold state unless changed below
        next_state = present_state;

        // stop should behave like halt from anywhere
        if (Stop) begin
            next_state = S_HALT;
        end
        else begin
            case (present_state)

                // global states
                S_RESET:  next_state = S_FETCH0;
                S_FETCH0: next_state = S_FETCH1;
                S_FETCH1: next_state = S_FETCH2;

                S_FETCH2: begin
                    case (opcode)
                        OP_ADD:  next_state = S_ADD3;
                        OP_SUB:  next_state = S_SUB3;
                        OP_AND:  next_state = S_AND3;
                        OP_OR:   next_state = S_OR3;
                        OP_SHR:  next_state = S_SHR3;
                        OP_SHRA: next_state = S_SHRA3;
                        OP_SHL:  next_state = S_SHL3;
                        OP_ROR:  next_state = S_ROR3;
                        OP_ROL:  next_state = S_ROL3;

                        OP_ADDI: next_state = S_ADDI3;
                        OP_ANDI: next_state = S_ANDI3;
                        OP_ORI:  next_state = S_ORI3;

                        OP_DIV:  next_state = S_DIV3;
                        OP_MUL:  next_state = S_MUL3;
                        OP_NEG:  next_state = S_NEG3;
                        OP_NOT:  next_state = S_NOT3;

                        OP_LD:   next_state = S_LD3;
                        OP_LDI:  next_state = S_LDI3;
                        OP_ST:   next_state = S_ST3;

                        OP_JAL:  next_state = S_JAL3;
                        OP_JR:   next_state = S_JR3;
                        OP_BR:   next_state = S_BR3;

                        OP_IN:   next_state = S_IN3;
                        OP_OUT:  next_state = S_OUT3;
                        OP_MFHI: next_state = S_MFHI3;
                        OP_MFLO: next_state = S_MFLO3;

                        OP_NOP:  next_state = S_NOP3;
                        OP_HALT: next_state = S_HALT;

                        default: next_state = S_FETCH0;
                    endcase
                end

                S_HALT: next_state = S_HALT;

                // arithmetic / logical
                S_ADD3:  next_state = S_ADD4;
                S_ADD4:  next_state = S_ADD5;
                S_ADD5:  next_state = S_FETCH0;

                S_SUB3:  next_state = S_SUB4;
                S_SUB4:  next_state = S_SUB5;
                S_SUB5:  next_state = S_FETCH0;

                S_AND3:  next_state = S_AND4;
                S_AND4:  next_state = S_AND5;
                S_AND5:  next_state = S_FETCH0;

                S_OR3:   next_state = S_OR4;
                S_OR4:   next_state = S_OR5;
                S_OR5:   next_state = S_FETCH0;

                S_SHR3:  next_state = S_SHR4;
                S_SHR4:  next_state = S_SHR5;
                S_SHR5:  next_state = S_FETCH0;

                S_SHRA3: next_state = S_SHRA4;
                S_SHRA4: next_state = S_SHRA5;
                S_SHRA5: next_state = S_FETCH0;

                S_SHL3:  next_state = S_SHL4;
                S_SHL4:  next_state = S_SHL5;
                S_SHL5:  next_state = S_FETCH0;

                S_ROR3:  next_state = S_ROR4;
                S_ROR4:  next_state = S_ROR5;
                S_ROR5:  next_state = S_FETCH0;

                S_ROL3:  next_state = S_ROL4;
                S_ROL4:  next_state = S_ROL5;
                S_ROL5:  next_state = S_FETCH0;

                S_NEG3:  next_state = S_NEG4;
                S_NEG4:  next_state = S_FETCH0;

                S_NOT3:  next_state = S_NOT4;
                S_NOT4:  next_state = S_FETCH0;

                S_MUL3:  next_state = S_MUL4;
                S_MUL4:  next_state = S_MUL5;
                S_MUL5:  next_state = S_MUL6;
                S_MUL6:  next_state = S_FETCH0;

                S_DIV3:  next_state = S_DIV4;
                S_DIV4:  next_state = S_DIV5;
                S_DIV5:  next_state = S_DIV6;
                S_DIV6:  next_state = S_FETCH0;

                // load / store
                S_LD3:   next_state = S_LD4;
                S_LD4:   next_state = S_LD5;
                S_LD5:   next_state = S_LD6;
                S_LD6:   next_state = S_LD7;
                S_LD7:   next_state = S_FETCH0;

                S_LDI3:  next_state = S_LDI4;
                S_LDI4:  next_state = S_LDI5;
                S_LDI5:  next_state = S_FETCH0;

                S_ST3:   next_state = S_ST4;
                S_ST4:   next_state = S_ST5;
                S_ST5:   next_state = S_ST6;
                S_ST6:   next_state = S_ST7;
                S_ST7:   next_state = S_FETCH0;

                // immediate ALU
                S_ADDI3: next_state = S_ADDI4;
                S_ADDI4: next_state = S_ADDI5;
                S_ADDI5: next_state = S_FETCH0;

                S_ANDI3: next_state = S_ANDI4;
                S_ANDI4: next_state = S_ANDI5;
                S_ANDI5: next_state = S_FETCH0;

                S_ORI3:  next_state = S_ORI4;
                S_ORI4:  next_state = S_ORI5;
                S_ORI5:  next_state = S_FETCH0;

                // branch / jump
                S_BR3:   next_state = S_BR4;
                S_BR4:   next_state = S_BR5;
                S_BR5:   next_state = S_BR6;
                S_BR6:   next_state = S_FETCH0;

                S_JR3:   next_state = S_FETCH0;

                S_JAL3:  next_state = S_JAL4;
                S_JAL4:  next_state = S_FETCH0;

                // special / I/O / misc
                S_MFHI3: next_state = S_FETCH0;
                S_MFLO3: next_state = S_FETCH0;

                S_IN3:   next_state = S_FETCH0;
                S_OUT3:  next_state = S_FETCH0;

                S_NOP3:  next_state = S_FETCH0;

                default: next_state = S_FETCH0;
            endcase
        end
    end

endmodule