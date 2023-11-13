// Originally from Fred Owens, Oct 1 2019
// Adapted by Wen-Bo Hung, Nov 12 2023

`ifndef OUTPUT_LOGIC_IF_VH
`define OUTPUT_LOGIC_IF_VH

interface output_logic_if;
    
import jtag_types_pkg::*;
    logic dr_shift;
    logic bypass_out;
    logic bsr_out;
    logic ir_shift;
    logic instr_out;
    instruction_t instruction;
    logic TDO;
    logic tmp_status;
    logic ahb;
    logic idcode;
    logic ahb_error;
    logic tlr_reset;
    modport ol
    (
        input 
        dr_shift,
        bypass_out,
        bsr_out,
        ir_shift,
        tmp_status,
        instr_out,
        instruction,
        ahb,
        idcode,
        ahb_error,
        tlr_reset,
        output TDO 
    );
endinterface

`endif //OUTPUT_LOGIC_IF_VH
