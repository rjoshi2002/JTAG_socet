// Flex adder, default width of 4 bits
// Tested DUT, used to test the functionality of BSR of JTAG

`include "adder_if.vh"

module adder_Nbit #(parameter BIT_WIDTH = 4) (adder_if.adder add_if);
  always_ff @(posedge add_if.clk, negedge add_if.n_rst) begin
    if(add_if.n_rst) begin
      {add_if.overflow, add_if.sum} <= (add_if.a + add_if.b + add_if.carry_in);
    end
    else begin
      add_if.sum <= 0;
      add_if.overflow <= 0;
    end
  end
endmodule
