`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2025 08:54:57 PM
// Design Name: 
// Module Name: signature
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


module signature(
    input clk,
    input reset,
    input ld,
    input en,
    output reg q
);
    reg [7:0] counter;
    
    always @(posedge clk) begin
        if (reset) begin
            counter <= 8'h55;
            q <= 1'b0;
        end else if (ld) begin
            counter <= 8'h55;
            q <= 1'b0;
        end else if (en) begin
            counter <= counter + 1;
            q <= ^counter; // XOR all bits
        end
    end
endmodule
