`timescale 1ns/1ps

module tb_testing();
    parameter M = 32;
    
    reg clk;
    reg rst;
    reg tx_p;
    reg rx_e;
    reg cfg_en;
    reg cfg_i;
    reg tx_en;
    reg rx_en;
    
    reg sel0, sel1;
    
    wire tx_e;
    wire rx_p;
    wire dbg_tx_p;
    wire dbg_rx_e;
    wire cfg_o;
    wire [2:0] heartbeat;
    
    // Test vectors
    reg [15:0] test_input = 16'b1111000011110000;
    reg [15:0] encrypted_data;
    reg [15:0] decrypted_data;
    
    integer i;
    
    // Instantiate the DUT
//    dual_xor_stream_cipher #(.M(M)) dut (
//        .clk(clk),
//        .rst(rst),
//        .sel0(sel0),
//        .sel1(sel1),
//        .tx_p(tx_p),
//        .rx_e(rx_e),
//        .tx_e(tx_e),
//        .rx_p(rx_p),
//        .dbg_tx_p(dbg_tx_p),
//        .dbg_rx_e(dbg_rx_e),
//        .cfg_en(cfg_en),
//        .cfg_i(cfg_i),
//        .tx_en(tx_en),
//        .rx_en(rx_en),
//        .cfg_o(cfg_o),
//        .heartbeat(heartbeat)
//    );
    
    wire [7:0] ui_in, uo_out;
    
    assign tx_e = uo_out[0];
    assign rx_p = uo_out[1];
    
    assign ui_in = {rx_en,tx_en,cfg_i,cfg_en,rx_e,tx_p,sel1,sel0};
    
    tt_um_Sai222777 dut (
    .ui_in(ui_in),
    .uo_out(uo_out),
    .clk(clk),
    .rst_n(!rst)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Initialize signals
    initial begin
        
        $dumpfile("tb_dual_xor_stream_cipher.vcd");
        $dumpvars(0, tb_dual_xor_stream_cipher);
    
        clk = 0;
        rst = 1;
        tx_p = 0;
        rx_e = 0;
        cfg_en = 0;
        cfg_i = 0;
        tx_en = 0;
        rx_en = 0;
        sel0 = 1;
        sel1 = 0;
        
        // Reset the system
        #20;
        rst = 0;
        #20;
        
        $display("=== TEST STARTED ===");
        $display("Original Input: %b", test_input);
        
        // Test 1: Encryption and Decryption
        test_encryption_decryption();
        
//        #2000 $finish;
    end
    
    task test_encryption_decryption;
    begin
        $display("\n--- Test 1: Encryption and Decryption ---");
        
        // Configure LFSR (optional - use defaults)
        configure_lfsr();
        
        // Encrypt the test input
        $display("Encrypting...");
        encrypted_data = 0;
        for (i = 0; i < 16; i = i + 1) begin
            tx_p = test_input[i];
            tx_en = 1;
            #10;
            encrypted_data[i] = tx_e;
            tx_en = 0;
            #10;
        end
        
        $display("Encrypted Output: %b", encrypted_data);
        
        // Reset and reconfigure to ensure same LFSR state for decryption
        rst = 1;
        #20;
        rst = 0;
        #20;
        configure_lfsr();
        
        // Decrypt the encrypted data
        $display("Decrypting...");
        decrypted_data = 0;
        for (i = 0; i < 16; i = i + 1) begin
            rx_e = encrypted_data[i];
//            rx_e = test_input[i];
            rx_en = 1;
            #10;
            decrypted_data[i] = rx_p;
            rx_en = 0;
            #10;
        end
        
        $display("Decrypted Output: %b", decrypted_data);
    end
    endtask
    
    task configure_lfsr;
    begin
        $display("Configuring LFSR with default values...");
        cfg_en = 1;
        // Shift in configuration bits (using defaults)
        for (i = 0; i < (2*M+2); i = i + 1) begin
            cfg_i = 0; // Default configuration
            #10;
        end
        cfg_en = 0;
        #20;
    end
    endtask
    
    
    // Monitor signals
//    always @(posedge clk) begin
//        if (tx_en) begin
//            $display("TX: P=%b, E=%b, LFSR_k=%b", tx_p, tx_e, dut.tx_lfsr_k);
//        end
//        if (rx_en) begin
//            $display("RX: E=%b, P=%b, LFSR_k=%b", rx_e, rx_p, dut.tx_lfsr_k);
//        end
//    end
    
endmodule
