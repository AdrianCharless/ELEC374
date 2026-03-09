// 512 x 32 RAM
// asynchronous read, read is combinational (rdata reflects mem[addr] when read_en=1)
// synchronous write, write happens on posedge clk when write_en=1
// clear signal input is included for interface compatibilit but does not clear RAM contents
module RAM (
    input        clk,
    input        clear,
    input        read_en,
    input        write_en,
    input  [8:0] addr,
    input  [31:0] wdata,
    output [31:0] rdata
);

    reg [31:0] mem [0:511];

    // synchronous write
    always @(posedge clk) begin
        if (write_en) begin
            mem[addr] <= wdata;
        end
    end

    // asynchronous read (gated)
    assign rdata = (read_en) ? mem[addr] : 32'b0;

endmodule