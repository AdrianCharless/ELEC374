
module div_combinational (
    input  [31:0] A,              // Dividend
    input  [31:0] B,              // Divisor
    output [31:0] quotient,       // Result: A / B
    output [31:0] remainder       // Result: A % B
);

    // Internal registers for the algorithm
    reg [31:0] Q;                 // Quotient
    reg [31:0] R;                 // Remainder
    reg [31:0] divisor;
    integer i;

    always @(*) begin
        // Handle division by zero
        if (B == 32'd0) begin
            Q = 32'hFFFFFFFF;     // Set to max value for divide by zero
            R = 32'h00000000;
        end
        else begin
            // Initialize
            Q = 32'd0;
            R = 32'd0;
            divisor = B;

            // Restoring division algorithm (unrolled loop)
            // Process from MSB to LSB
            for (i = 31; i >= 0; i = i - 1) begin
                // Shift remainder left by 1 bit
                R = R << 1;
                
                // Move next bit of dividend into remainder LSB
                R[0] = A[i];
                
                // Try subtraction
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

    assign quotient = Q;
    assign remainder = R;

endmodule