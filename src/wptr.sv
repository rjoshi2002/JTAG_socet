/* Wen-Bo Hung, 2024/03/03
    email: hong395@purdue.edu*/
// JTAG SoCET team
`include "wptr_if.vh"
`include "jtag_types_pkg.vh"
module wptr #(parameter ADDR_WIDTH = 32)(
    wptr_if.WPTR wpif
);

logic [ADDR_WIDTH-1:0] nxt_waddr;
logic [ADDR_WIDTH-1:0] tran_raddr;

/* Module instantiations */
flex_bin2gray #(.bin2gray(1), .width(ADDR_WIDTH)) BIN2GRAY1 (wpif.waddr, wpif.wptr); // BIN2GRAY
flex_bin2gray #(.bin2gray(0), .width(ADDR_WIDTH)) BIN2GRAY2 (wpif.sync_rptr, tran_raddr); // GRAY2BIN

always_ff @(posedge wpif.wclk) begin : WPTR_FF
    if(!wpif.w_nrst) begin
        wpif.waddr <= '0;
    end
    else begin
        wpif.waddr <= nxt_waddr;
    end
end

always_comb begin : WPTR_NXT_LOGIC
    if(wpif.winc && !wpif.full) begin
        nxt_waddr = wpif.waddr + 1;
    end
    else begin
        nxt_waddr = wpif.waddr;
    end

    if(((wpif.waddr + 1) == tran_raddr) || ((tran_raddr == '0) && (wpif.waddr == '1)))
        wpif.full = 1'b1;
    else
        wpif.full = 1'b0;
end


endmodule