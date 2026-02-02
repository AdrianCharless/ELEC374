// DIV_restoring_32.v
// Unsigned 32-bit restoring division
// quotient = dividend / divisor
// remainder = dividend % divisor
//
// start: pulse high for 1 cycle to begin
// busy:  1 while running
// done:  pulses high for 1 cycle when finished

module DIV_restoring_32 (
	input  wire        clk,
	input  wire        clr,

	input  wire        start,
	input  wire [31:0] dividend,
	input  wire [31:0] divisor,

	output reg  [31:0] quotient,
	output reg  [31:0] remainder,
	output reg         busy,
	output reg         done
);

	reg [32:0] A;        // 33-bit remainder (signed check via MSB)
	reg [31:0] Q;        // dividend/quotient
	reg [32:0] M;        // 33-bit divisor
	reg [5:0]  count;    // counts 32..1

	// Intermediate values (must be at module level in Verilog)
	reg [32:0] A_shift;
	reg [31:0] Q_shift;
	reg [32:0] A_sub;

	always @(posedge clk or posedge clr) begin
		if (clr) begin
			A <= 33'd0; Q <= 32'd0; M <= 33'd0; count <= 6'd0;
			quotient <= 32'd0; remainder <= 32'd0;
			busy <= 1'b0; done <= 1'b0;
		end else begin
			done <= 1'b0; // default: single-cycle pulse

			// start a new division
			if (start && !busy) begin
				if (divisor == 32'd0) begin
					// divide-by-zero policy (safe for demo):
					quotient  <= 32'd0;
					remainder <= dividend;
					busy <= 1'b0;
					done <= 1'b1;
				end else begin
					A <= 33'd0;
					Q <= dividend;
					M <= {1'b0, divisor};
					count <= 6'd32;
					busy <= 1'b1;
				end
			end

			// run one restoring-division iteration per cycle
			else if (busy) begin
				// 1) shift left (A,Q)
				A_shift = {A[31:0], Q[31]};
				Q_shift = {Q[30:0], 1'b0};

				// 2) subtract divisor
				A_sub = A_shift - M;

				// 3) restore if negative; set Q0
				if (A_sub[32]) begin
					// negative -> restore remainder, Q0=0
					A <= A_shift;
					Q <= {Q_shift[31:1], 1'b0};
				end else begin
					// non-negative -> keep, Q0=1
					A <= A_sub;
					Q <= {Q_shift[31:1], 1'b1};
				end

				count <= count - 6'd1;

				// finish after 32 iterations - use computed values (not Q,A) for correct timing
				if (count == 6'd1) begin
					busy <= 1'b0;
					if (A_sub[32]) begin
						quotient  <= {Q_shift[31:1], 1'b0};
						remainder <= A_shift[31:0];
					end else begin
						quotient  <= {Q_shift[31:1], 1'b1};
						remainder <= A_sub[31:0];
					end
					done <= 1'b1;
				end
			end
		end
	end

endmodule
