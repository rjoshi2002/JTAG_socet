// Jason Choi
`include "jtag_types_pkg.vh"
`ifndef AHB_REG_IF_VH
`define AHB_REG_IF_VH
interface ahb_reg_if;

import jtag_types_pkg::*;
    logic TDI, TDO;
    logic dr_update;
	logic reset;
    logic enable;
    logic ahb_select;

	modport AHB_REG
	(
		input dr_update, TDI, reset, ahb_select,
		output TDO, enable
	);
endinterface

`endif