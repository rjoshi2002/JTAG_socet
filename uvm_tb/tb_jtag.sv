import uvm_pkg::*;
`include "jtag.sv"
`include "jtag_if.vh"
`include "test.svh"

`timescale 1 ns/1 ns

module tb_jtag();
  localparam JTAG_PERIOD = 20;
  localparam CORE_PERIOD = 10;
  logic TCK = 0, CLK = 0;

  //Interface
  jtag_if jtif();

  // JTAG Module
  jtag JTAG(jtif);
  // Clock Generation
  //always #(JTAG_PERIOD) jtif.TCK++;
  //always #(CORE_PERIOD) jtif.clk++;
  initial begin
    jtif.clk = 0;
    forever #10 begin
       jtif.clk = ~jtif.clk;
       jtif.TCK = ~jtif.TCK;
    end
  end

  initial begin
    jtif.TCK = 0;
    forever #10 begin
       jtif.clk = ~jtif.clk;
       jtif.TCK = ~jtif.TCK;
    end
  end
  
  initial begin
    uvm_config_db#(virtual jtag_if)::set(null, "", "jtag_vif", jtif);
    run_test("test");
  end
endmodule
