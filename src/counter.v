`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2025 08:54:15 PM
// Design Name: 
// Module Name: counter
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


module counter(
    input clk,
    input rst,
    input en,
    input [15:0] trigger_count,
    output reg [15:0] count,
    output pulse
);
    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
        end else if (en) begin
            if (count == trigger_count) begin
                count <= 0;
            end else begin
                count <= count + 1;
            end
        end
    end
    
    assign pulse = (count == trigger_count) && en;
endmodule
