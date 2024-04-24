`include "afifo_if.vh"
`include "flex_fifo_mem_if.vh"
`include "wptr_if.vh"
`include "rptr_if.vh"
`include "jtag_types_pkg.vh"
// Asynchronous FIFO
module afifo #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 32)(
    afifo_if.AFIFO affif
);
    import jtag_types_pkg::*;
    /* Interface instantiations */
    flex_fifo_mem_if #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) ffif();
    wptr_if #(.ADDR_WIDTH(ADDR_WIDTH)) wpif();
    rptr_if #(.ADDR_WIDTH(ADDR_WIDTH)) rpif();

    /* Module instantiations */
    flex_fifo_mem   #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) FIFO (ffif);
    wptr            #(.ADDR_WIDTH(ADDR_WIDTH)) WPTR (wpif);
    rptr            #(.ADDR_WIDTH(ADDR_WIDTH)) RPTR (rpif);
    sync_low        #(.WIDTH(ADDR_WIDTH)) RPTR_SYNC (affif.wclk, affif.w_nrst, rpif.rptr, wpif.sync_rptr);
    sync_low        #(.WIDTH(ADDR_WIDTH)) WPTR_SYNC (affif.rclk, affif.r_nrst, wpif.wptr, rpif.sync_wptr);
    
    //FLEX_FIFO
    assign ffif.wdata = affif.wdata;
    assign ffif.wclk_en = affif.winc & (!affif.full);
    assign ffif.waddr = wpif.waddr;
    assign ffif.wclk = affif.wclk;
    assign ffif.raddr = rpif.raddr;
    assign affif.rdata = ffif.rdata;

    // WPTR
    assign affif.full = wpif.full;
    assign wpif.winc = affif.winc;
    assign wpif.wclk = affif.wclk;
    assign wpif.w_nrst = affif.w_nrst;
    
    // RPTR
    assign rpif.rinc = affif.rinc;
    assign affif.empty = rpif.empty;
    assign rpif.rclk = affif.rclk;
    assign rpif.r_nrst = affif.r_nrst;
endmodule