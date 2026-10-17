// ==============================================================================
// Circuit 4: reg2reg_mux (4-to-1 Register-to-Register Multiplexer)
// Architecture:
//   Inputs d[3:0], sel[1:0] -> Input DFFs -> Combinational 4:1 MUX ->
//   Output DFF -> y
// ==============================================================================

`timescale 1ns / 1ps

module reg2reg_mux (
    input  wire       clk,
    input  wire       rst_n,
    // Stage 1 Inputs
    input  wire [3:0] d,
    input  wire [1:0] sel,
    // Stage 2 Registered Output
    output reg        y
);

    // -------------------------------------------------------------------------
    // Stage 1: Input D Flip-Flops
    // -------------------------------------------------------------------------
    reg [3:0] r_d;
    reg [1:0] r_sel;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_d   <= 4'b0000;
            r_sel <= 2'b00;
        end else begin
            r_d   <= d;
            r_sel <= sel;
        end
    end

    // -------------------------------------------------------------------------
    // Combinational 4-to-1 Multiplexer Logic Cone
    // -------------------------------------------------------------------------
    reg comb_y;

    always @(*) begin
        case (r_sel)
            2'b00: comb_y = r_d[0];
            2'b01: comb_y = r_d[1];
            2'b10: comb_y = r_d[2];
            2'b11: comb_y = r_d[3];
            default: comb_y = 1'b0;
        endcase
    end

    // -------------------------------------------------------------------------
    // Stage 2: Output D Flip-Flop
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            y <= 1'b0;
        end else begin
            y <= comb_y;
        end
    end

endmodule
