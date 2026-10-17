// ==============================================================================
// Circuit 5: reg2reg_decoder (2-to-4 Register-to-Register Decoder with Enable)
// Architecture:
//   Inputs in[1:0], en -> Input DFFs -> Combinational 2:4 Decoder ->
//   Output DFFs -> out[3:0]
// ==============================================================================

`timescale 1ns / 1ps

module reg2reg_decoder (
    input  wire       clk,
    input  wire       rst_n,
    // Stage 1 Inputs
    input  wire [1:0] in,
    input  wire       en,
    // Stage 2 Registered Outputs
    output reg  [3:0] out
);

    // -------------------------------------------------------------------------
    // Stage 1: Input D Flip-Flops
    // -------------------------------------------------------------------------
    reg [1:0] r_in;
    reg       r_en;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_in <= 2'b00;
            r_en <= 1'b0;
        end else begin
            r_in <= in;
            r_en <= en;
        end
    end

    // -------------------------------------------------------------------------
    // Combinational 2-to-4 Decoder Logic Cone
    // -------------------------------------------------------------------------
    reg [3:0] comb_out;

    always @(*) begin
        if (!r_en) begin
            comb_out = 4'b0000;
        end else begin
            case (r_in)
                2'b00: comb_out = 4'b0001;
                2'b01: comb_out = 4'b0010;
                2'b10: comb_out = 4'b0100;
                2'b11: comb_out = 4'b1000;
                default: comb_out = 4'b0000;
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // Stage 2: Output D Flip-Flops
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out <= 4'b0000;
        end else begin
            out <= comb_out;
        end
    end

endmodule
