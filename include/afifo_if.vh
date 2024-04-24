/* Wen-Bo Hung, 2024/02/10
    email: hong395@purdue.edu*/
// JTAG SoCET team
`include "jtag_types_pkg.vh"
`ifndef AFIFO_IF_VH
`define AFIFO_IF_VH
interface afifo_if #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 32);
import jtag_types_pkg::*;
	logic [DATA_WIDTH-1:0] wdata;
    logic winc;
    logic rinc;
    logic [DATA_WIDTH-1:0] rdata;
    logic full;
    logic empty;
    logic wclk;
    logic rclk;
    logic w_nrst;
    logic r_nrst;
	modport AFIFO
	(
		input wdata, winc, rinc, wclk, rclk, w_nrst, r_nrst,
        output rdata, full, empty
	);

    modport TB
    (
        input rdata, full, empty, 
        output wdata, winc, rinc, wclk, rclk, w_nrst, r_nrst
    );
endinterface

`endif //AFIFO_IF_VH