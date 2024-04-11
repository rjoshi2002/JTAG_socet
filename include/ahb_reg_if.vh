// Wen-Bo Hung & Jason Choi
`include "jtag_types_pkg.vh"
`ifndef AHB_REG_IF_VH
`define AHB_REG_IF_VH
interface ahb_reg_if;

import jtag_types_pkg::*;
    logic TDI, TDO;
	logic tlr_reset;
	logic dr_shift;
    logic dr_update;
	logic dr_capture;
    logic ahb_select;
	logic [40:0] parallel_out;
	logic winc;
	

	modport AHB_REG
	(
		input TDI, tlr_reset, dr_shift, dr_update, dr_capture, ahb_select, 
		output TDO, parallel_out, winc
	);
endinterface

`endif
