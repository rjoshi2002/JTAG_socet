import uvm_pkg::*;
`include "uvm_macros.svh"
`include "transaction.svh"

class extest_sequence extends uvm_sequence#(jtag_transaction);
  `uvm_object_utils(extest_sequence)

  function new(string name = "");
    super.new(name);
  endfunction: new

  task body();
    jteg_transaction req_item;
    req_item = jteg_transaction::type_id::create("req_item");

    // repeat 25 randomized test cases
    repeat(25) begin
      start_item(req_item);
      if(!req_item.randomize()) begin
        `uvm_fatal("Sequence", "Not able to randomize")
      end
      req_item.instruction = 5'b00011; // EXTEST
      finish_item(req_item);
    end
  endtask: body
endclass



class sequencer extends uvm_sequencer#(transaction);
  `uvm_component_utils(sequencer)

  function new(input string name = "sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
endclass: sequencer
