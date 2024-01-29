`ifndef TRANSACTION_SVH
`define TRANSACTION_SVH

import uvm_pkg::*;
`include "uvm_macros.svh"

class jtag_transaction #(parameter INSTRUCTION_BITS = 5, parameter NUM_IN = 9, parameter NUM_OUT = 5) extends uvm_sequence_item;
  rand bit [INSTRUCTION_BITS - 1:0] instruction;
  rand bit [NUM_IN - 1: 0] parallel_in; // ADDER parallel in
  rand bit [NUM_IN + NUM_OUT - 1:0] tap_series;
  bit [NUM_OUT - 1:0] capture_system_logic_out;
  bit [NUM_OUT - 1:0] scan_system_logic_out;
  bit [NUM_OUT + NUM_IN -1: 0] sr_parallel_out;

  `uvm_object_utils_begin(jtag_transaction)
    `uvm_field_int(instruction, UVM_NOCOMPARE)
    `uvm_field_int(parallel_in, UVM_NOCOMPARE)
    `uvm_field_int(tap_series, UVM_NOCOMPARE)
    `uvm_field_int(capture_system_logic_out, UVM_DEFAULT)
    `uvm_field_int(scan_system_logic_out, UVM_DEFAULT)
    `uvm_field_int(sr_parallel_out, UVM_DEFAULT)
  `uvm_object_utils_end

  // add constrains for randomization

  function new(string name = "jtag_transaction");
    super.new(name);
  endfunction: new

  // if two transactions are the same, return 1
  function int input_equal(jtag_transaction tx);
    int result;
    if((instruction == tx.instruction) && (parallel_in == tx.parallel_in) && (tap_series == tx.tap_series)) begin
      result = 1;
      return result;
    end
    else
      result = 0;
    return result;
  endfunction
endclass

`endif
