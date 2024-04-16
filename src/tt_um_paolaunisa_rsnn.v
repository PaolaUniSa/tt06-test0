/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`define default_netname none

module tt_um_paolaunisa_rsnn (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

//  // All output pins must be assigned. If not used, assign to 0.
//  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
//  assign uio_out = 0;
//  assign uio_oe  = 0;
  
  wire rst = ! rst_n;
  wire spike;
    // Instantiate the LeakyIntegrateFireNeuron
 RecursiveSpikingNeuron RecursiveSpikingNeuron(
        .clk(clk),
        .reset(rst),
        .external_input_current(ui_in),
        .threshold(ui_in),
        .leak(ui_in),
        .refractory_period(ui_in[5:0]),
        .scale_factor(ui_in),
        .feedback_delay(ui_in[0]),
        .spike(spike)
    );
    
    
  assign uo_out[0]=spike;
  assign uo_out[7:1]=7'b0;
  
  
    //assign uo_out = {7'b0000000, spike};
    assign uio_out = 8'b0;
    assign uio_oe = 8'b0; //used bidirectional pins as input
    
endmodule

