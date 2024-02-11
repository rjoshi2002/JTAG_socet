/* Made by Wen-Bo Hung, 2023/11/2
    email: hong395@purdue.edu*/
// JTAG SoCET team
// If tmp controller is added, decoder don't need to decide bsr mode
// five data register: bsr, id reg, bypass reg, tmp_status reg, ahb reg
`ifndef INSTRUCTION_DECODER_IF_VH
`define INSTRUCTION_DECODER_IF_VH

interface instruction_decoder_if;

import jtag_types_pkg::*;
	instruction_t parallel_out;
	logic bsr_select, bsr_mode;
	logic id_select;
	logic bypass_select;
	logic tmp_select;
	logic ahb_select;
	// Signals to TMP controller
	logic clamp_hold_decode;
	logic clamp_release_decode;
	logic bypass_decode;
	modport ID
	(
		input parallel_out,
		output bsr_select, bsr_mode, id_select, bypass_select, ahb_select, tmp_select, clamp_hold_decode, clamp_release_decode, bypass_decode
	);
endinterface

`endif //INSTRUCTION_REGISTER_IF_VH
