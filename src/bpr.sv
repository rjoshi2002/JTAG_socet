// Bypass Register
// TCK: JTAG clock signal
// TDI: JTAG input signal
// TDO: JTAG output signal
// operate when ShiftDR = 1
// in the Shift-DR state, data is transferred from TDI to TDO with a delay of one TCK cycle
// in the Capture-DR state, a logic 0 is loaded into this register


`include "bpr_if.vh"
`include "jtag_types_pkg.vh"

module bpr(
    input logic TCK, TRST,
    bpr_if.BPR bprif
);

    logic next_TDO;

    always_comb begin : bpr_comb
        next_TDO = bprif.TDI;

        if (bprif.ShiftDR && bprif.bpr_select) begin
            next_TDO = bprif.TDI;
        end
        else if(bprif.tlr_reset)
            next_TDO = 1'b0;
    end

    always_ff @ (posedge TCK, negedge TRST) begin : bpr_ff
        if(TRST == 1'b0) begin
            bprif.TDO <= 1'b0;
        end
        else begin
            bprif.TDO <= next_TDO;
        end
    end

endmodule
