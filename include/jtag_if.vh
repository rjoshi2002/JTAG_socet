// Originally from Fred Owens, Oct 2 2019
// Adapted by Wen-Bo Hung, Nov 5 2023
// jtag interface

`ifndef JTAG_IF_VH
`define JTAG_IF_VH

// import types


interface jtag_if #(parameter NUM_IN = 9, parameter NUM_OUT = 5);

    logic TCK, clk;
    logic TDO, TMS, TDI;
    logic TRST, nRST;
    //logic [4:0] scan_out; // For UVM testbench to do the test
    logic [NUM_IN - 1: 0] parallel_in;
    logic [NUM_OUT - 1: 0] parallel_out;
    logic [31: 0] sr_parallel_out; // Used for storing the TDOs.
    // jtag port

    //UVM testbench signal
    //Handshake signal between driver and monitor
    logic capture_check = 1;
    logic scan_check = 1;
    logic id_check = 1;
    // record the transaction field
    logic [4:0] instruction;
    logic [NUM_IN + NUM_OUT - 1:0] tap_series;

    modport jtag (
        input TCK, clk, TDI, TMS,  parallel_in, TRST, nRST, 
        output TDO, parallel_out, sr_parallel_out
    );

    modport tb (
        input TCK, clk, TDO,  parallel_out, sr_parallel_out, 
        output TDI, TMS,  parallel_in, TRST, nRST
    );

endinterface
`endif //JTAG_IF_VH
