import uvm_pkg::*;
`include "uvm_macros.svh"
`include "transaction.svh"

class jtag_predictor extends uvm_subscriber#(jtag_transaction);
  `uvm_component_utils(jtag_predictor)

  uvm_analysis_port#(jtag_transaction) pred_ap;
  jtag_transaction output_tx;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    pred_ap = new("pred_ap", this);
  endfunction

  function void write(jtag_transaction t);
    output_tx = jtag_transaction#(5,9,5)::type_id::create("output_tx", this);
    output_tx.copy(t);

    // calculate expected sum and expected overflow
    output_tx.capture_system_logic_out = (t.parallel_in[3:0] + t.parallel_in[7:4] + t.parallel_in[8]);
    output_tx.scan_system_logic_out = (t.tap_series[3:0] + t.tap_series[7:4] + t.tap_series[8]);
    // send expected output to scoreboard
    pred_ap.write(output_tx);
  endfunction: write
endclass: jtag_predictor
