// ==============================================================================
// Circuit 2: reg2reg_adder (4-bit Register-to-Register Full Adder)
// Architecture:
//   Inputs a[3:0], b[3:0], cin -> Input DFFs -> Combinational 4-bit Adder ->
//   Output DFFs -> sum[3:0], cout
// ==============================================================================

`timescale 1ns / 1ps

module reg2reg_adder (
    input  wire       clk,
    input  wire       rst_n,
    // Stage 1 Inputs
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       cin,
    // Stage 2 Registered Outputs
    output reg  [3:0] sum,
    output reg        cout
);

    // -------------------------------------------------------------------------
    // Stage 1: Input D Flip-Flops
    // -------------------------------------------------------------------------
    reg [3:0] r_a;
    reg [3:0] r_b;
    reg       r_cin;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_a   <= 4'b0000;
            r_b   <= 4'b0000;
            r_cin <= 1'b0;
        end else begin
            r_a   <= a;
            r_b   <= b;
            r_cin <= cin;
        end
    end

    // -------------------------------------------------------------------------
    // Combinational 4-bit Adder Logic Cone
    // -------------------------------------------------------------------------
    wire [4:0] comb_add = {1'b0, r_a} + {1'b0, r_b} + {4'b0000, r_cin};

    // -------------------------------------------------------------------------
    // Stage 2: Output D Flip-Flops
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum  <= 4'b0000;
            cout <= 1'b0;
        end else begin
            sum  <= comb_add[3:0];
            cout <= comb_add[4];
        end
    end

endmodule
