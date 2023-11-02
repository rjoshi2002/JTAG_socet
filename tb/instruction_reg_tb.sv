`include "instruction_reg_if.vh"

`timescale 1ns/1ns

module instruction_reg_tb;
    import jtag_types_pkg::*;
    parameter PERIOD = 10;
    instruction_reg_if irif();
    logic CLK=0, nRST;
    instruction_reg DUT(CLK, nRST, irif);
    test_ir PROG(CLK, nRST, irif);

    always #(PERIOD/2) CLK++;

    task reset_dut;
        begin
            @(negedge CLK);
            nRST = 0;
            @(negedge CLK);
            @(negedge CLK);
            nRST = 1;
            @(negedge CLK);
        end
    endtask

    task check_outputs
        (
            input instruction_decode_t exp_parallel_out,
            input logic exp_tdo
        );
        begin
            if (exp_parallel_out != irif.parallel_out) begin
                $display("\tParallel Out does not match expected Prallel Out");
            end
            else
            	$display("CORRECT P out");
            if (exp_tdo != irif.TDO) begin
                $display("\tTDO does not match expected TDO");
            end
            else
            	$display("CORRECT TDO");
        end
    endtask

    task shift_in
        (
            input instruction_t instr
        );
        begin
            irif.ir_shift = 1;
            irif.TDI = instr[0];
            @(negedge CLK);
            irif.TDI = instr[1];
            @(negedge CLK);
            irif.TDI = instr[2];
            @(negedge CLK);
            irif.TDI = instr[3];
            @(negedge CLK);
            irif.TDI = 0;
            irif.ir_shift = 0;
        end
    endtask

endmodule



program test_ir(
    input logic CLK, nRST,
    instruction_reg_if.IR irif
);
    initial begin
        import jtag_types_pkg::*;
        irif.TDI = 0;
        irif.ir_capture = 0;
        irif.ir_shift = 0;
        irif.ir_update = 0;
        irif.test_reset = 0;

        $display("RESET DUT TEST");
        reset_dut();
        check_outputs(BYPASS_de, 0); // used to be 1

        $display("TEST RESET TEST");
        shift_in(INIT_RUN);
        irif.ir_update = 1;
        @(negedge CLK);
        check_outputs(INIT_RUN_de, 1);
        @(negedge CLK);
        irif.ir_update = 0;
        irif.test_reset = 1;
        @(negedge CLK);
        check_outputs(BYPASS_de, 1);
        irif.ir_update = 0;
        irif.test_reset = 0;
        reset_dut();
        $display("IR UPDATE TEST");
        shift_in(SAMPLE);
        irif.ir_update = 1;
        @(negedge CLK);
        check_outputs(SAMPLE_de, 1);
        shift_in(BYPASS);
        @(negedge CLK);
        check_outputs(BYPASS_de, 0);
        shift_in(EXTEST);
        @(negedge CLK);
        check_outputs(EXTEST_de, 1);
        shift_in(IDCODE);
        @(negedge CLK);
        check_outputs(IDCODE_de, 0);
        shift_in(CLAMP);
        @(negedge CLK);
        check_outputs(CLAMP_de, 1);
        shift_in(HIGHZ);
        @(negedge CLK);
        check_outputs(HIGHZ_de, 0);
        shift_in(IC_RESET);
        @(negedge CLK);
        check_outputs(IC_RESET_de, 1);
        shift_in(CLAMP_HOLD);
        @(negedge CLK);
        check_outputs(CLAMP_HOLD_de, 0);
        shift_in(CLAMP_RELEASE);
        @(negedge CLK);
        check_outputs(CLAMP_RELEASE_de, 1);
        shift_in(TMP_STATUS);
        @(negedge CLK);
        check_outputs(TMP_STATUS_de, 0);
        shift_in(INIT_SETUP);
        @(negedge CLK);
        check_outputs(INIT_SETUP_de, 1);
        shift_in(INIT_SETUP_CLAMP);
        @(negedge CLK);
        check_outputs(INIT_SETUP_CLAMP_de, 0);
        shift_in(INIT_RUN);
        @(negedge CLK);
        check_outputs(INIT_RUN_de, 1);
        shift_in(PRELOAD);
        @(negedge CLK);
        check_outputs(PRELOAD_de, 0);
        irif.ir_update = 0;

        $display("IR UPDATE DISABLE TEST");
        shift_in(INIT_SETUP);
        @(negedge CLK);
        check_outputs(PRELOAD_de, 1);
        @(negedge CLK);
        @(negedge CLK);
    end
endprogram









