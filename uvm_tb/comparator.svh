import uvm_pkg::*;
`include "uvm_macros.svh"

class comparator extends uvm_scoreboard;
  `uvm_component_utils(comparator)

  uvm_analysis_export#(jtag_transaction) expected_export; // to recieve result from predictor
  uvm_analysis_export#(jtag_transaction) actual_export; // to recieve result from DUT
  uvm_tlm_analysis_fifo#(jtag_transaction) expected_fifo;
  uvm_tlm_analysis_fifo#(jtag_transaction) actual_fifo;

  int m_matches, m_mismatches; // number of matches and mismatches

  function new(string name, uvm_component parent);
    super.new(name, parent);
    m_matches = 0;
    m_mismatches = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    expected_export = new("expected_export", this);
    actual_export = new("actual_export", this);
    expected_fifo = new("expected_fifo", this);
    actual_fifo = new("actual_fifo", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    expected_export.connect(expected_fifo.analysis_export);
    actual_export.connect(actual_fifo.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    jtag_transaction expected_tx;
    jtag_transaction actual_tx;
    forever begin
      expected_fifo.get(expected_tx);
      actual_fifo.get(actual_tx);
      uvm_report_info("Comparator", $psprintf("\nExpected:\nresult_sum: %d\nresult_overflow: %d\n~~~~~~~~~~\nActual:\nsum: %d\noverflow: %d\n", expected_tx.result_sum, expected_tx.result_overflow, actual_tx.result_sum, actual_tx.result_overflow));

      // keep count of number of matches and mismatches (actual vs expected)
      if (expected_tx.compare(actual_tx)) begin
        m_matches++;
        uvm_report_info("Comparator", "Data match");
      end else begin
        m_mismatches++;
        uvm_report_info("Comparator", "Error: Data mismatch");
      end
    end
  endtask

  function void report_phase(uvm_phase phase);
    uvm_report_info("Comparator", $sformatf("Matches:    %0d", m_matches), UVM_LOW);
    uvm_report_info("Comparator", $sformatf("Mismatches: %0d", m_mismatches), UVM_LOW);
  endfunction
endclass
