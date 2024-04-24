/* Wen-Bo Hung, 2024/03/03
    email: hong395@purdue.edu*/
// JTAG SoCET team
`include "jtag_types_pkg.vh"
`ifndef RPTR_IF_VH
`define RPTR_IF_VH
interface rptr_if #(parameter ADDR_WIDTH = 32);
import jtag_types_pkg::*;
	logic empty;
    logic rinc;
    logic rclk;
    logic r_nrst;
    logic [ADDR_WIDTH-1:0] sync_wptr;
    logic [ADDR_WIDTH-1:0] rptr;
    logic [ADDR_WIDTH-1:0] raddr;

	modport RPTR
	(
		input rinc, rclk, r_nrst, sync_wptr, 
        output empty, rptr, raddr
	);

    modport TB
    (
        input empty, rptr, raddr, 
        output rinc, rclk, r_nrst, sync_wptr
    );
endinterface

`endif //RPTR_IF_VH