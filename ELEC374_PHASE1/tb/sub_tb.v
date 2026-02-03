// ============================================================================
// Subtraction Testbench
// Tests the sub module (A - B) with various test cases
// ============================================================================

`timescale 1ns/10ps

module sub_tb;

    // Testbench signals
    reg [31:0] A;
    reg [31:0] B;
    wire [31:0] Result;
    
    // Test counter
    integer test_num;
    integer errors;

    // Instantiate the sub module
    sub dut (
        .A(A),
        .B(B),
        .Result(Result)
    );

    // Test procedure
    initial begin
        // Initialize
        test_num = 0;
        errors = 0;
        
        $display("========================================");
        $display("Subtraction Test Bench");
        $display("========================================");
        
        // Test 1: Simple subtraction (5 - 3 = 2)
        test_num = test_num + 1;
        A = 32'd5;
        B = 32'd3;
        #10;
        if (Result !== 32'd2) begin
            $display("ERROR Test %0d: 5 - 3 failed", test_num);
            $display("  A: %0d, B: %0d, Expected: 2, Got: %0d", 
                     $signed(A), $signed(B), $signed(Result));
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: 5 - 3 = 2", test_num);
        end
        
        // Test 2: Subtract zero (10 - 0 = 10)
        test_num = test_num + 1;
        A = 32'd10;
        B = 32'd0;
        #10;
        if (Result !== 32'd10) begin
            $display("ERROR Test %0d: 10 - 0 failed", test_num);
            $display("  A: %0d, B: %0d, Expected: 10, Got: %0d", 
                     $signed(A), $signed(B), $signed(Result));
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: 10 - 0 = 10", test_num);
        end
        
        // Test 3: Subtract from zero (0 - 5 = -5)
        test_num = test_num + 1;
        A = 32'd0;
        B = 32'd5;
        #10;
        if ($signed(Result) !== -5) begin
            $display("ERROR Test %0d: 0 - 5 failed", test_num);
            $display("  A: %0d, B: %0d, Expected: -5, Got: %0d", 
                     $signed(A), $signed(B), $signed(Result));
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: 0 - 5 = -5", test_num);
        end
        
        // Test 4: Result is zero (7 - 7 = 0)
        test_num = test_num + 1;
        A = 32'd7;
        B = 32'd7;
        #10;
        if (Result !== 32'd0) begin
            $display("ERROR Test %0d: 7 - 7 failed", test_num);
            $display("  A: %0d, B: %0d, Expected: 0, Got: %0d", 
                     $signed(A), $signed(B), $signed(Result));
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: 7 - 7 = 0", test_num);
        end
        
        // Test 5: Large positive numbers (1000 - 250 = 750)
        test_num = test_num + 1;
        A = 32'd1000;
        B = 32'd250;
        #10;
        if (Result !== 32'd750) begin
            $display("ERROR Test %0d: 1000 - 250 failed", test_num);
            $display("  A: %0d, B: %0d, Expected: 750, Got: %0d", 
                     $signed(A), $signed(B), $signed(Result));
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: 1000 - 250 = 750", test_num);
        end
        
        // Test 6: Negative result (100 - 200 = -100)
        test_num = test_num + 1;
        A = 32'd100;
        B = 32'd200;
        #10;
        if ($signed(Result) !== -100) begin
            $display("ERROR Test %0d: 100 - 200 failed", test_num);
            $display("  A: %0d, B: %0d, Expected: -100, Got: %0d", 
                     $signed(A), $signed(B), $signed(Result));
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: 100 - 200 = -100", test_num);
        end
        
        // Test 7: Positive minus negative (10 - (-5) = 15)
        test_num = test_num + 1;
        A = 32'd10;
        B = -32'd5;
        #10;
        if (Result !== 32'd15) begin
            $display("ERROR Test %0d: 10 - (-5) failed", test_num);
            $display("  A: %0d, B: %0d, Expected: 15, Got: %0d", 
                     $signed(A), $signed(B), $signed(Result));
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: 10 - (-5) = 15", test_num);
        end
        
        // Test 8: Negative minus positive (-10 - 5 = -15)
        test_num = test_num + 1;
        A = -32'd10;
        B = 32'd5;
        #10;
        if ($signed(Result) !== -15) begin
            $display("ERROR Test %0d: -10 - 5 failed", test_num);
            $display("  A: %0d, B: %0d, Expected: -15, Got: %0d", 
                     $signed(A), $signed(B), $signed(Result));
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: -10 - 5 = -15", test_num);
        end
        
        // Test 9: Negative minus negative (-10 - (-3) = -7)
        test_num = test_num + 1;
        A = -32'd10;
        B = -32'd3;
        #10;
        if ($signed(Result) !== -7) begin
            $display("ERROR Test %0d: -10 - (-3) failed", test_num);
            $display("  A: %0d, B: %0d, Expected: -7, Got: %0d", 
                     $signed(A), $signed(B), $signed(Result));
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: -10 - (-3) = -7", test_num);
        end
        
        // Test 10: Maximum positive value operations
        test_num = test_num + 1;
        A = 32'h7FFFFFFF; // 2147483647
        B = 32'd1;
        #10;
        if (Result !== 32'h7FFFFFFE) begin
            $display("ERROR Test %0d: Max - 1 failed", test_num);
            $display("  A: %0d (0x%h), B: %0d, Expected: 2147483646, Got: %0d (0x%h)", 
                     $signed(A), A, $signed(B), $signed(Result), Result);
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: 2147483647 - 1 = 2147483646", test_num);
        end
        
        // Test 11: Hex pattern subtraction
        test_num = test_num + 1;
        A = 32'h12345678;
        B = 32'h11111111;
        #10;
        if (Result !== 32'h01234567) begin
            $display("ERROR Test %0d: Hex pattern subtraction failed", test_num);
            $display("  A: 0x%h, B: 0x%h, Expected: 0x01234567, Got: 0x%h", 
                     A, B, Result);
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: 0x12345678 - 0x11111111 = 0x01234567", test_num);
        end
        
        // Test 12: Large numbers
        test_num = test_num + 1;
        A = 32'd1000000;
        B = 32'd500000;
        #10;
        if (Result !== 32'd500000) begin
            $display("ERROR Test %0d: 1000000 - 500000 failed", test_num);
            $display("  A: %0d, B: %0d, Expected: 500000, Got: %0d", 
                     $signed(A), $signed(B), $signed(Result));
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: 1000000 - 500000 = 500000", test_num);
        end
        
        // Test 13: Overflow case (positive - negative = large positive)
        test_num = test_num + 1;
        A = 32'h7FFFFFFF; // Max positive
        B = -32'd1;       // -1
        #10;
        // This will overflow in signed arithmetic, but the hardware result is defined
        $display("INFO Test %0d: Overflow case - 0x7FFFFFFF - (-1)", test_num);
        $display("  A: %0d (0x%h), B: %0d (0x%h), Got: %0d (0x%h)", 
                 $signed(A), A, $signed(B), B, $signed(Result), Result);
        $display("  Note: This causes signed overflow (wraps to negative)");
        test_num = test_num + 1;
        
        // Test 14: All ones minus all ones
        test_num = test_num + 1;
        A = 32'hFFFFFFFF;
        B = 32'hFFFFFFFF;
        #10;
        if (Result !== 32'd0) begin
            $display("ERROR Test %0d: 0xFFFFFFFF - 0xFFFFFFFF failed", test_num);
            $display("  A: 0x%h, B: 0x%h, Expected: 0, Got: 0x%h", 
                     A, B, Result);
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: 0xFFFFFFFF - 0xFFFFFFFF = 0", test_num);
        end
        
        // Test 15: Pattern test
        test_num = test_num + 1;
        A = 32'hDEADBEEF;
        B = 32'hBEEFDEAD;
        #10;
        if (Result !== 32'h1FBDE042) begin
            $display("ERROR Test %0d: Pattern subtraction failed", test_num);
            $display("  A: 0x%h, B: 0x%h, Expected: 0x1FBDE042, Got: 0x%h", 
                     A, B, Result);
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: 0xDEADBEEF - 0xBEEFDEAD = 0x1FBDE042", test_num);
        end
        
        // Test 16: Simple test (52 - 18 = 34)
        test_num = test_num + 1;
        A = 32'd52;
        B = 32'd18;
        #10;
        if (Result !== 32'd34) begin
            $display("ERROR Test %0d: 52 - 18 failed", test_num);
            $display("  A: %0d, B: %0d, Expected: 34, Got: %0d", 
                     $signed(A), $signed(B), $signed(Result));
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: 52 - 18 = 34", test_num);
        end
        
        // Print summary
        $display("========================================");
        if (errors == 0) begin
            $display("ALL TESTS PASSED! (%0d/%0d)", test_num, test_num);
        end else begin
            $display("TESTS COMPLETED: %0d PASSED, %0d FAILED", test_num - errors, errors);
        end
        $display("========================================");
        
        $finish;
    end

endmodule
