module R0_register (
    input         clear,
    input         clock,
    input         R0in,         
    input         BAout,        
    input  [31:0] BusMuxOut,    
    output [31:0] BusMuxIn_R0   
);

    reg [31:0] q;
    initial q = 32'h0;

    always @(posedge clock) begin
        if (clear)
            q <= 32'h0;
        else if (R0in)
            q <= BusMuxOut;
    end

    assign BusMuxIn_R0 = BAout ? 32'h0 : q;

endmodule