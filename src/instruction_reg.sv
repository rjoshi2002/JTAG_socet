/*
Based on IEEE 1149.1 2013 7.2.2
Originally made by Xianmeng Zhang, SEP 29 2019, zhan2718@purdue.edu, xianmengzh@gmail.com
Downloaded from SoCET, JTAG repository
Adapted by Wen-Bo Hung, hong395@purdue.edu

*/
// Why are there so many reset signal? tlr_reset = test_reset(come from TAP controller), TRST
// Instruction Register + Instruction decoder

`include "instruction_reg_if.vh"

module instruction_reg(
	input logic TCK, TRST, 
    instruction_reg_if.IR IR
);
	import jtag_types_pkg::*;
	instruction_t n_shift_reg, shift_reg;
	instruction_decode_t n_parallel_out;

always_comb
begin : instruction_reg_control
//anti-latch
	n_shift_reg = shift_reg;
	n_parallel_out = IR.parallel_out;
	IR.TDO = shift_reg[0];

//Serial
	if (IR.ir_capture) // Set a default value, maybe we can set to BYPASS?
	begin
		n_shift_reg = SAMPLE;
	end
	else if (IR.ir_shift) // Shift in LSB first
	begin
		n_shift_reg[4] = IR.TDI;
		n_shift_reg[3:0] = shift_reg[4:1];
	end

//Parallel + decode
// Maybe don't use one-hot encoding scheme because it takes a lot of area when there are many instructions
	else if (IR.ir_update)
	begin
		casez(shift_reg)
			BYPASS:
				n_parallel_out = BYPASS_de;
			SAMPLE:
				n_parallel_out = SAMPLE_de;
			PRELOAD:
				n_parallel_out = PRELOAD_de;
			EXTEST:
				n_parallel_out = EXTEST_de;
			IDCODE:
				n_parallel_out = IDCODE_de;
			CLAMP:
				n_parallel_out = CLAMP_de;
			HIGHZ:
				n_parallel_out = HIGHZ_de;
			IC_RESET:
				n_parallel_out = IC_RESET_de;
			CLAMP_HOLD:
				n_parallel_out = CLAMP_HOLD_de;
			CLAMP_RELEASE:
				n_parallel_out = CLAMP_RELEASE_de;
			TMP_STATUS:
				n_parallel_out = TMP_STATUS_de;
			INIT_SETUP:
				n_parallel_out = INIT_SETUP_de;
			INIT_SETUP_CLAMP:
				n_parallel_out = INIT_SETUP_CLAMP_de;
			INIT_RUN:
				n_parallel_out = INIT_RUN_de;
            AHB:
                n_parallel_out = AHB_de;
            BYPASS_2:	// 6.2.1.1.d
				n_parallel_out = BYPASS_de; // I don't know what it is
            AHB_ERROR:
                n_parallel_out = AHB_ERROR_de;
		endcase
	end
	else if (IR.test_reset)
		n_parallel_out = BYPASS_de;
end

always_ff @(posedge TCK, negedge TRST) // Update shift register at posedge of TCK
begin
    if(TRST == 1'b0) begin
        shift_reg <= BYPASS;
    end else begin
        if(IR.tlr_reset) begin
            shift_reg <= BYPASS;
        end else begin
            shift_reg <= n_shift_reg;
        end
    end
end

always_ff @(negedge TCK, negedge TRST) // Update parallel_out at negedge of TCK
begin
    if (TRST == 1'b0) begin
		IR.parallel_out <= BYPASS_de;
    end else begin
        if(IR.tlr_reset) begin
            IR.parallel_out <= BYPASS_de;
        end else begin
            IR.parallel_out <= n_parallel_out;
        end
    end
end
endmodule
