/* Wen-Bo Hung, created at 2023/11/2, email: hong395@purdue.edu*/
// JTAG SoCET Team
// JTAG top level
// Still lack of tmp controller, tmp register
`include "adder_if.vh"
`include "bsr_if.vh"
`include "idr_if.vh"
`include "bpr_if.vh"
`include "ahb_fifo_read_if.vh"
`include "afifo_if.vh"
`include "instruction_decoder_if.vh"
`include "instruction_reg_if.vh"
`include "tap_ctrl_if.vh"
`include "jtag_if.vh"
`include "output_logic_if.vh"

module jtag(
    jtag_if.jtag jtif
);
    /* Types */
    import jtag_types_pkg::*;
    //Adder's parameter
    parameter BIT_WIDTH = 4;
    //BSR's parameter
    parameter NUM_IN = 9;
    parameter NUM_OUT = 5;
    // AHB DATA
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 3;
    /* Interface instantiations */
    adder_if adif(jtif.clk);
    bsr_if bsrif();
    idr_if idrif();
    bpr_if bprif();
    ahb_fifo_read_if #(.DATA_WIDTH(DATA_WIDTH)) arif();
    afifo_if #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) affif_read();
    instruction_decoder_if idif();
    instruction_reg_if irif();
    tap_ctrl_if tcif();
    output_logic_if olif();

    /* Module instantiations */
    adder_Nbit     ADDER(adif);
    bsr            BSR(jtif.TCK, jtif.TRST, bsrif);
    idr            IDR(jtif.TCK, jtif.TRST, idrif);
    bpr            BPR(jtif.TCK, jtif.TRST, bprif);
    instruction_decoder  INS_DECODE(jtif.TCK, jtif.TRST, idif);
    instruction_reg      INS_REG(jtif.TCK, jtif.TRST, irif);
    ahb_fifo_read #(.DATA_WIDTH(DATA_WIDTH)) AHB_READ(affif.rclk, arif);
    afifo #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) FIFO_READ(affif_read);
    tap_ctrl             TAP_CTRL(jtif.TCK, jtif.TRST, tcif);
    output_logic         OUTPUT_LOGIC(jtif.TCK, jtif.TRST, olif);
    flex_stp_sr   #(.NUM_BITS(32), .SHIFT_MSB(0))   SHIFT_REGISTER  (jtif.TCK, jtif.TRST, tcif.dr_shift, olif.TDO, jtif.sr_parallel_out);

    /*Input Signal Assign*/
    //4-bit adder(To test the functionality of BSR)
    assign adif.n_rst = jtif.nRST;
    //assign adif.clk = jtif.clk;
    assign adif.a = bsrif.to_system_logic[BIT_WIDTH-1:0];
    assign adif.b = bsrif.to_system_logic[2*BIT_WIDTH-1:BIT_WIDTH];
    assign adif.carry_in = bsrif.to_system_logic[NUM_IN-1];
    //BSR
    assign bsrif.parallel_in = jtif.parallel_in;
    assign bsrif.parallel_system_logic_out = {adif.overflow, adif.sum};
    assign bsrif.TDI = jtif.TDI;
    assign bsrif.mode = idif.bsr_mode; // Change it when having tmp controller
    assign bsrif.dr_shift = tcif.dr_shift;
    assign bsrif.dr_capture = tcif.dr_capture;
    assign bsrif.dr_update = tcif.dr_update;
    assign bsrif.bsr_select = idif.bsr_select;
    //ID code register
    assign idrif.CaptureDR = tcif.dr_capture;
    assign idrif.ShiftDR = tcif.dr_shift;
    assign idrif.TDI = jtif.TDI;
    assign idrif.idr_select = idif.id_select;
    assign idrif.tlr_reset = tcif.tap_reset;
    //Bypass register
    assign bprif.ShiftDR = tcif.dr_shift;
    assign bprif.TDI = jtif.TDI;
    assign bprif.bpr_select = idif.bypass_select;
    assign bprif.tlr_reset = tcif.tap_reset;
    // AHB READ
    assign arif.tlr_reset = tcif.tap_reset;
    assign arif.dr_shift = tcif.dr_shift;
    assign arif.ahb_fifo_read_select = idif.ahb_fifo_read_select;
    assign arif.empty = affif_read.empty;
    assign arif.rdata = affif_read.rdata;
    // AHB AP
    
    // Asynchronous FIFO for storing the data returned from AHB (Unfinished assign signals)
    assign affif_read.rinc = arif.rinc;
    assign affif_read.rclk = jtif.TCK;
    assign affif_read.wclk = jtif.clk;
    assign affif_read.r_nrst = ~tcif.tap_reset;
    assign affif_read.w_nrst = jtif.nRST;
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
    assign olif.bypass_out = bprif.TDO;
    assign olif.idcode = idrif.TDO;
    assign olif.ir_shift = tcif.ir_shift;
    assign olif.instr_out = irif.TDO;
    assign olif.ahb_read = arif.TDO;
    assign olif.instruction = irif.parallel_out;
    assign olif.tlr_reset = tcif.tap_reset;
    // JTAG output
    assign jtif.TDO = olif.TDO;
    assign jtif.parallel_out = bsrif.to_output_pin;

endmodule