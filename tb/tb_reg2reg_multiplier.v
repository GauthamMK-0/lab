// ==============================================================================
// Testbench: tb_reg2reg_multiplier
// Verification for 2-bit Multiplier (2-cycle pipeline)
// ==============================================================================

`timescale 1ns / 1ps

module tb_reg2reg_multiplier;

    reg        clk;
    reg        rst_n;
    reg  [1:0] a;
    reg  [1:0] b;
    wire [3:0] p;

    // Instantiate DUT
    reg2reg_multiplier dut (
        .clk   (clk),
        .rst_n (rst_n),
        .a     (a),
        .b     (b),
        .p     (p)
    );

    // 100 MHz Clock (10 ns period)
    always #5 clk = ~clk;

    integer errors;
    integer i, j;
    reg [3:0] expected_p;

    initial begin
        clk    = 0;
        rst_n  = 0;
        a      = 2'b00;
        b      = 2'b00;
        errors = 0;

        #15;
        rst_n = 1;
        #10;

        $display("------------------------------------------------------------");
        $display("Starting tb_reg2reg_multiplier (2-bit Multiplier) Verification");
        $display("------------------------------------------------------------");

        // Exhaustive test: all 16 input combinations (4x4)
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                @(negedge clk);
                a = i[1:0];
                b = j[1:0];
                expected_p = i * j;

                // 2-cycle latency (1 cycle for input DFFs, 1 cycle for output DFFs)
                @(negedge clk);
                @(negedge clk);

                if (p !== expected_p) begin
                    $display("[ERROR] %0d * %0d failed: expected %0d, got %0d", i, j, expected_p, p);
                    errors = errors + 1;
                end else begin
                    $display("[PASS] %0d * %0d = %0d", i, j, p);
                end
            end
        end

        $display("------------------------------------------------------------");
        if (errors == 0) begin
            $display("tb_reg2reg_multiplier PASSED: ALL 16 TESTS SUCCESSFUL (0 errors)");
        end else begin
            $display("tb_reg2reg_multiplier FAILED with %0d errors", errors);
        end
        $display("------------------------------------------------------------");
        $finish;
    end

endmodule
