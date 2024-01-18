// Jason Choi
`include "idr_if.vh"
`include "jtag_types_pkg.vh"

`timescale 1 ns/1 ns

module tb_idr();
    parameter PERIOD = 10;
    logic TCK = 0;
    logic TRST;
    // logic idrif;
    always #(PERIOD / 2) TCK++;

    idr_if idrif();
    // DUT Port map
    test PROG(
        .TCK(TCK),
        .TRST(TRST),
        .idrif(idrif)
    );
    idr DUT(TCK, TRST, idrif);
    // `endif
endmodule

program test(
    input logic TCK,
    output logic TRST,
    idr_if idrif
);
    import jtag_types_pkg::*;
    int tb_test_num;
    string tb_test_case;

    task reset;
    begin
        TRST = 0;
        @(posedge TCK);
        @(posedge TCK);
        @(negedge TCK);
        TRST = 1;
    end
    endtask

    task data_capture;
    begin
        @(negedge TCK);
        idrif.CaptureDR = 1'b1;
        @(negedge TCK);
        idrif.CaptureDR = 1'b0;
    end
    endtask

    // Test bench main process
    initial begin
        // tb_test_case = "Test bench initialization";
        TRST = 1'b1;
        #(0.1);

        tb_test_num = 0;
        tb_test_case = "Check for ID code";
        @(negedge TCK);
        @(negedge TCK);
        assign idrif.CaptureDR = 1'b1;
        if (idrif.CaptureDR == 1'b1) begin
            if (idrif.code == 32'b00010000000000000001000000000011) begin
                $display("PASS: Check for ID code");
            end
        end
        
        tb_test_num = 1;
        tb_test_case = "Check for Reset";
        reset();
        // TRST = 1'b0;
        // @(negedge TCK);
        // @(negedge TCK);
        if (idrif.code == '0) begin
            $display("PASS: Check for Reset");
        end

        $stop();
    end
endprogram
