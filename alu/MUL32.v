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

module MUL32 (
    input  wire [31:0] A,
    input  wire [31:0] B,
    output wire [31:0] HI,
    output wire [31:0] LO
);

 
    wire [63:0] sum_stage   [0:32];
    wire [63:0] carry_stage [0:32];
    wire [63:0] carry_in    [0:32]; 

    assign sum_stage[0]   = 64'd0;
    assign carry_stage[0] = 64'd0;
    assign carry_in[0]    = 64'd0;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : MUL_CSA_CHAIN
            wire [63:0] pp_i;

            
            assign pp_i = B[i] ? ({32'd0, A} << i) : 64'd0;

            CarrySaveAdder64 csa64 (
                .A   (sum_stage[i]),
                .B   (carry_in[i]),
                .C   (pp_i),
                .S   (sum_stage[i+1]),
                .Cout(carry_stage[i+1])
            );

            assign carry_in[i+1] = carry_stage[i+1] << 1;
        end
    endgenerate

    wire [63:0] product;
    wire        product_cout; // unused

    Add64 add64 (
        .A   (sum_stage[32]),
        .B   (carry_in[32]),
        .Sum (product),
        .Cout(product_cout)
    );

    assign LO = product[31:0];
    assign HI = product[63:32];

endmodule
