// select_encode_tb.v
// Testbench for select_encode module
// Updated with corrected bit ordering (MSB = R0, LSB = R15)

module select_encode_tb;

    // inputs
    reg [31:0] IR;
    reg        Gra, Grb, Grc;
    reg        Rin, Rout, BAout;

    // outputs
    wire [15:0] Rin_out;
    wire [15:0] Rout_out;

    // instantiate module under test
    select_encode uut (
        .IR      (IR),
        .Gra     (Gra),
        .Grb     (Grb),
        .Grc     (Grc),
        .Rin     (Rin),
        .Rout    (Rout),
        .BAout   (BAout),
        .Rin_out (Rin_out),
        .Rout_out(Rout_out)
    );

    initial begin
        $display("===========================================");
        $display("     Select & Encode Testbench");
        $display("===========================================");

        // initialize all signals off
        IR = 32'h0; Gra = 0; Grb = 0; Grc = 0;
        Rin = 0; Rout = 0; BAout = 0;
        #10;

        // -------------------------------------------
        // TEST 1: Gra selects Ra=R7, Rin=1
        // IR[26:23] = 0111 = 7
        // bit ordering: MSB=R0, LSB=R15
        // R7 → bit 8 from MSB → 0000000100000000
        // -------------------------------------------
        IR = 32'b00000_0111_0000_0000_000_00000000000000;
        Gra = 1; Grb = 0; Grc = 0;
        Rin = 1; Rout = 0; BAout = 0;
        #10;
        $display("");
        $display("TEST 1 - Gra selects Ra=R7, Rin=1");
        $display("  IR[26:23]  = %b (R7)", IR[26:23]);
        $display("  Rin_out    = %b", Rin_out);
        $display("  Rout_out   = %b", Rout_out);
        $display("  Expected Rin_out  = 0000000100000000");
        $display("  Expected Rout_out = 0000000000000000");
        if (Rin_out === 16'b0000000100000000 && Rout_out === 16'b0000000000000000)
            $display("  PASS ✓");
        else
            $display("  FAIL ✗");

        // -------------------------------------------
        // TEST 2: Grb selects Rb=R2, Rout=1
        // IR[22:19] = 0010 = 2
        // R2 → bit 3 from MSB → 0010000000000000
        // -------------------------------------------
        IR = 32'b00000_0000_0010_0000_000_00000000000000;
        Gra = 0; Grb = 1; Grc = 0;
        Rin = 0; Rout = 1; BAout = 0;
        #10;
        $display("");
        $display("TEST 2 - Grb selects Rb=R2, Rout=1");
        $display("  IR[22:19]  = %b (R2)", IR[22:19]);
        $display("  Rin_out    = %b", Rin_out);
        $display("  Rout_out   = %b", Rout_out);
        $display("  Expected Rin_out  = 0000000000000000");
        $display("  Expected Rout_out = 0010000000000000");
        if (Rin_out === 16'b0000000000000000 && Rout_out === 16'b0010000000000000)
            $display("  PASS ✓");
        else
            $display("  FAIL ✗");

        // -------------------------------------------
        // TEST 3: Grc selects Rc=R5, Rin=1
        // IR[18:15] = 0101 = 5
        // R5 → bit 6 from MSB → 0000010000000000
        // -------------------------------------------
        IR = 32'b00000_0000_0000_0101_000_00000000000000;
        Gra = 0; Grb = 0; Grc = 1;
        Rin = 1; Rout = 0; BAout = 0;
        #10;
        $display("");
        $display("TEST 3 - Grc selects Rc=R5, Rin=1");
        $display("  IR[18:15]  = %b (R5)", IR[18:15]);
        $display("  Rin_out    = %b", Rin_out);
        $display("  Rout_out   = %b", Rout_out);
        $display("  Expected Rin_out  = 0000010000000000");
        $display("  Expected Rout_out = 0000000000000000");
        if (Rin_out === 16'b0000010000000000 && Rout_out === 16'b0000000000000000)
            $display("  PASS ✓");
        else
            $display("  FAIL ✗");

        // -------------------------------------------
        // TEST 4: BAout with R0 selected (Grb, Rb=R0)
        // IR[22:19] = 0000 = R0
        // R0 → MSB → 1000000000000000
        // -------------------------------------------
        IR = 32'b00000_0000_0000_0000_000_00000000000000;
        Gra = 0; Grb = 1; Grc = 0;
        Rin = 0; Rout = 0; BAout = 1;
        #10;
        $display("");
        $display("TEST 4 - BAout with R0 selected (Grb, Rb=R0)");
        $display("  IR[22:19]  = %b (R0)", IR[22:19]);
        $display("  Rin_out    = %b", Rin_out);
        $display("  Rout_out   = %b", Rout_out);
        $display("  Expected Rin_out  = 0000000000000000");
        $display("  Expected Rout_out = 1000000000000000");
        if (Rin_out === 16'b0000000000000000 && Rout_out === 16'b1000000000000000)
            $display("  PASS ✓");
        else
            $display("  FAIL ✗");

        // -------------------------------------------
        // TEST 5: BAout with R2 selected (Grb, Rb=R2)
        // IR[22:19] = 0010 = R2
        // R2 → 0010000000000000
        // ld R7, 0x72(R2) case from Section 3.1
        // -------------------------------------------
        IR = 32'b00000_0000_0010_0000_000_00000000000000;
        Gra = 0; Grb = 1; Grc = 0;
        Rin = 0; Rout = 0; BAout = 1;
        #10;
        $display("");
        $display("TEST 5 - BAout with R2 selected (ld R7, 0x72(R2))");
        $display("  IR[22:19]  = %b (R2)", IR[22:19]);
        $display("  Rin_out    = %b", Rin_out);
        $display("  Rout_out   = %b", Rout_out);
        $display("  Expected Rin_out  = 0000000000000000");
        $display("  Expected Rout_out = 0010000000000000");
        if (Rin_out === 16'b0000000000000000 && Rout_out === 16'b0010000000000000)
            $display("  PASS ✓");
        else
            $display("  FAIL ✗");

        // -------------------------------------------
        // TEST 6: No Gra/Grb/Grc asserted
        // reg_select defaults to 0000 = R0
        // Rin=1 → Rin_out MSB set → 1000000000000000
        // -------------------------------------------
        IR = 32'hFFFFFFFF;
        Gra = 0; Grb = 0; Grc = 0;
        Rin = 1; Rout = 0; BAout = 0;
        #10;
        $display("");
        $display("TEST 6 - No Gra/Grb/Grc, defaults to R0");
        $display("  Rin_out    = %b", Rin_out);
        $display("  Rout_out   = %b", Rout_out);
        $display("  Expected Rin_out  = 1000000000000000");
        $display("  Expected Rout_out = 0000000000000000");
        if (Rin_out === 16'b1000000000000000 && Rout_out === 16'b0000000000000000)
            $display("  PASS ✓");
        else
            $display("  FAIL ✗");

        // -------------------------------------------
        // TEST 7: Gra selects Ra=R15, Rout=1
        // IR[26:23] = 1111 = 15
        // R15 → LSB → 0000000000000001
        // -------------------------------------------
        IR = 32'b00000_1111_0000_0000_000_00000000000000;
        Gra = 1; Grb = 0; Grc = 0;
        Rin = 0; Rout = 1; BAout = 0;
        #10;
        $display("");
        $display("TEST 7 - Gra selects Ra=R15, Rout=1");
        $display("  IR[26:23]  = %b (R15)", IR[26:23]);
        $display("  Rin_out    = %b", Rin_out);
        $display("  Rout_out   = %b", Rout_out);
        $display("  Expected Rin_out  = 0000000000000000");
        $display("  Expected Rout_out = 0000000000000001");
        if (Rin_out === 16'b0000000000000000 && Rout_out === 16'b0000000000000001)
            $display("  PASS ✓");
        else
            $display("  FAIL ✗");

        $display("");
        $display("===========================================");
        $display("        Testbench Complete");
        $display("===========================================");
        $stop;
    end

endmodule

