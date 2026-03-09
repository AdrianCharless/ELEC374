// sign_extend_tb.v
// Testbench for sign_extend module
// Tests positive, negative, and Cout disabled cases

module sign_extend_tb;

    // inputs driven by testbench
    reg  [18:0] C;
    reg         Cout;

    // output observed
    wire [31:0] C_sign_extended;

    // instantiate the module under test
    sign_extend uut (
        .C                 (C),
        .Cout              (Cout),
        .C_sign_extended   (C_sign_extended)
    );

    initial begin
        $display("===========================================");
        $display("       Sign Extension Testbench");
        $display("===========================================");

        // -------------------------------------------
        // Test 1: Positive number, Cout = 1
        // C[18] = 0, upper 13 bits should be 0
        // ld R7, 0x65 case — C = 0x65
        // -------------------------------------------
        C = 19'h00065; Cout = 1;
        #10;
        $display("TEST 1 - Positive (C=0x65), Cout=1");
        $display("  C        = %b (%h)", C, C);
        $display("  Expected = 0x00000065");
        $display("  Got      = 0x%h", C_sign_extended);
        if (C_sign_extended === 32'h00000065)
            $display("  PASS ✓");
        else
            $display("  FAIL ✗");
        $display("");

        // -------------------------------------------
        // Test 2: Negative number, Cout = 1
        // C[18] = 1, upper 13 bits should all be 1
        // addi R7, R4, -9 case — C = -9 in 19-bit 2's complement
        // -9 in 19 bits = 19'h7FFF7 = 1111111111111110111
        // -------------------------------------------
        C = 19'h7FFF7; Cout = 1;
        #10;
        $display("TEST 2 - Negative (C=-9), Cout=1");
        $display("  C        = %b (%h)", C, C);
        $display("  Expected = 0xFFFFFFF7");
        $display("  Got      = 0x%h", C_sign_extended);
        if (C_sign_extended === 32'hFFFFFFF7)
            $display("  PASS ✓");
        else
            $display("  FAIL ✗");
        $display("");

        // -------------------------------------------
        // Test 3: Cout = 0, output should be high-Z
        // Module should not be driving the bus
        // -------------------------------------------
        C = 19'h00065; Cout = 0;
        #10;
        $display("TEST 3 - Cout=0 (high-Z expected)");
        $display("  C        = %b (%h)", C, C);
        $display("  Expected = 0xzzzzzzzz");
        $display("  Got      = 0x%h", C_sign_extended);
        if (C_sign_extended === 32'hzzzzzzzz)
            $display("  PASS ✓");
        else
            $display("  FAIL ✗");
        $display("");

        // -------------------------------------------
        // Test 4: Boundary — most negative 19-bit value
        // C = 1000000000000000000 (only sign bit set)
        // Expected: 0xFFFC0000
        // -------------------------------------------
        C = 19'h40000; Cout = 1;
        #10;
        $display("TEST 4 - Most negative 19-bit value");
        $display("  C        = %b (%h)", C, C);
        $display("  Expected = 0xFFFC0000");
        $display("  Got      = 0x%h", C_sign_extended);
        if (C_sign_extended === 32'hFFFC0000)
            $display("  PASS ✓");
        else
            $display("  FAIL ✗");
        $display("");

        // -------------------------------------------
        // Test 5: Boundary — most positive 19-bit value
        // C = 0111111111111111111
        // Expected: 0x0003FFFF
        // -------------------------------------------
        C = 19'h3FFFF; Cout = 1;
        #10;
        $display("TEST 5 - Most positive 19-bit value");
        $display("  C        = %b (%h)", C, C);
        $display("  Expected = 0x0003FFFF");
        $display("  Got      = 0x%h", C_sign_extended);
        if (C_sign_extended === 32'h0003FFFF)
            $display("  PASS ✓");
        else
            $display("  FAIL ✗");
        $display("");

        // -------------------------------------------
        // Test 6: C = 0 (zero)
        // Expected: 0x00000000
        // -------------------------------------------
        C = 19'h00000; Cout = 1;
        #10;
        $display("TEST 6 - Zero value");
        $display("  C        = %b (%h)", C, C);
        $display("  Expected = 0x00000000");
        $display("  Got      = 0x%h", C_sign_extended);
        if (C_sign_extended === 32'h00000000)
            $display("  PASS ✓");
        else
            $display("  FAIL ✗");
        $display("");

        $display("===========================================");
        $display("         Testbench Complete");
        $display("===========================================");
        $stop;
    end

endmodule
