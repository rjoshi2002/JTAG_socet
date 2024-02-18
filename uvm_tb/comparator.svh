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
      if((expected_tx.instruction == 5'b00010) || (expected_tx.instruction == 5'b00011)) // EXTEST and PRELOAD
        uvm_report_info("Comparator", $psprintf("\nExpected:\ncapture_system_logic_out: %d\nscan_system_logic_out: %d\n~~~~~~~~~~\nActual:\ncapture_system_logic_out: %d\nscan_system_logic_out: %d\n", expected_tx.capture_system_logic_out, expected_tx.scan_system_logic_out, actual_tx.capture_system_logic_out, actual_tx.scan_system_logic_out), UVM_LOW);
      else if(expected_tx.instruction == 5'b00100) // IDCODE
        uvm_report_info("Comparator", $psprintf("\nExpected:\nid_code: %d\n~~~~~~~~~~\nActual:\nid_code: %d\n", expected_tx.id_code, actual_tx.id_code), UVM_LOW);
      // keep count of number of matches and mismatches (actual vs expected)
      if (expected_tx.compare(actual_tx)) begin
        m_matches++;
        uvm_report_info("Comparator", "Data match", UVM_LOW);
      end else begin
        m_mismatches++;
        uvm_report_info("Comparator", "Error: Data mismatch", UVM_LOW);
      end
    end
  endtask

  function void report_phase(uvm_phase phase);
    uvm_report_info("Comparator", $sformatf("Matches:    %0d", m_matches), UVM_LOW);
    uvm_report_info("Comparator", $sformatf("Mismatches: %0d", m_mismatches), UVM_LOW);
  endfunction
endclass
