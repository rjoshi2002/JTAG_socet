/* Wen-Bo Hung, created at 2023/11/2, email: hong395@purdue.edu, peterhouse08271026@gmail.com*/
// JTAG SoCET Team
// JTAG top level
// Still lack of bypass register, IDcode register, tmp controller, tmp register
`include "adder_if.vh"
`include "bsr_if.vh"
`include "instruction_decoder_if.vh"
`include "instruction_reg_if.vh"
`include "tap_ctrl_if.vh"
`include "jtag_if.vh"
`include "output_logic_if.vh"

module jtag(
    input logic TCK, clk, 
    jtag_if.jtag jtif
);
    /* Types */
    import jtag_types_pkg::*;
    //Adder's parameter
    parameter BIT_WIDTH = 4;
    //BSR's parameter
    parameter NUM_IN = 9;
    parameter NUM_OUT = 5;
    /* Interface instantiations */
    adder_if adif();
    bsr_if bsrif();
    instruction_deocder_if idif();
    instruction_reg_if irif();
    tap_ctrl_if tcif();
    output_logic_if olif();

    /* Module instantiations */
    adder_Nbit     ADDER(adif);
    bsr            BSR(TCK, jtif.TRST, bsrif);
    instruction_decoder  INS_DECODE(TCK, jtif.TRST, idif);
    instruction_reg      INS_REG(TCK, jtif.TRST, irif);
    tap_ctrl             TAP_CTRL(TCK, jtif.TRST, tcif);
    output_logic         OUTPUT_LOGIC(TCK, jtif.TRST, olif);

    /*Input Signal Assign*/
    //4-bit adder(To test the functionality of BSR)
    assign adif.n_rst = jtif.nRST;
    assign adif.clk = clk;
    assign adif.a = bsrif.to_system_logic[0:BIT_WIDTH-1];
    assign adif.b = bsrif.to_system_logic[2*BIT_WIDTH-1:BIT_WIDTH];
    assign adif.carry_in = bsrif.to_system_logic[NUM_IN];
    //BSR
    assign bsrif.parallel_in = jtif.parallel_in;
    assign bsrif.parallel_system_logic_out = {adif.sum, adif.overflow};
    assign bsrif.TDI = jtif.TDI;
    assign bsrif.mode = idif.bsr_mode; // Change it when having tmp controller
    assign bsrif.dr_shift = tcif.dr_shift;
    assign bsrif.dr_capture = tcif.dr_capture;
    assign bsrif.dr_update = tcif.dr_update;
    assign bsrif.bsr_select = idif.bsr_select;
    //Instruction decoder
    assign idif.parallel_out = irif.parallel_out;
    //Instruction register
    assign irif.TDI = jtif.TDI;
    assign irif.ir_capture = tcif.ir_capture;
    assign irif.ir_update = tcif.ir_update;
    assign irif.ir_shift = tcif.ir_shift;
    assign irif.test_reset = tcif.tap_reset; // I don't understand there are two reset signal, both from tap_reset. Maybe we can remove one redundant
    assign irif.tlr_reset = tcif.tap_reset;
    //Tap controller
    assign tcif.TMS = jtif.TMS;
    //Output Logic
    assign olif.dr_shift = tcif.dr_shift;
    assign olif.bsr_out = bsrif.TDO;
    assign olif.ir_shift = tcif.ir_shift;
    assign olif.instr_out = irif.TDO;
    assign olif.instruction = irif.parallel_out;
    assign olif.tlr_reset = tcif.tap_reset;
    // JTAG output
    assign jtif.TDO = olif.TDO;
    assign jtif.parallel_out = bsrif.to_output_pin;

endmodule