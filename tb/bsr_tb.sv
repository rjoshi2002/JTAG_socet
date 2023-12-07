/* Made by Wen-Bo Hung, 12/03/2023*/
`include "bsr_if.vh"
`include "jtag_types_pkg.vh"

`timescale 1 ns/1 ns

module bsr_tb;
    parameter PERIOD = 10;
    logic TCK = 0, TRST;
    // clock
    always #(PERIOD/2) TCK++;

    //interface
    bsr_if bsrif();
    //test program
    test #(.PERIOD (PERIOD)) PROG (
        .TCK(TCK),
        .TRST(TRST),
        .bsrif(bsrif)
    );
    // DUT
    `ifndef MAPPED
        bsr DUT(TCK, TRST, bsrif);
    `else
        bsr DUT(
            .\bsrif.parallel_in (bsrif.parallel_in),
            .\bsrif.parallel_system_logic_out(bsrif.parallel_system_logic_out),
            .\bsrif.to_system_logic (bsrif.to_system_logic),
            .\bsrif.to_output_pin (bsrif.to_output_pin),
            .\bsrif.TDI (bsrif.TDI),
            .\bsrif.TDO (bsrif.TDO),
            .\bsrif.mode (bsrif.mode),
            .\bsrif.dr_shift (bsrif.dr_shift),
            .\bsrif.dr_capture (bsrif.dr_capture),
            .\bsrif.dr_update (bsrif.dr_update),
            .\bsrif.bsr_select (bsrif.bsr_select),
            .\TCK (TCK),
            .\TRST (TRST)
        );
    `endif
endmodule

program test(
    input logic TCK,
    output logic TRST,
    bsr_if bsrif
);
    import jtag_types_pkg::*;
    parameter PERIOD = 10;
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


    task check_output;
    input logic [8:0] exp_to_system_logic;
    input logic [4:0] exp_to_output_pin;
    input logic exp_TDO;
    begin
        $display("%0d test case: %s", tb_test_num, tb_test_case);
        if(exp_to_system_logic == bsrif.to_system_logic) begin
            $display("to_system_logic is as espected: %0b", bsrif.to_system_logic);
        end
        else begin
            $display("to_system_logic is not as espected: %0b", bsrif.to_system_logic);
        end
        if(exp_to_output_pin == bsrif.to_output_pin) begin
            $display("to_output_pin is as espected: %0b", bsrif.to_output_pin);
        end
        else begin
            $display("to_output_pin is not as espected: %0b", bsrif.to_output_pin);
        end
        if(exp_TDO == bsrif.TDO) begin
            $display("TDO is as espected: %0b", bsrif.TDO);
        end
        else begin
            $display("TDO is not as espected: %0b", bsrif.TDO);
        end
        $display("");
    end
    endtask

    task data_shift;
    input logic [13:0] data;
    begin
        @(negedge TCK);
        bsrif.dr_shift = 1'b1;
        for(int i = 0; i < 14; i++) begin
            bsrif.TDI = data[i];
            @(negedge TCK);
        end
        bsrif.dr_shift = 1'b0;
    end
    endtask

    task data_update;
    begin
        @(negedge TCK);
        bsrif.dr_update = 1'b1;
        @(negedge TCK);
        bsrif.dr_update = 1'b0;
    end
    endtask

    task data_capture;
    begin
        @(negedge TCK);
        bsrif.dr_capture = 1'b1;
        @(negedge TCK);
        bsrif.dr_capture = 1'b0;
    end
    endtask

    initial begin
        tb_test_num = 0;
        tb_test_case = "Reset";
        TRST = 1'b1;
        bsrif.parallel_in = '0;
        bsrif.parallel_system_logic_out = '0;
        bsrif.TDI = '0;
        bsrif.mode = '0;
        bsrif.dr_shift = '0;
        bsrif.dr_capture = '0;
        bsrif.dr_update = '0;
        bsrif.bsr_select = '0;
        reset();
        bsrif.mode = 1'b1;
        @(negedge TCK);
        @(negedge TCK);
        check_output(9'b000000000, 5'b00000, 1'b0);
        // Case 1: mode = 0
        tb_test_num++;
        tb_test_case = "mode = 0";
        bsrif.parallel_in = 9'b101010101;
        bsrif.parallel_system_logic_out = 5'b00011;
        bsrif.mode = 1'b0;
        @(negedge TCK);
        @(negedge TCK);
        check_output(9'b101010101, 5'b00011, 1'b0);
        // Case 2: bsr_select = 1'b0, capture data
        tb_test_num++;
        tb_test_case = "bsr_select = 1'b0, capture data";
        reset();
        bsrif.mode = 1'b1;
        bsrif.bsr_select = '0;
        data_capture();
        data_update();
        check_output(9'b000000000, 5'b00000, 1'b0);
        // Case 3: bsr_select = 1'b0, shift in data
        tb_test_num++;
        tb_test_case = "bsr_select = 1'b0, shift in data";
        reset();
        bsrif.mode = 1'b1;
        bsrif.bsr_select = '0;
        data_shift(14'b01010101010101);
        data_update();
        check_output(9'b000000000, 5'b00000, 1'b0);
        // Case 4: bsr_select = 1'b1, capture data
        tb_test_num++;
        tb_test_case = "bsr_select = 1'b1, capture";
        reset();
        bsrif.mode = 1'b1;
        bsrif.bsr_select = 1'b1;
        check_output(9'b000000000, 5'b00000, 1'b0);
        data_capture();
        data_update();
        check_output(9'b101010101, 5'b00011, 1'b0);
        // Case 5: bsr_select = 1'b1, shift in data
        tb_test_num++;
        tb_test_case = "bsr_select = 1'b1, shift in data";
        reset();
        bsrif.mode = 1'b1;
        bsrif.bsr_select = 1'b1;
        check_output(9'b000000000, 5'b00000, 1'b0);
        data_shift(14'b01010101010101);
        data_update();
        check_output(9'b010101010, 5'b10101, 1'b1);
        // Case 6: change mode back to 0
        tb_test_num++;
        tb_test_case = "change mode back to 0";
        @(negedge TCK);
        @(negedge TCK);
        check_output(9'b010101010, 5'b10101, 1'b1);
        bsrif.mode = 1'b0;
        @(negedge TCK);
        check_output(9'b101010101, 5'b00011, 1'b1);
        @(negedge TCK);
        @(negedge TCK);
        $stop();
    end


endprogram