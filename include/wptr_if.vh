/* Wen-Bo Hung, 2024/03/03
    email: hong395@purdue.edu*/
// JTAG SoCET team
`include "jtag_types_pkg.vh"
`ifndef WPTR_IF_VH
`define WPTR_IF_VH
interface wptr_if #(parameter ADDR_WIDTH = 32);
import jtag_types_pkg::*;
	logic full;
    logic winc;
    logic wclk;
    logic w_nrst;
    logic [ADDR_WIDTH-1:0] sync_rptr;
    logic [ADDR_WIDTH-1:0] wptr;
    logic [ADDR_WIDTH-1:0] waddr;

	modport WPTR
	(
		input winc, wclk, w_nrst, sync_rptr, 
        output full, wptr, waddr
	);

    modport TB
    (
        input full, wptr, waddr, 
        output winc, wclk, w_nrst, sync_rptr
    );
endinterface

`endif //WPTR_IF_VH