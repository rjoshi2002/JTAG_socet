/* Wen-Bo Hung, 2024/02/10
    email: hong395@purdue.edu*/
// JTAG SoCET team
`include "jtag_types_pkg.vh"
`ifndef FIFO_IF_VH
`define FIFO_IF_VH
interface fifo_if #(parameter WIDTH = 8, parameter DEPTH = 64);
import jtag_types_pkg::*;
	logic [WIDTH-1:0] data_in;
    logic wr_en;
    logic rd_en;
    logic [WIDTH-1:0] data_out;
    logic full;
    logic empty;
	modport FIFO
	(
		input data_in, wr_en, rd_en,
        output data_out, full, empty
	);

    modport TB
    (
        input data_out, full, empty,
        output data_in, wr_en, rd_en
    );
endinterface

`endif //FIFO_IF_VH