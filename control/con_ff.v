module con_ff(
    input  wire        clear,
    input  wire        clock,
    input  wire        CONin,
    input  wire [31:0] BusMuxOut,
    input  wire [3:0]  IR_C2,
    output reg         CON
);

    wire condition_result;

    // instantiate the combinational condition logic
    branch_condition BC (
        .value(BusMuxOut),
        .condition(IR_C2[1:0]),
        .result(condition_result)
    );

    // the actual CON flip-flop
    always @(posedge clock or posedge clear) begin
        if (clear)
            CON <= 1'b0;
        else if (CONin)
            CON <= condition_result;
    end

endmodule