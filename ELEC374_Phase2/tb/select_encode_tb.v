module select_encode_tb;

    reg [31:0] IR;
    reg        Gra, Grb, Grc;
    reg        Rin, Rout, BAout;

    wire [15:0] Rin_out;
    wire [15:0] Rout_out;

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

        IR = 32'h0; Gra = 0; Grb = 0; Grc = 0;
        Rin = 0; Rout = 0; BAout = 0;
        #10;

        // TEST 1: Gra, Ra=R7, Rin=1
        // IR[26:23]=0111=R7 → 0x03800000
        IR = 32'h03800000;
        Gra = 1; Grb = 0; Grc = 0;
        Rin = 1; Rout = 0; BAout = 0;
        #10;
        $display("\nTEST 1 - Gra selects Ra=R7, Rin=1");
        $display("  IR[26:23]  = %b (R7)", IR[26:23]);
        $display("  Rin_out    = %b", Rin_out);
        $display("  Rout_out   = %b", Rout_out);
        $display("  Expected Rin_out  = 0000000100000000");
        $display("  Expected Rout_out = 0000000000000000");
        if (Rin_out === 16'b0000000100000000 && Rout_out === 16'b0000000000000000)
            $display("  PASS");
        else
            $display("  FAIL");

        // TEST 2: Grb, Rb=R2, Rout=1
        // IR[22:19]=0010=R2 → 0x00100000
        IR = 32'h00100000;
        Gra = 0; Grb = 1; Grc = 0;
        Rin = 0; Rout = 1; BAout = 0;
        #10;
        $display("\nTEST 2 - Grb selects Rb=R2, Rout=1");
        $display("  IR[22:19]  = %b (R2)", IR[22:19]);
        $display("  Rin_out    = %b", Rin_out);
        $display("  Rout_out   = %b", Rout_out);
        $display("  Expected Rin_out  = 0000000000000000");
        $display("  Expected Rout_out = 0010000000000000");
        if (Rin_out === 16'b0000000000000000 && Rout_out === 16'b0010000000000000)
            $display("  PASS");
        else
            $display("  FAIL");

        // TEST 3: Grc, Rc=R5, Rin=1
        // IR[18:15]=0101=R5 → 0x00028000
        IR = 32'h00028000;
        Gra = 0; Grb = 0; Grc = 1;
        Rin = 1; Rout = 0; BAout = 0;
        #10;
        $display("\nTEST 3 - Grc selects Rc=R5, Rin=1");
        $display("  IR[18:15]  = %b (R5)", IR[18:15]);
        $display("  Rin_out    = %b", Rin_out);
        $display("  Rout_out   = %b", Rout_out);
        $display("  Expected Rin_out  = 0000010000000000");
        $display("  Expected Rout_out = 0000000000000000");
        if (Rin_out === 16'b0000010000000000 && Rout_out === 16'b0000000000000000)
            $display("  PASS");
        else
            $display("  FAIL");

        // TEST 4: BAout, Rb=R0
        IR = 32'h00000000;
        Gra = 0; Grb = 1; Grc = 0;
        Rin = 0; Rout = 0; BAout = 1;
        #10;
        $display("\nTEST 4 - BAout with R0 selected");
        $display("  IR[22:19]  = %b (R0)", IR[22:19]);
        $display("  Rin_out    = %b", Rin_out);
        $display("  Rout_out   = %b", Rout_out);
        $display("  Expected Rin_out  = 0000000000000000");
        $display("  Expected Rout_out = 1000000000000000");
        if (Rin_out === 16'b0000000000000000 && Rout_out === 16'b1000000000000000)
            $display("  PASS");
        else
            $display("  FAIL");

        // TEST 5: BAout, Rb=R2
        // IR[22:19]=0010=R2 → 0x00100000
        IR = 32'h00100000;
        Gra = 0; Grb = 1; Grc = 0;
        Rin = 0; Rout = 0; BAout = 1;
        #10;
        $display("\nTEST 5 - BAout with R2 selected");
        $display("  IR[22:19]  = %b (R2)", IR[22:19]);
        $display("  Rin_out    = %b", Rin_out);
        $display("  Rout_out   = %b", Rout_out);
        $display("  Expected Rin_out  = 0000000000000000");
        $display("  Expected Rout_out = 0010000000000000");
        if (Rin_out === 16'b0000000000000000 && Rout_out === 16'b0010000000000000)
            $display("  PASS");
        else
            $display("  FAIL");

        // TEST 6: No G signals, default R0
        IR = 32'hFFFFFFFF;
        Gra = 0; Grb = 0; Grc = 0;
        Rin = 1; Rout = 0; BAout = 0;
        #10;
        $display("\nTEST 6 - No Gra/Grb/Grc, defaults to R0");
        $display("  Rin_out    = %b", Rin_out);
        $display("  Rout_out   = %b", Rout_out);
        $display("  Expected Rin_out  = 1000000000000000");
        $display("  Expected Rout_out = 0000000000000000");
        if (Rin_out === 16'b1000000000000000 && Rout_out === 16'b0000000000000000)
            $display("  PASS");
        else
            $display("  FAIL");

        // TEST 7: Gra, Ra=R15, Rout=1
        // IR[26:23]=1111=R15 → 0x07800000
        IR = 32'h07800000;
        Gra = 1; Grb = 0; Grc = 0;
        Rin = 0; Rout = 1; BAout = 0;
        #10;
        $display("\nTEST 7 - Gra selects Ra=R15, Rout=1");
        $display("  IR[26:23]  = %b (R15)", IR[26:23]);
        $display("  Rin_out    = %b", Rin_out);
        $display("  Rout_out   = %b", Rout_out);
        $display("  Expected Rin_out  = 0000000000000000");
        $display("  Expected Rout_out = 0000000000000001");
        if (Rin_out === 16'b0000000000000000 && Rout_out === 16'b0000000000000001)
            $display("  PASS");
        else
            $display("  FAIL");

        $display("\n===========================================");
        $display("        Testbench Complete");
        $display("===========================================");
        $stop;
    end

endmodule

