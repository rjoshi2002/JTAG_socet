`ifndef ADDER_IF_SVH
`define ADDER_IF_SVH

interface adder_if #(parameter BIT_WIDTH = 4) (input logic clk);
  logic n_rst;

  logic [BIT_WIDTH - 1:0] a;
  logic [BIT_WIDTH - 1:0] b;
  logic carry_in;

  logic [BIT_WIDTH - 1:0] sum;
  logic overflow;
  
  logic check = 1;

  modport tester
  (
    input sum, overflow, clk,
    output n_rst, a, b, carry_in
  );

  modport adder
  (
    output sum, overflow,
    input n_rst, a, b, carry_in, clk
  );
endinterface

`endif
