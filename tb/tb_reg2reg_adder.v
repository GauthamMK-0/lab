// ==============================================================================
// Testbench: tb_reg2reg_adder
// Verification for 4-bit Full Adder (2-cycle pipeline)
// ==============================================================================

`timescale 1ns / 1ps

module tb_reg2reg_adder;

    reg        clk;
    reg        rst_n;
    reg  [3:0] a;
    reg  [3:0] b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;

    // Instantiate DUT
    reg2reg_adder dut (
        .clk   (clk),
        .rst_n (rst_n),
        .a     (a),
        .b     (b),
        .cin   (cin),
        .sum   (sum),
        .cout  (cout)
    );

    // 100 MHz Clock (10 ns period)
    always #5 clk = ~clk;

    integer errors;

    initial begin
        clk    = 0;
        rst_n  = 0;
        a      = 4'h0;
        b      = 4'h0;
        cin    = 0;
        errors = 0;

        #15;
        rst_n = 1;
        #10;

        $display("------------------------------------------------------------");
        $display("Starting tb_reg2reg_adder (4-bit Adder) Verification");
        $display("------------------------------------------------------------");

        // Test 1: 3 + 5 + 0 = 8, cout=0
        @(negedge clk);
        a = 4'd3; b = 4'd5; cin = 0;
        @(negedge clk);
        @(negedge clk);
        if (sum !== 4'd8 || cout !== 1'b0) begin
            $display("[ERROR] 3 + 5 failed: sum=%0d cout=%b", sum, cout);
            errors = errors + 1;
        end else begin
            $display("[PASS] 3 + 5 + 0 = %0d (cout=%b)", sum, cout);
        end

        // Test 2: 7 + 8 + 1 = 16 (sum=0, cout=1)
        @(negedge clk);
        a = 4'd7; b = 4'd8; cin = 1;
        @(negedge clk);
        @(negedge clk);
        if (sum !== 4'd0 || cout !== 1'b1) begin
            $display("[ERROR] 7 + 8 + 1 failed: sum=%0d cout=%b", sum, cout);
            errors = errors + 1;
        end else begin
            $display("[PASS] 7 + 8 + 1 = %0d (cout=%b)", sum, cout);
        end

        // Test 3: 15 + 15 + 1 = 31 (sum=15, cout=1)
        @(negedge clk);
        a = 4'd15; b = 4'd15; cin = 1;
        @(negedge clk);
        @(negedge clk);
        if (sum !== 4'd15 || cout !== 1'b1) begin
            $display("[ERROR] 15 + 15 + 1 failed: sum=%0d cout=%b", sum, cout);
            errors = errors + 1;
        end else begin
            $display("[PASS] 15 + 15 + 1 = %0d (cout=%b)", sum, cout);
        end

        $display("------------------------------------------------------------");
        if (errors == 0) begin
            $display("tb_reg2reg_adder PASSED: ALL TESTS SUCCESSFUL (0 errors)");
        end else begin
            $display("tb_reg2reg_adder FAILED with %0d errors", errors);
        end
        $display("------------------------------------------------------------");
        $finish;
    end

endmodule
