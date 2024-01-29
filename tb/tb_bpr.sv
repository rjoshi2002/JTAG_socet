`include "bpr_if.vh"
`include "jtag_types_pkg.vh"

`timescale 1 ns/1 ns

module tb_bpr();
    reg tb_TCK;
    reg tb_TRST;
    reg tb_bprif;

    string tb_test_case;

    idr_if bprif();
    // DUT Port map
    bpr #(
        .TCK(tb_TCK),
        .TRST(tb_TRST),
        .bprif(tb_bprif)
    );

    // Test bench main process
    initial
    begin
        tb_test_case = "Test bench initialization";
        tb_TRST = 1'b1;
        #(0.1);

        tb_test_case = "1. Check for ID code";
        @(negedge tb_TCK);
        @(negedge tb_TCK);
        if (tb_idrif.code == 00010000000000000001000000000011) begin
            $display("PASS: Check for ID code");
        end

        tb_test_case = "2. Check for Reset";
        tb_TRST = 1'b0;
        @(negedge tb_TCK);
        @(negedge tb_TCK);
        if (tb_idrif.code == 00000000000000000000000000000000) begin
            $display("PASS: Check for Reset");
        end



        $stop();
    end
endmodule
