import uvm_pkg::*;
`include "uvm_macros.svh"
`include "sequence.svh"
`include "driver.svh"
`include "monitor.svh"

class jtag_agent extends uvm_agent;
  `uvm_component_utils(jtag_agent)
  sequencer sqr;
  jtag_driver drv;
  jtag_monitor mon;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    sqr = sequencer::type_id::create("sqr", this);
    drv = jtag_driver::type_id::create("drv", this);
    mon = jtag_monitor::type_id::create("mon", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction

endclass: jtag_agent
