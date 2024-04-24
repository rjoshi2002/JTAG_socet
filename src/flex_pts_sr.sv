
// $Id: $
// File name:   flex_pts_sr.sv
// Created:     2/9/2023
// Author:      Wen-Bo Hung
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Flexible and Scalable Parallel-to-Serial Shift Register Design

module flex_pts_sr # (
    NUM_BITS = 4,
    SHIFT_MSB = 1
) (
    input wire clk,
    input wire n_rst,
    input wire shift_enable,
    input wire load_enable,
    input wire [NUM_BITS-1:0] parallel_in,
    output reg serial_out
);
reg [NUM_BITS-1:0] next_output;
reg [NUM_BITS-2:0] flipout;

always_ff @(posedge clk, negedge n_rst) 
begin : SHIFT_REG_FLIPFLOP
    if(n_rst == 0)
    begin
        flipout <= '0;
        serial_out <= '0;
    end
    else
    begin
        if(SHIFT_MSB == 1)
        begin
            flipout <= next_output [NUM_BITS-2:0];
            serial_out <= next_output [NUM_BITS-1];
        end
        else
        begin
            flipout <= next_output [NUM_BITS-1:1];
            serial_out <= next_output [0];
        end
    end
end

always_comb begin : NEXT_OUTPUT
    if(load_enable == 1)
    begin
        next_output = parallel_in;
    end
    else
    begin
        if(shift_enable == 1)
        begin
            if(SHIFT_MSB == 1)
            begin
                next_output = {flipout, 1'b0};
            end
            else
            begin
                next_output = {1'b0, flipout};
            end
        end
        else
        begin
            if(SHIFT_MSB == 1)
            begin
                next_output = {serial_out, flipout};
            end
            else
            begin
                next_output = {flipout, serial_out};
            end
        end
    end
end

endmodule
