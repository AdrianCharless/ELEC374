module DIV32 (
    input  [31:0] A,              // dividend (signed 2's complement)
    input  [31:0] B,              // divisor  (signed 2's complement)
    output [31:0] quotient,
    output [31:0] remainder,
    output reg    div_by_zero
);

    reg [31:0] Qmag, Rmag, divisor;
    reg [31:0] Q, R;
    reg        signA, signB, signQ;
    reg [31:0] absA, absB;
    integer i;

    always @(*) begin
        // Defaults (avoid latches)
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
            Q = 32'hFFFFFFFF;
            R = 32'h00000000;
            div_by_zero = 1'b1;
        end
        // Overflow guard: (-2^31) / (-1)
        else if (A == 32'h80000000 && B == 32'hFFFFFFFF) begin
            Q = 32'h80000000;
            R = 32'h00000000;
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

            // Quotient sign = signA XOR signB
            signQ = signA ^ signB;

            // Apply sign to quotient
            Q = signQ ? (~Qmag + 32'd1) : Qmag;

            // Remainder follows dividend sign
            R = signA ? (~Rmag + 32'd1) : Rmag;
        end
    end

    assign quotient  = Q;
    assign remainder = R;

endmodule
