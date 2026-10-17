// ==============================================================================
// Testbench: tb_reg2reg_mux
// Verification for 4-to-1 Multiplexer (2-cycle pipeline)
// ==============================================================================

`timescale 1ns / 1ps

module tb_reg2reg_mux;

    reg        clk;
    reg        rst_n;
    reg  [3:0] d;
    reg  [1:0] sel;
    wire       y;

    // Instantiate DUT
    reg2reg_mux dut (
        .clk   (clk),
        .rst_n (rst_n),
        .d     (d),
        .sel   (sel),
        .y     (y)
    );

    // 100 MHz Clock (10 ns period)
    always #5 clk = ~clk;

    integer errors;

    initial begin
        clk    = 0;
        rst_n  = 0;
        d      = 4'b0000;
        sel    = 2'b00;
        errors = 0;

        #15;
        rst_n = 1;
        #10;

        $display("------------------------------------------------------------");
        $display("Starting tb_reg2reg_mux (4-to-1 MUX) Verification");
        $display("------------------------------------------------------------");

        // Channel 0: d = 4'b1010, sel = 00 -> y = d[0] = 0
        @(negedge clk);
        d = 4'b1010; sel = 2'b00;
        @(negedge clk);
        @(negedge clk);
        if (y !== 1'b0) begin
            $display("[ERROR] Channel 0 failed: expected 0, got %b", y);
            errors = errors + 1;
        end else begin
            $display("[PASS] Channel 0: sel=00 selects d[0]=0");
        end

        // Channel 1: d = 4'b1010, sel = 01 -> y = d[1] = 1
        @(negedge clk);
        d = 4'b1010; sel = 2'b01;
        @(negedge clk);
        @(negedge clk);
        if (y !== 1'b1) begin
            $display("[ERROR] Channel 1 failed: expected 1, got %b", y);
            errors = errors + 1;
        end else begin
            $display("[PASS] Channel 1: sel=01 selects d[1]=1");
        end

        // Channel 2: d = 4'b1010, sel = 10 -> y = d[2] = 0
        @(negedge clk);
        d = 4'b1010; sel = 2'b10;
        @(negedge clk);
        @(negedge clk);
        if (y !== 1'b0) begin
            $display("[ERROR] Channel 2 failed: expected 0, got %b", y);
            errors = errors + 1;
        end else begin
            $display("[PASS] Channel 2: sel=10 selects d[2]=0");
        end

        // Channel 3: d = 4'b1010, sel = 11 -> y = d[3] = 1
        @(negedge clk);
        d = 4'b1010; sel = 2'b11;
        @(negedge clk);
        @(negedge clk);
        if (y !== 1'b1) begin
            $display("[ERROR] Channel 3 failed: expected 1, got %b", y);
            errors = errors + 1;
        end else begin
            $display("[PASS] Channel 3: sel=11 selects d[3]=1");
        end

        $display("------------------------------------------------------------");
        if (errors == 0) begin
            $display("tb_reg2reg_mux PASSED: ALL TESTS SUCCESSFUL (0 errors)");
        end else begin
            $display("tb_reg2reg_mux FAILED with %0d errors", errors);
        end
        $display("------------------------------------------------------------");
        $finish;
    end

endmodule
