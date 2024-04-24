// Jason Choi & Wen-Bo Hung
// AHB Register module
`include "ahb_reg_if.vh"

module ahb_reg(
    input logic TCK,
    ahb_reg_if.AHB_REG ahbif
);

    logic [5:0] count; // count how many bits have shifted in
    logic [5:0] nxt_count;
    logic [40:0] ap_instruction;
    logic [40:0] nxt_ap_instruction; 

    assign ahbif.parallel_out = ap_instruction;
    assign ahbif.TDO = ap_instruction[0];

    always_ff @( posedge TCK, posedge ahbif.tlr_reset ) begin : AHB_REG_FF
        if(ahbif.tlr_reset) begin
            count <= '0;
            ap_instruction <= '0;
        end
        else begin
            count <= nxt_count;
            ap_instruction <= nxt_ap_instruction;
        end
    end 

    always_comb begin : NXT_AP_INSTRUCTION
        nxt_ap_instruction = ap_instruction;
        if(ahbif.ahb_select) begin
            if(ahbif.dr_shift) begin
                nxt_ap_instruction = {ahbif.TDI, ap_instruction[40:1]};
            end
        end
    end

    always_comb begin : WINC
        ahbif.winc = 1'b0;
        if(ahbif.ahb_select) begin
            if((count == 6'd41) && (ahbif.dr_update)) begin // If user doesn't shift in 41 bits, don't update the fifo
                ahbif.winc = 1'b1;
            end
        end
    end

    always_comb begin : COUNT_LOGIC
        nxt_count = count;
        if(ahbif.dr_update) begin // Clear the count every time when dr_update is 1
            nxt_count = '0;
        end
        else if(ahbif.dr_capture) begin // Clear the count every time when dr_capture is 1
            nxt_count = '0;
        end
        else if(ahbif.ahb_select) begin
            if(ahbif.dr_shift) begin
                nxt_count = count + 1;
            end
        end
        
    end

endmodule
