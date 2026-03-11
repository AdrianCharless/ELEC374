module branch_condition(
    input [31:0] Bus,
    input [1:0] C2,
    output reg condition_result
);

wire zero;
wire nonzero;
wire positive;
wire negative;

assign zero = (Bus == 32'b0);
assign nonzero = ~zero;
assign negative = Bus[31];
assign positive = (~Bus[31]) & (Bus != 0);

always @(*) begin
    case (C2)
        2'b00: condition_result = zero;      // brzr
        2'b01: condition_result = nonzero;   // brnz
        2'b10: condition_result = positive;  // brpl
        2'b11: condition_result = negative;  // brmi
    endcase
end

endmodule