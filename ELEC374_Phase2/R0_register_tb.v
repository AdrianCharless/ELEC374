// R0_register_tb.v
// Testbench for R0_register
// Tests: load, clear, BAout gating

module R0_register_tb;

    reg        clear;
    reg        clock;
    reg        R0in;
    reg        BAout;
    reg [31:0] BusMuxOut;

    wire [31:0] BusMuxIn_R0;

    R0_register uut (
        .clear       (clear),
        .clock       (clock),
        .R0in        (R0in),
        .BAout       (BAout),
        .BusMuxOut   (BusMuxOut),
        .BusMuxIn_R0 (BusMuxIn_R0)
    );

    // clock 10ns period
    initial clock = 0;
    always #5 clock = ~clock;

    initial begin
        $display("R0 Register Testbench");

        // init
        clear = 0; R0in = 0; BAout = 0;
        BusMuxOut = 32'h0;
        #10;

        // TEST 1: clear works
        BusMuxOut = 32'hDEADBEEF;
        R0in = 1;
        @(posedge clock); #1;
        R0in = 0;
        clear = 1;
        @(posedge clock); #1;
        clear = 0;
        #5;
        $display("\nTEST 1 - clear");
        $display("  got=%h expected=00000000", BusMuxIn_R0);
        if (BusMuxIn_R0 === 32'h00000000)
            $display("  PASS");
        else
            $display("  FAIL");

        // TEST 2: normal load, BAout=0
        BusMuxOut = 32'h00000063;
        R0in = 1;
        @(posedge clock); #1;
        R0in = 0;
        #5;
        $display("\nTEST 2 - normal load BAout=0");
        $display("  got=%h expected=00000063", BusMuxIn_R0);
        if (BusMuxIn_R0 === 32'h00000063)
            $display("  PASS");
        else
            $display("  FAIL");

        // TEST 3: BAout=1 should gate 0s even though R0=0x63
        BAout = 1;
        #5;
        $display("\nTEST 3 - BAout=1 gates 0s");
        $display("  got=%h expected=00000000", BusMuxIn_R0);
        if (BusMuxIn_R0 === 32'h00000000)
            $display("  PASS");
        else
            $display("  FAIL");

        // TEST 4: BAout back to 0, should see R0 contents again
        BAout = 0;
        #5;
        $display("\nTEST 4 - BAout=0 normal output restored");
        $display("  got=%h expected=00000063", BusMuxIn_R0);
        if (BusMuxIn_R0 === 32'h00000063)
            $display("  PASS");
        else
            $display("  FAIL");

        // TEST 5: R0in=0, loading shouldnt change anything
        BusMuxOut = 32'hFFFFFFFF;
        R0in = 0;
        @(posedge clock); #1;
        #5;
        $display("\nTEST 5 - R0in=0 no load");
        $display("  got=%h expected=00000063", BusMuxIn_R0);
        if (BusMuxIn_R0 === 32'h00000063)
            $display("  PASS");
        else
            $display("  FAIL");

        // TEST 6: load new value then check BAout still works
        BusMuxOut = 32'h00000057;
        R0in = 1;
        @(posedge clock); #1;
        R0in = 0;
        BAout = 1;
        #5;
        $display("\nTEST 6 - new value, BAout=1 still gates 0s");
        $display("  got=%h expected=00000000", BusMuxIn_R0);
        if (BusMuxIn_R0 === 32'h00000000)
            $display("  PASS");
        else
            $display("  FAIL");

        $display("\nDone");
        $stop;
    end

endmodule