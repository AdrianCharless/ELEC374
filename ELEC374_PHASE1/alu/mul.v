module MUL (
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
