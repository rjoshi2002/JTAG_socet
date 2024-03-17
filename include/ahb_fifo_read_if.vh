/* Developed by Wen-Bo Hung, 2024/03/17
    email: hong395@purdue.edu*/
// JTAG SoCET team
`include "jtag_types_pkg.vh"
`ifndef AHB_FIFO_READ_IF_VH
`define AHB_FIFO_READ_IF_VH
interface ahb_fifo_read_if #(parameter DATA_WIDTH = 8);
import jtag_types_pkg::*;
    logic tlr_reset;
    logic dr_shift;
    logic ahb_fifo_read_select;
    logic TDO;
    logic empty;
    logic [DATA_WIDTH-1:0] rdata;
    logic rinc;
	modport AHB_READ
	(
		input tlr_reset, dr_shift, ahb_fifo_read_select, empty, rdata, 
        output TDO, rinc
	);

    modport TB
    (
        input TDO, rinc,  
        output tlr_reset, dr_shift, ahb_fifo_read_select, empty, rdata
    );
endinterface

`endif //AHB_FIFO_READ_IF_VH