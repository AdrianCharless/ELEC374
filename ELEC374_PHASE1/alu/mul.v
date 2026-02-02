module mul (
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] HI,
    output [31:0] LO
);
    // Running CSA state
    reg  [63:0] sum_r;
    reg  [63:0] car_r;
    reg  [63:0] pp_r;
    integer i;

    // CSA outputs
    wire [63:0] sum_next;
    wire [63:0] car_next;

    // Final product
    wire [63:0] product;
    wire        product_cout;

    // CSA step: sum_r + car_r + pp_r -> sum_next, car_next
    csa64 csa (
        .A   (sum_r),
        .B   (car_r),
        .C   (pp_r),
        .S   (sum_next),
        .Cout(car_next)
    );

    // Final collapse: product = sum_r + (car_r << 1)
    adder64 final_add (
        .A   (sum_r),
        .B   (car_r << 1),
        .Sum (product),
        .Cout(product_cout)
    );

    // Combinational accumulation of 32 partial products
    always @* begin
        sum_r = 64'd0;
        car_r = 64'd0;

        for (i = 0; i < 32; i = i + 1) begin
            // partial product for bit i of multiplier B
            if (B[i])
                pp_r = ({32'd0, A} << i);
            else
                pp_r = 64'd0;

            // update CSA state
            sum_r = sum_next;
            car_r = car_next;
        end
    end

    assign LO = product[31:0];
    assign HI = product[63:32];

endmodule
