module AND (
    input  [31:0] A,
    input  [31:0] B,
    output reg [31:0] out
);
    integer i;
    always @(*) begin
        for (i = 0; i <= 31; i = i + 1)
            out[i] = A[i] & B[i];
    end
endmodule



