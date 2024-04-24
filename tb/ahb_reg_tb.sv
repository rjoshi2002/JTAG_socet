/* Made by Wen-Bo Hung, 04/11/2024*/
`include "ahb_reg_if.vh"
`include "jtag_types_pkg.vh"

`timescale 1 ns/1 ns

module ahb_reg_tb;
    parameter PERIOD = 10;
    logic TCK = 0;
    // clock
    always #(PERIOD/2) TCK++;

    //interface
    ahb_reg_if ahbif();
    //test program
    test #(.PERIOD (PERIOD)) PROG (
        .TCK(TCK),
        .ahbif(ahbif)
    );
    // DUT
    ahb_reg DUT(TCK, ahbif);
endmodule

program test(
    input logic TCK,
    ahb_reg_if ahbif
);
    import jtag_types_pkg::*;
    parameter PERIOD = 10;
    int tb_test_num;
    string tb_test_case;

    task reset;
    begin
        ahbif.tlr_reset = 1;
        @(posedge TCK);
        @(posedge TCK);
        @(negedge TCK);
        ahbif.tlr_reset = 0;
    end
    endtask


    task check_output;
    input logic [40:0] exp_parallel_out;
    input logic exp_winc;
    input logic exp_TDO;
    begin
        $display("%0d test case: %s", tb_test_num, tb_test_case);
        if(exp_winc == ahbif.winc) begin
            $display("winc is as espected: %0b", ahbif.winc);
        end
        else begin
            $display("winc is not as espected: %0b", ahbif.winc);
        end
        if(exp_parallel_out == ahbif.parallel_out) begin
            $display("parallel_out is as espected: %0b", ahbif.parallel_out);
        end
        else begin
            $display("parallel_out is not as espected: %0b", ahbif.parallel_out);
        end
        if(exp_TDO == ahbif.TDO) begin
            $display("TDO is as espected: %0b", ahbif.TDO);
        end
        else begin
            $display("TDO is not as espected: %0b", ahbif.TDO);
        end
        $display("");
    end
    endtask

    task data_shift;
    input logic [40:0] data;
    begin
        @(negedge TCK);
        ahbif.dr_shift = 1'b1;
        for(int i = 0; i < 41; i++) begin
            ahbif.TDI = data[i];
            @(negedge TCK);
        end
        ahbif.dr_shift = 1'b0;
    end
    endtask

    task data_update;
    begin
        @(negedge TCK);
        ahbif.dr_update = 1'b1;
        @(negedge TCK);
        ahbif.dr_update = 1'b0;
    end
    endtask

    task data_capture;
    begin
        @(negedge TCK);
        ahbif.dr_capture = 1'b1;
        @(negedge TCK);
        ahbif.dr_capture = 1'b0;
    end
    endtask


    initial begin
        tb_test_num = 0;
        tb_test_case = "Reset";
        ahbif.tlr_reset = 1'b0;
        ahbif.TDI = '0;
        ahbif.dr_shift = '0;
        ahbif.dr_update = '0;
        ahbif.dr_capture = 1'b0;
        ahbif.ahb_select = '0;
        reset();
        @(negedge TCK);
        @(negedge TCK);
        check_output(41'b0, 1'b0, 1'b0);
        // Case 1: shift in normal 41 bit ap_instruction
        tb_test_num++;
        tb_test_case = "shift in normal 41 bit ap_instruction";
        ahbif.ahb_select = 1'b1;
        data_shift(41'b10101010101010101010101010101010101010101);
        check_output(41'b10101010101010101010101010101010101010101, 1'b0, 1'b1);
        ahbif.dr_update = 1'b1;
        #(0.1*PERIOD);
        check_output(41'b10101010101010101010101010101010101010101, 1'b1, 1'b1);
        ahbif.dr_update = 1'b0;
        // Case 2: shift in normal 41 bit ap_instruction without clearing the count
        tb_test_num++;
        tb_test_case = "shift in normal 41 bit ap_instruction without clearing the count";
        data_shift(41'b10101010101010101010101010101010101010101);
        check_output(41'b10101010101010101010101010101010101010101, 1'b0, 1'b1);
        ahbif.dr_update = 1'b1;
        #(0.1*PERIOD);
        check_output(41'b10101010101010101010101010101010101010101, 1'b0, 1'b1);
        ahbif.dr_update = 1'b0;
        // Case 3: shift in normal 41 bit ap_instruction after clearing the count
        tb_test_num++;
        tb_test_case = "shift in normal 41 bit ap_instruction after clearing the count";
        ahbif.dr_update = 1'b1;
        @(negedge TCK);
        ahbif.dr_update = 1'b0;
        data_shift(41'b10101010101010101010101010101010101010101);
        check_output(41'b10101010101010101010101010101010101010101, 1'b0, 1'b1);
        ahbif.dr_update = 1'b1;
        #(0.1*PERIOD);
        check_output(41'b10101010101010101010101010101010101010101, 1'b1, 1'b1);
        $stop();
    end


endprogram