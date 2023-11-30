// Bypass Register
// TCK: JTAG clock signal
// TDI: JTAG input signal
// TDO: JTAG output signal
// operate when ShiftDR = 1
// in the Shift-DR state, data is transferred from TDI to TDO with a delay of one TCK cycle
// in the Capture-DR state, a logic 0 is loaded into this register


`include "bpr_if.vh"

module bpr(
    input logic TCK, TRST,
    bpr_if.BPR bprif
);

    always_comb begin : bpr_comb
        next_TDI = bprif.TDI

        if (bprif.CaptureDR) begin
            next_TDI = 1'b0
        end
        else if (bprif.ShiftDR) begin
            next_TDI = bprif.TDI
        end
    end

    always_ff @ (posedge TCK, negedge TRST) begin : bpr_ff
        if(TRST == 1'b0) begin
            bprif.TDO <= 1'b0;
        end
        else begin
            bprif.TDO <= next_TDI;
        end
    end

endmodule
