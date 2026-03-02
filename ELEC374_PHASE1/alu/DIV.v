module DIV (
    input  [31:0] A,              // Dividend (signed 2's complement)
    input  [31:0] B,              // Divisor  (signed 2's complement)
    output [31:0] quotient,       // A / B
    output [31:0] remainder,      // A % B
    output reg    div_by_zero
);

    // Magnitudes used for unsigned restoring divide
    reg [31:0] Qmag;
    reg [31:0] Rmag;
    reg [31:0] divisor;

    // Final signed outputs (as 2's complement bit patterns)
    reg [31:0] Q;
    reg [31:0] R;

    // Sign + abs values
    reg        signA, signB, signQ;
    reg [31:0] absA, absB;

    integer i;

    always @(*) begin
        // Defaults
        Q = 32'd0;
        R = 32'd0;
        Qmag = 32'd0;
        Rmag = 32'd0;
        divisor = 32'd0;
        div_by_zero = 1'b0;

        // Signs
        signA = A[31];
        signB = B[31];

        // Absolute values (2's complement)
        absA = signA ? (~A + 32'd1) : A;
        absB = signB ? (~B + 32'd1) : B;

        // Divide-by-zero
        if (B == 32'd0) begin
            Q = 32'hFFFFFFFF;     // your chosen behavior
            R = 32'h00000000;
            div_by_zero = 1'b1;
        end
        else begin
            divisor = absB;

            // Unsigned restoring division on magnitudes: absA / absB
            for (i = 31; i >= 0; i = i - 1) begin
                Rmag = Rmag << 1;
                Rmag[0] = absA[i];

                if (Rmag >= divisor) begin
                    Rmag = Rmag - divisor;
                    Qmag[i] = 1'b1;
                end else begin
                    Qmag[i] = 1'b0;
                end
            end

            // Apply signs
            signQ = signA ^ signB;

            // Quotient sign fix
            Q = signQ ? (~Qmag + 32'd1) : Qmag;

            // Remainder sign fix (remainder follows dividend)
            R = signA ? (~Rmag + 32'd1) : Rmag;
        end
    end

    assign quotient  = Q;
    assign remainder = R;

endmodule
