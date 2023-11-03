/*
Based on IEEE 1149.1 2013 7.2.2
Originally made by Xianmeng Zhang, SEP 29 2019, zhan2718@purdue.edu, xianmengzh@gmail.com
Downloaded from SoCET, JTAG repository
Adapted by Wen-Bo Hung, hong395@purdue.edu

*/
// Why are there so many reset signal? tlr_reset = test_reset(come from TAP controller), TRST
// Instruction Register

`include "instruction_reg_if.vh"

module instruction_reg(
	input logic TCK, TRST, 
    instruction_reg_if.IR IR
);
	import jtag_types_pkg::*;
	instruction_t n_shift_reg, shift_reg;
	instruction_t n_parallel_out;

parameter INSTRUCTION_BIT = 5;

always_comb begin : instruction_reg_control
//anti-latch
	n_shift_reg = shift_reg;
	n_parallel_out = IR.parallel_out;
	IR.TDO = shift_reg[0];

//Serial
	if (IR.ir_capture) // Set a default value
	begin
		n_shift_reg = BYPASS;
	end
	else if (IR.ir_shift) // Shift in LSB first
	begin
		n_shift_reg[INSTRUCTION_BIT-1] = IR.TDI;
		n_shift_reg[INSTRUCTION_BIT-2:0] = shift_reg[INSTRUCTION_BIT-1:1];
	end

//Parallel
	if (IR.test_reset)
		n_parallel_out = BYPASS;
	else if (IR.ir_update)
		n_parallel_out = shift_reg;
end

always_ff @(posedge TCK, negedge TRST) // Update shift register at posedge of TCK
begin
    if(TRST == 1'b0) begin
        shift_reg <= BYPASS;
    end else begin
        if(IR.tlr_reset) begin
            shift_reg <= BYPASS;
        end else begin
            shift_reg <= n_shift_reg;
        end
    end
end

always_ff @(negedge TCK, negedge TRST) // Update parallel_out at negedge of TCK
begin
    if (TRST == 1'b0) begin
		IR.parallel_out <= BYPASS;
    end 
	else begin
        if(IR.tlr_reset) begin
            IR.parallel_out <= BYPASS;
        end 
		else if(IR.ir_update) begin
            IR.parallel_out <= n_parallel_out;
        end
    end
end
endmodule
