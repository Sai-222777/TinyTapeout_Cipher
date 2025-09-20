`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2025 08:55:23 PM
// Design Name: 
// Module Name: dual_xor_stream_cipher
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


module dual_xor_stream_cipher #(parameter M = 32)(
    input clk,
    input rst, 
    
    input tx_p,
    input rx_e,
    
    input sel0,
    input sel1,

    output tx_e,
    output rx_p,    
    output dbg_tx_p,
    output dbg_rx_e,
    
    input cfg_en,
    input cfg_i,
    input tx_en,
    input rx_en,
    output cfg_o,
    output [2:0] heartbeat );

parameter tx_lfsr_taps_default = {M{32'h48000000}};
parameter tx_lfsr_state_default = {M{32'h000000055}};
parameter a_mux_internal_signature = 1'b0;
parameter d_en_disabled = 1'b0;

reg [2*M+1:0] cfg_reg;
wire [2*M+1:0] cfg_next;
wire [M-1:0] tx_lfsr_o,rx_lfsr_o;

wire internal_signature;

wire cfg_en_b;
assign cfg_en_b = !cfg_en;
wire ld;
wire a_mux, d_en; 
wire [15:0] heartbeat_count;
wire combined_tx_en, combined_rx_en;

assign combined_tx_en = tx_en & cfg_en_b;
assign combined_rx_en = rx_en & cfg_en_b;

assign a_mux = cfg_reg[2*M+1];
assign d_en = cfg_reg[2*M]; 

wire tx_lfsr_k;

always @(posedge clk) begin
    if (rst) begin
        cfg_reg <= {a_mux_internal_signature, d_en_disabled, tx_lfsr_taps_default, tx_lfsr_state_default};
    end else begin
        cfg_reg <= cfg_next;
    end
end

assign cfg_next = (cfg_en) ? {cfg_i, cfg_reg[2*M+1:1]} : {cfg_reg[2*M+1:2*M], cfg_reg[2*M-1:M], tx_lfsr_o};

galois_lfsr #( .N(32) ) uut_tx_galois_lfsr
(
    .clk(clk),
    .rst(rst),
    .en(combined_tx_en),
    .sel0(sel0),
    .sel1(sel1),
    .ld(ld),
    .taps(cfg_reg[2*M-1:M]),
    .lfsr_i(cfg_reg[M-1:0]),
    .lfsr_o(tx_lfsr_o),
    .k(tx_lfsr_k)
);

galois_lfsr #( .N(32) ) uut_rx_galois_lfsr (
    .clk(clk),
    .rst(rst),
    .en(combined_rx_en),
    .ld(ld),
    .sel0(sel0),
    .sel1(sel1),
    .taps(cfg_reg[2*M-1:M]),
    .lfsr_i(cfg_reg[M-1:0]),
    .lfsr_o(rx_lfsr_o),
    .k(rx_lfsr_k)
);

signature uut_signature (
    .clk(clk),
    .reset(rst),
    .ld(ld),
    .en(combined_tx_en),
    .q(internal_signature)
);

counter uut_counter (
    .clk(clk),
    .rst(rst),
    .en(cfg_en),
    .trigger_count(16'd66),
    .count(),
    .pulse(ld));
    
counter uut_heartbeat_counter (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .trigger_count(16'hFFFF),
    .count(heartbeat_count),
    .pulse());

wire txp;

assign txp = (a_mux == 1'b1) ? tx_p : internal_signature;

assign tx_e = (cfg_en == 1'b0) ? tx_p ^ tx_lfsr_k : 1'b0; 
assign rx_p = (cfg_en == 1'b0) ? rx_e ^ tx_lfsr_k : 1'b0; 

assign dbg_tx_p = (cfg_en == 1'b0) ? ((d_en == 1'b1) ? tx_e ^ tx_lfsr_k : 1'b0) : 1'b0;
assign dbg_rx_e = (cfg_en == 1'b0) ? ((d_en == 1'b1) ? rx_p ^ rx_lfsr_k : 1'b0) : 1'b0;

assign cfg_o = (cfg_en == 1'b1) ? cfg_reg[0] : 1'b0;

assign heartbeat = heartbeat_count[9:7];

endmodule
