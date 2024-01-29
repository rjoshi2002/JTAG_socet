import uvm_pkg::*;
`include "uvm_macros.svh"
`include "transaction.svh"

class extest_sequence extends uvm_sequence#(jtag_transaction);
  `uvm_object_utils(extest_sequence)

  function new(string name = "");
    super.new(name);
  endfunction: new

  task body();
    jtag_transaction req_item;
    req_item = jtag_transaction#(5,9,5)::type_id::create("req_item");

    // repeat 100 randomized test cases
    repeat(100) begin
      start_item(req_item);
      if(!req_item.randomize()) begin
        `uvm_fatal("Sequence", "Not able to randomize")
      end
      req_item.instruction = 5'b00011; // EXTEST
      finish_item(req_item);
    end
  endtask: body
endclass

class preload_sequence extends uvm_sequence#(jtag_transaction);
  `uvm_object_utils(preload_sequence)

  function new(string name = "");
    super.new(name);
  endfunction: new

  task body();
    jtag_transaction req_item;
    req_item = jtag_transaction#(5,9,5)::type_id::create("req_item");

    // repeat 100 randomized test cases
    repeat(100) begin
      start_item(req_item);
      if(!req_item.randomize()) begin
        `uvm_fatal("Sequence", "Not able to randomize")
      end
      req_item.instruction = 5'b00010; // PRELOAD
      finish_item(req_item);
    end
  endtask: body
endclass



class sequencer extends uvm_sequencer#(jtag_transaction);
  `uvm_component_utils(sequencer)

  function new(input string name = "sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
endclass: sequencer
