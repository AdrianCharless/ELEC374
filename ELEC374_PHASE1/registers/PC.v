// Program Counter
module PC (
    input         clear,
    input         clock,
    input         PCin,     // load from bus
    input         IncPC,    // increment by 1 (internal incrementer)
    input  [31:0] BusMuxOut,
    output [31:0] BusMuxInPC
);

    reg [31:0] q;
    initial q = 32'h0;

    always @(posedge clock) begin
        if (clear) begin
            q <= 32'h0;
        end else if (PCin) begin
            q <= BusMuxOut;
        end else if (IncPC) begin
            q <= q + 32'd1;         // allowed here since it's NOT the ALU datapath adder
        end
    end

    assign BusMuxInPC = q;

endmodule