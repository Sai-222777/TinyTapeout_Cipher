`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2025 08:55:53 PM
// Design Name: 
// Module Name: galois_lfsr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module galois_lfsr #(parameter N = 32)(
    input clk,
    input rst,
    input en,
    input ld,
    input sel0,
    input sel1,
    input [N-1:0] taps,
    input [N-1:0] lfsr_i,
    output [N-1:0] lfsr_o,
    output k
);
    reg [N-1:0] lfsr;
    
    always @(posedge clk) begin
        if (rst) begin
            lfsr <= {N{1'b1}};
        end else if (ld) begin
            lfsr <= lfsr_i;
        end else if (en) begin
            lfsr <= {lfsr[N-2:0], 1'b0} ^ (taps & {N{lfsr[N-1]}});
        end
    end
    
    wire [31:0] lfsr_o32;
    wire [31:0] lfsr_o16;
    wire [31:0] lfsr_o8;
    wire [31:0] lfsr_o4;

    assign lfsr_o32 = lfsr;                   // Full 32 bits
    assign lfsr_o16 = {16'b0, lfsr[15:0]};    // Lower 16 bits
    assign lfsr_o8  = {24'b0, lfsr[7:0]};     // Lower 8 bits
    assign lfsr_o4  = {28'b0, lfsr[3:0]};     // Lower 4 bits

    assign lfsr_o = (sel1 == 0 && sel0 == 0) ? lfsr_o32 :
                    (sel1 == 0 && sel0 == 1) ? lfsr_o16 :
                    (sel1 == 1 && sel0 == 0) ? lfsr_o8  :
                                              lfsr_o4;
    
    assign k = lfsr[N-1];
    
endmodule
