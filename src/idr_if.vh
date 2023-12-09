// Jason Choi
`include "jtag_types_pkg.vh"
`ifndef IDR_IF_VH
`define IDR_IF_VH
// Default num of input and output pins are adder's pin
interface idr_if #(parameter NUM_IN = 2, parameter NUM_OUT = 0);
import jtag_types_pkg::*;
    logic TDI, TDO;
    logic [31:0] code;
    logic CaptureDR;

	modport IDR
	(
		input code, CaptureDR
	);
endinterface

`endif