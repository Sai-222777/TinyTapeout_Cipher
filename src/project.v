/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_Sai222777 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // List all unused inputs to prevent warnings
  wire _unused = &{ena,uio_in,1'b0};
  
  assign uio_out = 0;
  assign uio_oe = 0;
  
  dual_xor_stream_cipher #( .M(32) ) uut  (
    .clk(clk),
    .rst(!rst_n),
    .sel0(ui_in[0]),
    .sel1(ui_in[1]),
    .tx_p(ui_in[2]),
    .rx_e(ui_in[3]),
    .cfg_en(ui_in[4]),
    .cfg_i(ui_in[5]),
    .tx_en(ui_in[6]),
    .rx_en(ui_in[7]),
    
    .tx_e(uo_out[0]),
    .rx_p(uo_out[1]),
    .dbg_tx_p(uo_out[2]),
    .dbg_rx_e(uo_out[3]), 

    .cfg_o(uo_out[4]),
    .heartbeat(uo_out[7:5])
    );
  
endmodule
