/*
module MUL32 (
    input  wire [31:0] A,
    input  wire [31:0] B,
    output wire [31:0] HI,
    output wire [31:0] LO
);
    integer i;

    reg  [63:0] sum_t, car_t, pp_t;
    reg  [63:0] s_next, c_next;
    reg  [63:0] product;

    always @* begin
        sum_t = 64'd0;
        car_t = 64'd0;

        // accumulate 32 partial products with CSA
        for (i = 0; i < 32; i = i + 1) begin
            pp_t = B[i] ? ({32'd0, A} << i) : 64'd0;

            // CSA step:
            // sum = A ^ B ^ C
            // carry = majority(A,B,C)
            s_next = sum_t ^ car_t ^ pp_t;
            c_next = (sum_t & car_t) | (sum_t & pp_t) | (car_t & pp_t);

            sum_t = s_next;
            car_t = c_next;
        end

        // final collapse
        product = sum_t + (car_t << 1);
    end

    assign LO = product[31:0];
    assign HI = product[63:32];

endmodule
*/

module MUL (
    input  wire [31:0] A,
    input  wire [31:0] B,
    output wire [31:0] HI,
    output wire [31:0] LO
);

    // 32 stages of carry-save accumulation w an array of 64 bit wires
    wire [63:0] sum_stage   [0:32];
    wire [63:0] carry_stage [0:32];

    assign sum_stage[0]   = 64'd0;
    assign carry_stage[0] = 64'd0;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : MUL_CSA_CHAIN
            wire [63:0] pp_i;

            // if B[i] = 1 → add A shifted left by i
            // if B[i] = 0 → add 0
            assign pp_i = B[i] ? ({32'd0, A} << i) : 64'd0;

            CarrySaveAdder64 csa64 (
                .A   (sum_stage[i]),
                .B   (carry_stage[i]),
                .C   (pp_i),
                .S   (sum_stage[i+1]),
                .Cout(carry_stage[i+1])
            );
        end
    endgenerate

    // Final collapse: product = sum + (carry << 1)
    wire [63:0] carry_shifted;
    assign carry_shifted = carry_stage[32] << 1;

    wire [63:0] product;
    wire        product_cout; // unused

    Add64 add64 (
        .A   (sum_stage[32]),
        .B   (carry_shifted),
        .Sum (product),
        .Cout(product_cout)
    );

    assign LO = product[31:0];
    assign HI = product[63:32];

endmodule
