`timescale 1ns/10ps

module io_ports_tb;

    reg         clk;
    reg  [31:0] Bus;
    reg  [31:0] InPortData;
    reg         InPortout;
    reg         OutPortin;

    wire [31:0] BusOut;
    wire [31:0] OutPortData;

    io_ports DUT (
        .clk(clk),
        .Bus(Bus),
        .InPortData(InPortData),
        .InPortout(InPortout),
        .OutPortin(OutPortin),
        .BusOut(BusOut),
        .OutPortData(OutPortData)
    );

    // clock generation
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    initial begin
        // initialize
        Bus        = 32'h00000000;
        InPortData = 32'hDEADBEEF;
        InPortout  = 1'b0;
        OutPortin  = 1'b0;

        // test input port driving bus
        #5;
        InPortout = 1'b1;
        #20;
        InPortout = 1'b0;

        // test output port loading from bus
        #5;
        Bus       = 32'hCAFEBABE;
        OutPortin = 1'b1;
        #20;
        OutPortin = 1'b0;

        // test another output load
        #10;
        Bus       = 32'h00000055;
        OutPortin = 1'b1;
        #20;
        OutPortin = 1'b0;

        #20;
        $finish;
    end

endmodule