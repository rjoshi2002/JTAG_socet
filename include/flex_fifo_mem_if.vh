// Initially developed by Karthik Maiya, Xianmeng Zhang, Feb 15 2020 
/* Adapted by Wen-Bo Hung, 2024/03/02
    email: hong395@purdue.edu*/
// JTAG SoCET team
`include "jtag_types_pkg.vh"
`ifndef FLEX_FIFO_MEM_IF_VH
`define FLEX_FIFO_MEM_IF_VH
interface flex_fifo_mem_if #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 32);
import jtag_types_pkg::*;
	logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;
    logic wclk_en;
    logic [ADDR_WIDTH-1:0] waddr;
    logic [ADDR_WIDTH-1:0] raddr;
    logic wclk;
	modport FIFO
	(
		input wclk_en, wdata, waddr, raddr, wclk, 
        output rdata
	);

    modport TB
    (
        input rdata, 
        output wclk_en, wdata, waddr, raddr, wclk
    );
endinterface

`endif //FLEX_FIFO_MEM_IF_VH