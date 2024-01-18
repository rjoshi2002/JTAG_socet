import uvm_pkg::*;
`include "uvm_macros.svh"
`include "jtag_if.vh"

class jtag_monitor extends uvm_monitor;
  `uvm_component_utils(jtag_monitor)

  virtual jtag_if vif;

  uvm_analysis_port#(jtag_transaction) jtag_ap;   // Port to predictor
  uvm_analysis_port#(jtag_transaction) result_ap; // Port to comparator
  jtag_transaction prev_tx; // check if new transaction has been sent

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
    jtag_ap = new("jtag_ap", this);
    result_ap = new("result_ap", this);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual jtag_if)::get(this, "", "jtag_vif", vif)) begin
      `uvm_fatal("Monitor", "No virtual interface specified for this monitor instance")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    prev_tx = jtag_transaction#(5,9,5)::type_id::create("prev_tx");
    forever begin
      jtag_transaction tx;
      tx = jtag_transaction#(5,9,5)::type_id::create("tx");
      @(negedge vif.TCK);
      // Capture activity between the driver and DUT
      tx.parallel_in = vif.parallel_in;
      tx.instruction = vif.instruction;
      tx.tap_series = vif.tap_series;
      if (!tx.input_equal(prev_tx)) begin // if new transaction has been sent
        jtag_ap.write(tx);
        // get outputs from DUT and send to scoreboard/comparator
        // wait until check is asserted
        while(!vif.capture_check) begin
            @(negedge vif.TCK);
        end
        tx.capture_system_logic_out = vif.parallel_out;
        while(!vif.scan_check) begin
            @(negedge vif.TCK);
        end
        tx.scan_system_logic_out = vif.parallel_out;
        result_ap.write(tx);
        prev_tx.copy(tx);
      end
    end
  endtask: run_phase
endclass: jtag_monitor
