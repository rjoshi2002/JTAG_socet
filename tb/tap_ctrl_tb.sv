/* 
    Testbench for TAP controller 
*/

// interfaces 
`include "tap_ctrl_if.vh"

import jtag_types_pkg::*;
`timescale 1 ns / 1 ns


module tap_ctrl_tb;

    parameter PERIOD = 10;

    logic TCK = 0, TRST;

    // clock
    always #(PERIOD/2) TCK++;

    // interface
    tap_ctrl_if tapif();

    test PROG (); 
    
`ifndef MAPPED
    tap_ctrl DUT(TCK, TRST, tapif);
`else
    tap_ctrl DUT(
        .\tapif.TMS (tapif.TMS),
        .\tapif.tap_state_uir (tapif.tap_state_uir),
        .\tapif.ir_update (tapif.ir_update),
        .\tapif.ir_shift (tapif.ir_shift),
        .\tapif.ir_capture (tapif.ir_capture),
        .\tapif.dr_capture (tapif.dr_capture),
        .\tapif.dr_shift (tapif.dr_shift),
        .\tapif.dr_update (tapif.dr_update),
        .\tapif.tap_reset (tapif.tap_reset),
        .\TRST (TRST),
        .\TCK (TCK)
    );
`endif
endmodule 

program test (); 
    parameter PERIOD = 10; 
    string tb_test_case; 
    integer tb_test_case_num; 
    integer i; 

    task reset_dut; 
        tap_ctrl_tb.TRST = 0; 
        @(posedge tap_ctrl_tb.TCK); 
        tap_ctrl_tb.TRST = 1; 
        @(posedge tap_ctrl_tb.TCK); 
    endtask 

    task check_output; 
        input logic tap_reset, dr_capture, dr_shift, dr_update, ir_capture, ir_shift, ir_update, tap_state_uir; 
        input string test_case; 
        begin 
            if(tap_reset == tap_ctrl_tb.tap_reset) begin
                // $display("Correct tap_reset during %s test case", test_case);
            end else begin
                $display("Incorrect tap_reset during %s test case, current tap_reset is %d", test_case, tap_ctrl_tb.tap_reset); 
            end 
            if(dr_capture == tap_ctrl_tb.dr_capture) begin
                // $display("Correct dr_capture during %s test case", test_case);
            end else begin
                $display("Incorrect dr_capture during %s test case, current dr_capture is %d", test_case, tap_ctrl_tb.dr_capture); 
            end 
            if(dr_shift == tap_ctrl_tb.dr_shift) begin
                // $display("Correct dr_shift during %s test case", test_case);
            end else begin
                $display("Incorrect dr_shift during %s test case, current dr_shift is %d", test_case, tap_ctrl_tb.dr_shift); 
            end 
            if(dr_update == tap_ctrl_tb.dr_update) begin
                // $display("Correct dr_update during %s test case", test_case);
            end else begin
                $display("Incorrect dr_update during %s test case, current dr_update is %d", test_case, tap_ctrl_tb.dr_update); 
            end 
            if(ir_capture == tap_ctrl_tb.ir_capture) begin
                // $display("Correct ir_capture during %s test case", test_case);
            end else begin
                $display("Incorrect ir_capture during %s test case, current ir_capture is %d", test_case, tap_ctrl_tb.ir_capture); 
            end 
            if(ir_shift == tap_ctrl_tb.ir_shift) begin
                // $display("Correct ir_shift during %s test case", test_case);
            end else begin
                $display("Incorrect ir_shift during %s test case, current ir_shift is %d", test_case, tap_ctrl_tb.ir_shift); 
            end 
            if(ir_update == tap_ctrl_tb.ir_update) begin
                // $display("Correct ir_update during %s test case", test_case);
            end else begin
                $display("Incorrect ir_update during %s test case, current ir_update is %d", test_case, tap_ctrl_tb.ir_update); 
            end 
            if(tap_state_uir == tap_ctrl_tb.tap_state_uir) begin
                // $display("Correct tap_state_uir during %s test case", test_case);
            end else begin
                $display("Incorrect tap_state_uir during %s test case, current tap_state_uir is %d", test_case, tap_ctrl_tb.tap_state_uir); 
            end 
        end 
    endtask

    initial begin
        // initialize signal 
        tb_test_case = "initialization"; 
        tb_test_case_num = -1; 

        reset_dut; 

        tap_ctrl_tb.TMS = 1; 

        tb_test_case = "test TEST_LOGIC_RESET"; 
        tb_test_case_num = tb_test_case_num + 1;
        @(posedge tap_ctrl_tb.TCK); 
        check_output(1,0,0,0,0,0,0,0, test_case); 

        tap_ctrl_tb.TMS = 0;
        tb_test_case = "test RUN_TEST_IDLE"; 
        tb_test_case_num = tb_test_case_num + 1; 
        @(posedge tap_ctrl_tb.TCK); 
        check_output(0,0,0,0,0,0,0,0, test_case); 

        // start testing data column 
        tap_ctrl_tb.TMS = 1; 
        @(posedge tap_ctrl_tb.TCK); // SELECT_DR_SCAN 

        tb_test_case = "test CAPTURE_DR"; 
        tb_test_case_num = tb_test_case_num + 1;
        tap_ctrl_tb.TMS = 0; 
        @(posedge tap_ctrl_tb.TCK); 
        check_output(0,1,0,0,0,0,0,0, test_case); 
        
        // tap_ctrl_tb.TMS = 1; 
        tb_test_case = "test SHIFT_DR"; 
        tb_test_case_num = tb_test_case_num + 1;
        @(posedge tap_ctrl_tb.TCK); 
        check_output(0,0,1,0,0,0,0,0, test_case); 

        @(posedge tap_ctrl_tb.TCK); // stay at SHIFT_DR 
        check_output(0,0,1,0,0,0,0,0, test_case); 

        tap_ctrl_tb.TMS = 1; 
        tb_test_case = "test EXIT1_DR"; 
        tb_test_case_num = tb_test_case_num + 1; 
        @(posedge tap_ctrl_tb.TCK); 
        check_output(0,0,0,0,0,0,0,0, test_case); 

        tb_test_case = "test UPDATE_DR"; 
        tb_test_case_num = tb_test_case_num + 1;
        @(posedge tap_ctrl_tb.TCK); 
        check_output(0,0,0,1,0,0,0,0, test_case); 

        // tap_ctrl_tb.TMS = 1; 
        // tb_test_case = "test CAPTURE_IR"; 
        // tb_test_case_num = tb_test_case_num + 1;
        // @(posedge tap_ctrl_tb.TCK); 
        // check_output(0,0,0,0,1,0,0,0, test_case); 

        // tap_ctrl_tb.TMS = 1; 
        // tb_test_case = "test SHIFT_IR"; 
        // tb_test_case_num = tb_test_case_num + 1;
        // @(posedge tap_ctrl_tb.TCK); 
        // check_output(0,0,0,0,0,1,0,0, test_case); 

        // tap_ctrl_tb.TMS = 1; 
        // tb_test_case = "test UPDATE_IR"; 
        // tb_test_case_num = tb_test_case_num + 1;
        // @(posedge tap_ctrl_tb.TCK); 
        // check_output(0,0,0,0,0,0,1,1, test_case); 




    end
endprogram 