// DIV_restoring_32.v
// Unsigned 32-bit restoring division (combinational - no clock)
// quotient = dividend / divisor
// remainder = dividend % divisor
//
// Fully combinational: result available after propagation delay

module DIV_restoring_32 (
	input  wire [31:0] dividend,
	input  wire [31:0] divisor,

	output reg  [31:0] quotient,
	output reg  [31:0] remainder
);

	reg [32:0] A;        // 33-bit remainder (sign check via MSB)
	reg [31:0] Q;        // dividend/quotient
	reg [32:0] M;        // 33-bit divisor
	reg [32:0] A_shift;
	reg [31:0] Q_shift;
	reg [32:0] A_sub;

	integer i;

	always @(*) begin
		if (divisor == 32'd0) begin
			// divide-by-zero: quotient=0, remainder=dividend
			quotient  = 32'd0;
			remainder = dividend;
		end else begin
			A = 33'd0;
			Q = dividend;
			M = {1'b0, divisor};

			for (i = 0; i < 32; i = i + 1) begin
				// 1) shift left (A,Q)
				A_shift = {A[31:0], Q[31]};
				Q_shift = {Q[30:0], 1'b0};

				// 2) subtract divisor
				A_sub = A_shift - M;

				// 3) restore if negative; set Q0
				if (A_sub[32]) begin
					A = A_shift;
					Q = {Q_shift[31:1], 1'b0};
				end else begin
					A = A_sub;
					Q = {Q_shift[31:1], 1'b1};
				end
			end

			quotient  = Q;
			remainder = A[31:0];
		end
	end

endmodule
</think>
Fixing the module: outputs driven by `always @(*)` must be `reg`:
<｜tool▁calls▁begin｜><｜tool▁call▁begin｜>
StrReplace
