// $Id: $
// File name:   flex_stp_sr.sv
// Created:     2/8/2023
// Author:      Wen-Bo Hung
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Flexible and Scalable Serial-to-Parallel Shift Register Design

module flex_stp_sr # (
    NUM_BITS = 4,
    SHIFT_MSB = 1
) (
    input wire clk,
    input wire n_rst,
    input wire shift_enable,
    input wire serial_in,
    output reg [NUM_BITS-1:0] parallel_out
);
reg [NUM_BITS-1:0] next_output;

always_ff @(posedge clk, negedge n_rst) 
begin : SHIFT_REG_FLIPFLOP
    if(n_rst == 0)
    begin
        parallel_out <= '1;
    end
    else
    begin
        parallel_out <= next_output;
    end
end

always_comb begin : NEXT_OUTPUT
    if(shift_enable)
    begin
        if(SHIFT_MSB)
        begin
            next_output = { parallel_out [NUM_BITS-2:0], serial_in};
        end
        else
        begin
            next_output = {serial_in,  parallel_out[NUM_BITS-1:1]};
        end
    end
    else
    begin
        next_output = parallel_out;
    end
end

endmodule