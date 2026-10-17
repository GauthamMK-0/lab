// ==============================================================================
// Testbench: tb_reg2reg_decoder
// Verification for 2-to-4 Decoder with Enable (2-cycle pipeline)
// ==============================================================================

`timescale 1ns / 1ps

module tb_reg2reg_decoder;

    reg        clk;
    reg        rst_n;
    reg  [1:0] in;
    reg        en;
    wire [3:0] out;

    // Instantiate DUT
    reg2reg_decoder dut (
        .clk   (clk),
        .rst_n (rst_n),
        .in    (in),
        .en    (en),
        .out   (out)
    );

    // 100 MHz Clock (10 ns period)
    always #5 clk = ~clk;

    integer errors;

    initial begin
        clk    = 0;
        rst_n  = 0;
        in     = 2'b00;
        en     = 0;
        errors = 0;

        #15;
        rst_n = 1;
        #10;

        $display("------------------------------------------------------------");
        $display("Starting tb_reg2reg_decoder (2-to-4 Decoder) Verification");
        $display("------------------------------------------------------------");

        // Test 1: Disabled (en = 0, in = 2'b11 -> out = 4'b0000)
        @(negedge clk);
        in = 2'b11; en = 0;
        @(negedge clk);
        @(negedge clk);
        if (out !== 4'b0000) begin
            $display("[ERROR] Disabled test failed: expected 0000, got %b", out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Disabled: en=0 -> out=4'b0000");
        end

        // Test 2: Enabled channel 0 (in = 00 -> out = 0001)
        @(negedge clk);
        in = 2'b00; en = 1;
        @(negedge clk);
        @(negedge clk);
        if (out !== 4'b0001) begin
            $display("[ERROR] Channel 0 failed: expected 0001, got %b", out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Channel 0: en=1 in=00 -> out=4'b0001");
        end

        // Test 3: Enabled channel 1 (in = 01 -> out = 0010)
        @(negedge clk);
        in = 2'b01; en = 1;
        @(negedge clk);
        @(negedge clk);
        if (out !== 4'b0010) begin
            $display("[ERROR] Channel 1 failed: expected 0010, got %b", out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Channel 1: en=1 in=01 -> out=4'b0010");
        end

        // Test 4: Enabled channel 2 (in = 10 -> out = 0100)
        @(negedge clk);
        in = 2'b10; en = 1;
        @(negedge clk);
        @(negedge clk);
        if (out !== 4'b0100) begin
            $display("[ERROR] Channel 2 failed: expected 0100, got %b", out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Channel 2: en=1 in=10 -> out=4'b0100");
        end

        // Test 5: Enabled channel 3 (in = 11 -> out = 1000)
        @(negedge clk);
        in = 2'b11; en = 1;
        @(negedge clk);
        @(negedge clk);
        if (out !== 4'b1000) begin
            $display("[ERROR] Channel 3 failed: expected 1000, got %b", out);
            errors = errors + 1;
        end else begin
            $display("[PASS] Channel 3: en=1 in=11 -> out=4'b1000");
        end

        $display("------------------------------------------------------------");
        if (errors == 0) begin
            $display("tb_reg2reg_decoder PASSED: ALL TESTS SUCCESSFUL (0 errors)");
        end else begin
            $display("tb_reg2reg_decoder FAILED with %0d errors", errors);
        end
        $display("------------------------------------------------------------");
        $finish;
    end

endmodule
