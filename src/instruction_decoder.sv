/* Wen-Bo Hung, created at 2023/11/2, email: hong395@purdue.edu, peterhouse08271026@gmail.com*/
// JTAG SoCET Team
// Instruction decoder

`include "instruction_decoder_if.vh"

module instruction_decoder(
    input TCK, TRST,
    instruction_decoder_if.ID idif
);
    import jtag_types_pkg::*;

    always_comb begin : SELECT_LOGIC
        idif.bsr_select = 1'b0;
        idif.bsr_mode = 1'b0;
        idif.id_select = 1'b0;
        idif.bypass_select = 1'b0;
        idif.bypass_decode = 1'b0;
        idif.tmp_select = 1'b0;
        idif.ahb_select = 1'b0;
        idif.clamp_hold_decode = 1'b0;
        idif.clamp_release_decode = 1'b0;
        case (idif.parallel_out)
            BYPASS: begin
                idif.bypass_select = 1'b1;
                idif.bypass_decode = 1'b1;
            end
            SAMPLE: begin
                idif.bsr_select = 1'b1;
                idif.bsr_mode = 1'b0;
            end
            PRELOAD: begin
                idif.bsr_select = 1'b1;
                idif.bsr_mode = 1'b0;
            end
            EXTEST: begin
                idif.bsr_select = 1'b1;
                idif.bsr_mode = 1'b1;
            end
            IDCODE: begin
                idif.id_select = 1'b1;
            end
            AHB: begin
                idif.ahb_select = 1'b1;
            end
            CLAMP_HOLD: begin
                idif.tmp_select = 1'b1;
                idif.clamp_hold_decode = 1'b1;
            end
            CLAMP_RELEASE: begin
                idif.tmp_select = 1'b1;
                idif.clamp_release_decode = 1'b1;
            end
        endcase
    end

endmodule