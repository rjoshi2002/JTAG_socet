/*
Originally made by Fred Owens, Xianmeng Zhang, SEP 25 2019
Downloaded from SoCET, JTAG repository
Adapted by Wen-Bo Hung, hong395@purdue.edu

*/

`ifndef INSTRUCTION_REG_IF_VH
`define INSTRUCTION_REG_IF_VH

interface instruction_reg_if;

import jtag_types_pkg::*;
	logic					TDI;
	logic					ir_capture, ir_shift, ir_update, test_reset;
	logic					TDO;
	instruction_decode_t	parallel_out;
  	logic         tlr_reset;
	modport IR
	(
		input TDI,ir_capture, ir_shift, ir_update, test_reset, tlr_reset,
		output TDO, parallel_out
	);

endinterface

`endif //INSTRUCTION_REGISTER_IF_VH
