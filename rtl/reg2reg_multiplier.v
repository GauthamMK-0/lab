// ==============================================================================
// Circuit 1: reg2reg_multiplier (2-bit Register-to-Register Multiplier)
// Architecture:
//   Inputs a[1:0], b[1:0] -> Input DFFs -> Combinational 2x2 Multiplier ->
//   Output DFFs -> p[3:0]
// ==============================================================================

`timescale 1ns / 1ps

module reg2reg_multiplier (
    input  wire       clk,
    input  wire       rst_n,
    // Stage 1 Inputs
    input  wire [1:0] a,
    input  wire [1:0] b,
    // Stage 2 Registered Outputs
    output reg  [3:0] p
);

    // -------------------------------------------------------------------------
    // Stage 1: Input D Flip-Flops
    // -------------------------------------------------------------------------
    reg [1:0] r_a;
    reg [1:0] r_b;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_a <= 2'b00;
            r_b <= 2'b00;
        end else begin
            r_a <= a;
            r_b <= b;
        end
    end

    // -------------------------------------------------------------------------
    // Combinational 2-bit Multiplier Logic Cone
    // -------------------------------------------------------------------------
    wire [3:0] comb_p = r_a * r_b;

    // -------------------------------------------------------------------------
    // Stage 2: Output D Flip-Flops
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p <= 4'b0000;
        end else begin
            p <= comb_p;
        end
    end

endmodule
