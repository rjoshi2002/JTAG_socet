// Output stage logic
// TDO clocked on NEGATIVE edge
// Originally Written by Fred Owens, Sep 20, 2019
// Adapted by Wen-Bo Hung, Nov 12, 2023
// See section 4.5.1 for details on TDO: should be on negedge
// See section 4.5.1: The TDO driver shall be set to its inactive drive state except when the shifting of data is in progress
// What is the definition of inactive drive state?
// Do we need tlr_reset at TDO logic?
`include "output_logic_if.vh"

module output_logic(input logic TCK, TRST, output_logic_if.ol olif);

import jtag_types_pkg::*;
logic next_TDO;

always_ff @(negedge TRST, negedge TCK) begin // Update at negedge of TCK
    if (TRST == 1'b0) begin
        olif.TDO <= 1'b0;
    end
    else begin
        if(olif.tlr_reset) begin
            olif.TDO <= 1'b0;
        end 
        else begin
            olif.TDO <= next_TDO;
        end
    end
end

always_comb begin
    next_TDO = '0;
    if (olif.dr_shift == 1'b1) begin
        if (olif.instruction == BYPASS) begin
            next_TDO = olif.bypass_out;
        end
        else if (olif.instruction == EXTEST
                || olif.instruction == SAMPLE
                || olif.instruction == PRELOAD) 
        begin 
            next_TDO = olif.bsr_out;
        end
        else if (olif.instruction == TMP_STATUS) begin
            next_TDO = olif.tmp_status;
        end
        else if (olif.instruction == AHB) begin
            next_TDO = olif.ahb;  
        end
        else if (olif.instruction == IDCODE) begin
                next_TDO = olif.idcode;
        end
        else if (olif.instruction == AHB_ERROR) begin
          next_TDO = olif.ahb_error;
        end
    end
    else if (olif.ir_shift == 1'b1) begin
        next_TDO = olif.instr_out;
    end
end 

endmodule
