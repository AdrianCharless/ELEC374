// ============================================================================
// Negate (Two's Complement) Testbench
// Tests the negate module with various test cases
// ============================================================================

`timescale 1ns/10ps

module negate_tb;

    // Testbench signals
    reg [31:0] A;
    wire [31:0] Result;
    
    // Test counter
    integer test_num;
    integer errors;

    // Instantiate the negate module
    negate dut (
        .A(A),
        .Result(Result)
    );

    // Test procedure
    initial begin
        // Initialize
        test_num = 0;
        errors = 0;
        
        $display("========================================");
        $display("Negate Test Bench");
        $display("========================================");
        
        // Test 1: Negate zero
        test_num = test_num + 1;
        A = 32'd0;
        #10;
        if (Result !== 32'd0) begin
            $display("ERROR Test %0d: Negate zero failed", test_num);
            $display("  Input: %0d (0x%h), Expected: %0d (0x%h), Got: %0d (0x%h)", 
                     $signed(A), A, 0, 32'd0, $signed(Result), Result);
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: Negate 0 = 0", test_num);
        end
        
        // Test 2: Negate positive number (1)
        test_num = test_num + 1;
        A = 32'd1;
        #10;
        if (Result !== 32'hFFFFFFFF) begin // -1 in two's complement
            $display("ERROR Test %0d: Negate 1 failed", test_num);
            $display("  Input: %0d (0x%h), Expected: -1 (0x%h), Got: %0d (0x%h)", 
                     $signed(A), A, 32'hFFFFFFFF, $signed(Result), Result);
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: Negate 1 = -1", test_num);
        end
        
        // Test 3: Negate negative number (-1)
        test_num = test_num + 1;
        A = 32'hFFFFFFFF; // -1
        #10;
        if (Result !== 32'd1) begin
            $display("ERROR Test %0d: Negate -1 failed", test_num);
            $display("  Input: %0d (0x%h), Expected: 1 (0x%h), Got: %0d (0x%h)", 
                     $signed(A), A, 32'd1, $signed(Result), Result);
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: Negate -1 = 1", test_num);
        end
        
        // Test 4: Negate positive number (42)
        test_num = test_num + 1;
        A = 32'd42;
        #10;
        if ($signed(Result) !== -42) begin
            $display("ERROR Test %0d: Negate 42 failed", test_num);
            $display("  Input: %0d (0x%h), Expected: -42 (0x%h), Got: %0d (0x%h)", 
                     $signed(A), A, -42, $signed(Result), Result);
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: Negate 42 = -42", test_num);
        end
        
        // Test 5: Negate negative number (-42)
        test_num = test_num + 1;
        A = -32'd42;
        #10;
        if (Result !== 32'd42) begin
            $display("ERROR Test %0d: Negate -42 failed", test_num);
            $display("  Input: %0d (0x%h), Expected: 42 (0x%h), Got: %0d (0x%h)", 
                     $signed(A), A, 32'd42, $signed(Result), Result);
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: Negate -42 = 42", test_num);
        end
        
        // Test 6: Negate large positive number
        test_num = test_num + 1;
        A = 32'd1000000;
        #10;
        if ($signed(Result) !== -1000000) begin
            $display("ERROR Test %0d: Negate 1000000 failed", test_num);
            $display("  Input: %0d (0x%h), Expected: -1000000 (0x%h), Got: %0d (0x%h)", 
                     $signed(A), A, -1000000, $signed(Result), Result);
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: Negate 1000000 = -1000000", test_num);
        end
        
        // Test 7: Negate large negative number
        test_num = test_num + 1;
        A = -32'd1000000;
        #10;
        if (Result !== 32'd1000000) begin
            $display("ERROR Test %0d: Negate -1000000 failed", test_num);
            $display("  Input: %0d (0x%h), Expected: 1000000 (0x%h), Got: %0d (0x%h)", 
                     $signed(A), A, 32'd1000000, $signed(Result), Result);
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: Negate -1000000 = 1000000", test_num);
        end
        
        // Test 8: Negate maximum positive value (2^31 - 1)
        test_num = test_num + 1;
        A = 32'h7FFFFFFF; // 2147483647
        #10;
        if (Result !== 32'h80000001) begin // -2147483647
            $display("ERROR Test %0d: Negate max positive failed", test_num);
            $display("  Input: %0d (0x%h), Expected: %0d (0x%h), Got: %0d (0x%h)", 
                     $signed(A), A, $signed(32'h80000001), 32'h80000001, 
                     $signed(Result), Result);
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: Negate 2147483647 = -2147483647", test_num);
        end
        
        // Test 9: Negate minimum value (special case: -2^31)
        // Note: Negating -2147483648 should give -2147483648 (overflow condition)
        test_num = test_num + 1;
        A = 32'h80000000; // -2147483648
        #10;
        if (Result !== 32'h80000000) begin
            $display("ERROR Test %0d: Negate min value failed", test_num);
            $display("  Input: %0d (0x%h), Expected: %0d (0x%h), Got: %0d (0x%h)", 
                     $signed(A), A, $signed(32'h80000000), 32'h80000000, 
                     $signed(Result), Result);
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: Negate -2147483648 = -2147483648 (overflow)", test_num);
        end
        
        // Test 10: Negate pattern 0xAAAAAAAA
        test_num = test_num + 1;
        A = 32'hAAAAAAAA;
        #10;
        if (Result !== 32'h55555556) begin
            $display("ERROR Test %0d: Negate 0xAAAAAAAA failed", test_num);
            $display("  Input: 0x%h, Expected: 0x%h, Got: 0x%h", 
                     A, 32'h55555556, Result);
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: Negate 0xAAAAAAAA = 0x55555556", test_num);
        end
        
        // Test 11: Negate pattern 0x12345678
        test_num = test_num + 1;
        A = 32'h12345678;
        #10;
        if (Result !== 32'hEDCBA988) begin
            $display("ERROR Test %0d: Negate 0x12345678 failed", test_num);
            $display("  Input: 0x%h, Expected: 0x%h, Got: 0x%h", 
                     A, 32'hEDCBA988, Result);
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: Negate 0x12345678 = 0xEDCBA988", test_num);
        end
        
        // Test 12: Double negation should return original
        test_num = test_num + 1;
        A = 32'd12345;
        #10;
        if ($signed(Result) !== -12345) begin
            $display("ERROR Test %0d: First negation of 12345 failed", test_num);
            errors = errors + 1;
        end
        // Apply negation result back to input
        A = Result;
        #10;
        if (Result !== 32'd12345) begin
            $display("ERROR Test %0d: Double negation failed", test_num);
            $display("  Original: 12345, After double negate: %0d", $signed(Result));
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: Double negation returns original", test_num);
        end
        
        // Test 13: Negate 100
        test_num = test_num + 1;
        A = 32'd100;
        #10;
        if ($signed(Result) !== -100) begin
            $display("ERROR Test %0d: Negate 100 failed", test_num);
            $display("  Input: %0d, Expected: -100, Got: %0d", $signed(A), $signed(Result));
            errors = errors + 1;
        end else begin
            $display("PASS Test %0d: Negate 100 = -100", test_num);
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
