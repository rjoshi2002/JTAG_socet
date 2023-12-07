import uvm_pkg::*;
`include "uvm_macros.svh"
`include "environment.svh"


class extest_test extends uvm_test;
  `uvm_component_utils(extest_test)

  environment env;
  virtual jtag_if vif;
  extest_sequence seq;

  function new(string name = "extest_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = environment::type_id::create("env", this);
    seq = extest_sequence::type_id::create("seq", this);

    // send interface down
    if (!uvm_config_db#(virtual jtag_if)::get(this, "", "jtag_vif", vif)) begin
      `uvm_fatal("Test", "No virtual interface specified for this test instance")
    end

    uvm_config_db#(virtual jtag_if)::set(this, "env.agt*", "jtag_vif", vif);
  endfunction: build_phase

  task main_phase(uvm_phase phase);
    phase.raise_objection(this, "Starting sequence in main phase");
    $display("%t Starting sequence run_phase", $time);
    seq.start(env.agt.sqr);
    #100ns;
    phase.drop_objection(this, "Finished in main phase");
  endtask
endclass: extest_test
