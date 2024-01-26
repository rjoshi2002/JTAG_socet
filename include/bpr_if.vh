// Jason Choi
`include "jtag_types_pkg.vh"
`ifndef BPR_IF_VH
`define BPR_IF_VH
interface bpr_if;

import jtag_types_pkg::*;
    logic TDI, TDO;
    logic ShiftDR;
	logic bpr_select;
	logic tlr_reset;

	modport BPR
	(
		input ShiftDR, TDI, bpr_select, tlr_reset, 
		output TDO
	);
endinterface

`endif