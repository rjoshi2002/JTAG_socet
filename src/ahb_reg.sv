// Jason Choi
// AHB Register module
`include "ahb_reg_if.vh"

module ahb_reg(
    input logic TCK,
    input logic TRST,
    ahb_reg_if.IDR ahbif
);

    logic [5:0] count;
    logic [5:0] count_next;

    assign ahbif.enable = (ahbif.ahb_select == 1'b1) && (ahbif.dr_update == 1'b1);

    always_comb begin : ahb_reg_comb
        count_next = count;

        if ((ahbif.ahb_select == 1'b1) && (ahbif.dr_update == 1'b1)) begin
            if (count < 6'd38) begin
                if (adbif.TDI == 1'b1) begin
                    count_next = count + 1'd1;
                end
            end
            else begin
                if (adbif.TDI == 1'b1) begin
                    count_next = 1'd1;
                end
                else begin
                    count_next = 1'd0;
                end
            end
        end
    end

    always_ff @(posedge TCK, negedge TRST) begin : ahb_reg_ff
        if (TRST == 1'b0) begin
            count <= '0;
        end
        else begin
            if(ahbif.reset) begin
                count <= '0;
            end
            else begin
                count <= count_next;
            end
        end
    end    

endmodule
