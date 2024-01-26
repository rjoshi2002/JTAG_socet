// Jason Choi
`include "jtag_types_pkg.vh"
`ifndef IDR_IF_VH
`define IDR_IF_VH
interface idr_if;

import jtag_types_pkg::*;
    logic TDI, TDO;
    // logic [31:0] code;
    logic CaptureDR, ShiftDR;
	logic idr_select;
	logic tlr_reset;

	modport IDR
	(
		input CaptureDR, ShiftDR, TDI, idr_select, tlr_reset, 
		output TDO
	);
endinterface

`endif