// $Id: $
// File name:   sync_low.sv
// Created:     1/29/2023
// Author:      Wen-Bo Hung
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Reset to Logic Low Synchronizer
module sync_low #(WIDTH = 8)(
    input wire clk,
    input wire n_rst,
    input wire [WIDTH-1:0] async_in,
    output reg [WIDTH-1:0] sync_out
);
reg [WIDTH-1:0] meta;
always_ff @( posedge clk, negedge n_rst ) 
begin : RESET_LOW_SYNCHRONIZER
    if(n_rst == 1'b0)
    begin
        meta <= '0;
        sync_out <= '0;
    end
    else
    begin
        meta <= async_in;
        sync_out <= meta;
    end
end
    
endmodule