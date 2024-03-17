// $Id: $
// File name:   flex_counter.sv
// Created:     1/29/2023
// Author:      Wen-Bo Hung
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Flexible Counter Design
module flex_counter #(
    NUM_CNT_BITS = 4
) (
    input reg clk,
    input reg n_rst,
    input reg clear,
    input reg count_enable,
    input reg [NUM_CNT_BITS-1:0] rollover_val,
    output reg [NUM_CNT_BITS-1:0] count_out,
    output reg rollover_flag
);
reg [NUM_CNT_BITS-1:0] next_output;
reg next_rollover_flag;
always_ff @(posedge clk, negedge n_rst) 
begin : OUTPUT
    if(n_rst == 0) // Make counter back to initial value
    begin
        count_out <= 0;
        rollover_flag <= 0;
    end
    else
    begin
        count_out <= next_output;
        rollover_flag <= next_rollover_flag;
    end
end

always_comb 
begin : NEXT_STATE
    if(clear == 1)
    begin
      next_output = 0;
      next_rollover_flag = 0;
    end
    else if(count_enable == 1'b1)
    begin
        if(count_out == rollover_val)
        begin
            next_output = 1;
            next_rollover_flag = 0;
        end
        else if(count_out == rollover_val-1)
        begin
            next_output = count_out + 1;
            next_rollover_flag = 1;
        end
        else
        begin
            next_output = count_out + 1;
            next_rollover_flag = 0;
        end
    end
    else
    begin
        next_output = count_out;
        next_rollover_flag = rollover_flag;
    end
end

endmodule