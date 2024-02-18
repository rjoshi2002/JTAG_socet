import uvm_pkg::*;
`include "uvm_macros.svh"
`include "jtag_if.vh"

class jtag_driver extends uvm_driver#(jtag_transaction);
  `uvm_component_utils(jtag_driver)

  virtual jtag_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // get interface
    if(!uvm_config_db#(virtual jtag_if)::get(this, "", "jtag_vif", vif)) begin
      `uvm_fatal("Driver", "No virtual interface specified for this test instance");
    end
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    jtag_transaction req_item;
    forever begin
      seq_item_port.get_next_item(req_item);
      vif.parallel_in = req_item.parallel_in;
      vif.instruction = req_item.instruction;
      vif.tap_series = req_item.tap_series;
      DUT_reset();
      vif.TMS = 1'b0;
      @(negedge vif.TCK); // IDLE
      set_instr(req_item.instruction);
      if(req_item.instruction == 5'b00011) begin //EXTEST
        dr_capture(); // Capture the parallel input to adder
        dr_capture(); // Capture the adder output 
        vif.capture_check = 1;
        @(negedge vif.TCK); // IDLE
        dr_scanin(req_item.tap_series, 14); // Scan in the adder input through TDI
        dr_capture(); // Capture the adder output 
        vif.scan_check = 1;
        @(negedge vif.TCK); // IDLE
      end
      else if(req_item.instruction == 5'b00010) begin // PRELOAD
        dr_capture(); // Capture the parallel input and system output and update them to output register
        vif.capture_check = 1;
        @(negedge vif.TCK); // IDLE
        dr_scanin(req_item.tap_series, 14); // Scan in the adder input through TDI
        dr_capture(); // Capture the adder output 
        vif.scan_check = 1;
        @(negedge vif.TCK); // IDLE
      end
      else if(req_item.instruction == 5'b00100) begin // IDCODE
        dr_scanin('1, 32);
        vif.id_check = 1;
        @(negedge vif.TCK); // IDLE
      end
      #(0.2)
      @(negedge vif.TCK);
      seq_item_port.item_done();
    end
  endtask: run_phase

  task DUT_reset();
    vif.capture_check = 0;
    vif.scan_check = 0;
    vif.id_check = 0;
    vif.TRST = 0;
    vif.nRST = 0;
    vif.TMS = 1;
    @(negedge vif.TCK);
    @(negedge vif.TCK);
    vif.TRST = 1;
    vif.nRST = 1;
    @(negedge vif.TCK);
  endtask

  task set_instr;
  input logic [4:0] instruction;
  begin
    vif.TMS = 1'b1;
    @(negedge vif.TCK); // Select DR Scan state
    vif.TMS = 1'b1;
    @(negedge vif.TCK); // Select IR Scan state
    vif.TMS = 1'b0;
    @(negedge vif.TCK); // Capture IR state
    vif.TMS = 1'b0;
    @(negedge vif.TCK); // Shift IR state
    for(int i = 0; i < 5; i++) begin
      vif.TDI = instruction[i]; // Shift in LSB first
      if(i == 4)
          vif.TMS = 1'b1;
      @(negedge vif.TCK);
    end
    vif.TMS = 1'b1;
    @(negedge vif.TCK); // IR_Update
    vif.TMS = 1'b0;
    @(negedge vif.TCK); // Go back to IDLE state
  end
  endtask

  task dr_capture;
  begin
    vif.TMS = 1'b1;
    @(negedge vif.TCK); // Select DR Scan state
    vif.TMS = 1'b0;
    @(negedge vif.TCK); // Capture DR state
    vif.TMS = 1'b1;
    @(negedge vif.TCK); // Exit1 state
    vif.TMS = 1'b1;
    @(negedge vif.TCK); // Update DR state
    vif.TMS = 1'b0;
    @(negedge vif.TCK); // IDLE
  end
  endtask

  task dr_scanin;
  input logic [13:0] data;
  input integer times;
  begin
    vif.TMS = 1'b1;
    @(negedge vif.TCK);
    vif.TMS = 1'b0;
    @(negedge vif.TCK); // Capture DR
    vif.TMS = 1'b0;
    @(negedge vif.TCK); // Shift DR
    for(int i = 0; i < times; i++) begin
      if(i < 14)
        vif.TDI = data[i]; // Shift in LSB first
      else
        vif.TDI = 1'b1;
      if(i == times - 1)
        vif.TMS = 1'b1;
      @(negedge vif.TCK);
    end
    vif.TMS = 1'b1;
    @(negedge vif.TCK); // Update DR
    vif.TMS = 1'b0;
    @(negedge vif.TCK); // Go back to IDLE state
  end
  endtask
endclass: jtag_driver
