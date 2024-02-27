// Jason Choi
// AHB Register module
`include "ahb_reg_if.vh"

module ahb_reg(
    input TCK,
    input TRST,
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




    // always_comb begin
    //     nxt_roll_flag = '0;
    //     nxt_count = count_out;

    //     if (clear == 1'b1) begin
    //         nxt_count = '0;
    //         nxt_roll_flag = '0;
    //     end

    //     else if (count_enable == 1'b1) begin
    //         if (rollover_val == count_out) 
    //             nxt_count = 1;
    //         else 
    //             nxt_count = count_out + 1'b1;

    //         if (rollover_val == nxt_count)
    //             nxt_roll_flag = 1'b1; //raise this flag when the NCL reach (rollover_val == nxt_count)
    //     end
    // end

    // always_ff @(posedge clk, negedge n_rst) begin
    //     if (n_rst == 1'b0) begin
    //         count_out <= '0;
    //         rollover_flag <= 1'b0;
    //     end
    //     else begin
    //         count_out <= nxt_count;
    //         rollover_flag <= nxt_roll_flag;
    //     end
    // end
endmodule