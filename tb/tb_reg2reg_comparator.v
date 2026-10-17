// ==============================================================================
// Testbench: tb_reg2reg_comparator
// Verification for 4-bit Magnitude Comparator (2-cycle pipeline)
// ==============================================================================

`timescale 1ns / 1ps

module tb_reg2reg_comparator;

    reg        clk;
    reg        rst_n;
    reg  [3:0] a;
    reg  [3:0] b;
    wire       eq;
    wire       gt;
    wire       lt;

    // Instantiate DUT
    reg2reg_comparator dut (
        .clk   (clk),
        .rst_n (rst_n),
        .a     (a),
        .b     (b),
        .eq    (eq),
        .gt    (gt),
        .lt    (lt)
    );

    // 100 MHz Clock (10 ns period)
    always #5 clk = ~clk;

    integer errors;

    initial begin
        clk    = 0;
        rst_n  = 0;
        a      = 4'h0;
        b      = 4'h0;
        errors = 0;

        #15;
        rst_n = 1;
        #10;

        $display("------------------------------------------------------------");
        $display("Starting tb_reg2reg_comparator (4-bit) Verification");
        $display("------------------------------------------------------------");

        // Test 1: Equal (a = 7, b = 7)
        @(negedge clk);
        a = 4'd7; b = 4'd7;
        @(negedge clk);
        @(negedge clk);
        if (eq !== 1'b1 || gt !== 1'b0 || lt !== 1'b0) begin
            $display("[ERROR] Equal failed: eq=%b gt=%b lt=%b", eq, gt, lt);
            errors = errors + 1;
        end else begin
            $display("[PASS] 7 == 7 (eq=1, gt=0, lt=0)");
        end

        // Test 2: Greater Than (a = 12, b = 4)
        @(negedge clk);
        a = 4'd12; b = 4'd4;
        @(negedge clk);
        @(negedge clk);
        if (eq !== 1'b0 || gt !== 1'b1 || lt !== 1'b0) begin
            $display("[ERROR] Greater failed: eq=%b gt=%b lt=%b", eq, gt, lt);
            errors = errors + 1;
        end else begin
            $display("[PASS] 12 > 4 (eq=0, gt=1, lt=0)");
        end

        // Test 3: Less Than (a = 2, b = 14)
        @(negedge clk);
        a = 4'd2; b = 4'd14;
        @(negedge clk);
        @(negedge clk);
        if (eq !== 1'b0 || gt !== 1'b0 || lt !== 1'b1) begin
            $display("[ERROR] Less failed: eq=%b gt=%b lt=%b", eq, gt, lt);
            errors = errors + 1;
        end else begin
            $display("[PASS] 2 < 14 (eq=0, gt=0, lt=1)");
        end

        $display("------------------------------------------------------------");
        if (errors == 0) begin
            $display("tb_reg2reg_comparator PASSED: ALL TESTS SUCCESSFUL (0 errors)");
        end else begin
            $display("tb_reg2reg_comparator FAILED with %0d errors", errors);
        end
        $display("------------------------------------------------------------");
        $finish;
    end

endmodule
