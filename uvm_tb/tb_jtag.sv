import uvm_pkg::*;
`include "jtag.sv"
`include "jtag_if.vh"
`include "test.svh"

`timescale 1 ns/1 ns

module tb_jtag();
  localparam JTAG_PERIOD = 20;
  localparam CORE_PERIOD = 10;
  logic TCK = 0, CLK = 0;

  // Clock Generation
  always #(JTAG_PERIOD) TCK++;
  always #(CORE_PERIOD) CLK++;
  
  //Interface
  jtag_if jtif();

  jtag JTAG(TCK, CLK, jtif);
  initial begin
    uvm_config_db#(virtual jtag_if)::set(null, "", "jtag_vif", jtif);
    run_test("test");
  end
endmodule
