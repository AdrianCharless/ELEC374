module DIV (
    input  [31:0] A,              // Dividend
    input  [31:0] B,              // Divisor
    output [31:0] quotient,       // Result: A / B
    output [31:0] remainder,      // Result: A % B
    output reg    div_by_zero     // NEW: divide-by-zero flag
);

    reg [31:0] Q;                 
    reg [31:0] R;                 
    reg [31:0] divisor;
    integer i;

    always @(*) begin
        // Default values (avoid inferred latches)
        Q = 32'd0;
        R = 32'd0;
        divisor = B;
        div_by_zero = 1'b0;

        // Divide by zero case
        if (B == 32'd0) begin
            Q = 32'hFFFFFFFF;     
            R = 32'h00000000;
            div_by_zero = 1'b1;   // 🚨 FLAG SET
        end
        else begin
            // Restoring division
            for (i = 31; i >= 0; i = i - 1) begin
                R = R << 1;
                R[0] = A[i];

                if (R >= divisor) begin
                    R = R - divisor;
                    Q[i] = 1'b1;
                end
                else begin
                    Q[i] = 1'b0;
                end
            end
        end
    end

    assign quotient  = Q;
    assign remainder = R;

endmodule
