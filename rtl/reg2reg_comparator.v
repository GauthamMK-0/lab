// ==============================================================================
// Circuit 3: reg2reg_comparator (4-bit Register-to-Register Magnitude Comparator)
// Architecture:
//   Inputs a[3:0], b[3:0] -> Input DFFs -> Combinational Comparator ->
//   Output DFFs -> eq, gt, lt
// ==============================================================================

`timescale 1ns / 1ps

module reg2reg_comparator (
    input  wire       clk,
    input  wire       rst_n,
    // Stage 1 Inputs
    input  wire [3:0] a,
    input  wire [3:0] b,
    // Stage 2 Registered Outputs
    output reg        eq,
    output reg        gt,
    output reg        lt
);

    // -------------------------------------------------------------------------
    // Stage 1: Input D Flip-Flops
    // -------------------------------------------------------------------------
    reg [3:0] r_a;
    reg [3:0] r_b;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_a <= 4'b0000;
            r_b <= 4'b0000;
        end else begin
            r_a <= a;
            r_b <= b;
        end
    end

    // -------------------------------------------------------------------------
    // Combinational Comparator Logic Cone
    // -------------------------------------------------------------------------
    wire comb_eq = (r_a == r_b);
    wire comb_gt = (r_a > r_b);
    wire comb_lt = (r_a < r_b);

    // -------------------------------------------------------------------------
    // Stage 2: Output D Flip-Flops
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            eq <= 1'b0;
            gt <= 1'b0;
            lt <= 1'b0;
        end else begin
            eq <= comb_eq;
            gt <= comb_gt;
            lt <= comb_lt;
        end
    end

endmodule
