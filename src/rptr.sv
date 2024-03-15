/* Wen-Bo Hung, 2024/03/03
    email: hong395@purdue.edu*/
// JTAG SoCET team
`include "rptr_if.vh"
`include "jtag_types_pkg.vh"
module rptr #(parameter ADDR_WIDTH = 32)(
    rptr_if.RPTR rpif
);

logic [ADDR_WIDTH-1:0] nxt_raddr;

/* Module instantiations */
flex_bin2gray #(.bin2gray(1), .width(ADDR_WIDTH)) BIN2GRAY (rpif.raddr, rpif.rptr); // BIN2GRAY

always_ff @(posedge rpif.rclk) begin : RPTR_FF
    if(!rpif.r_nrst) begin
        rpif.raddr <= '0;
    end
    else begin
        rpif.raddr <= nxt_raddr;
    end
end

always_comb begin : RPTR_NXT_LOGIC
    if(rpif.rinc && !rpif.empty) begin
        nxt_raddr = rpif.raddr + 1;
    end
    else begin
        nxt_raddr = rpif.raddr;
    end

    if(rpif.sync_wptr == rpif.rptr)
        rpif.empty = 1'b1;
    else
        rpif.empty = 1'b0;
end


endmodule