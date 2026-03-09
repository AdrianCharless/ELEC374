// io_ports.v

module io_ports(

    input clk,

    input [31:0] Bus,
    input [31:0] InPortData,

    input InPortout,
    input OutPortin,

    output [31:0] BusOut,
    output reg [31:0] OutPortData

);

assign BusOut =
        InPortout ? InPortData :
        32'hz;

always @(posedge clk)
begin
    if (OutPortin)
        OutPortData <= Bus;
end

endmodule
