`timescale 1ns / 1ns
`include "ahb_ap_if.vh"
`include "generic_bus_if.vh"
`include "jtag_types_pkg.vh"

module tb_ahb_ap;

    localparam CLK_PERIOD = 10;

    logic AFT_CLK = 0;
    logic nRST;

    always #(CLK_PERIOD/2) AFT_CLK++; 

    ahb_ap_if apif();
    generic_bus_if gbif();

    test #(.PERIOD(CLK_PERIOD)) PROG (
        .AFT_CLK(AFT_CLK), .nRST(nRST), .apif(apif), .gbif(gbif)
    ); 
        
    ahb_ap DUT(AFT_CLK, nRST, apif, gbif);
endmodule

program test (
    input logic AFT_CLK, output logic nRST, ahb_ap_if apif, generic_bus_if gbif 
); 
    import jtag_types_pkg::*; 
    parameter PERIOD = 10; 
    int tb_test_num; 
    string tb_test_case; 

// Task for standard DUT reset procedure
task reset_dut;
begin
  // Activate the reset
  nRST = 1'b0;

  // Maintain the reset for more than one cycle
  @(posedge AFT_CLK);
  @(posedge AFT_CLK);

  // Wait until safely away from rising edge of the clock before releasing
  @(negedge AFT_CLK);
  nRST = 1'b1;

  // Leave out of reset for a couple cycles before allowing other stimulus
  // Wait for negative clock edges, 
  // since inputs to DUT should normally be applied away from rising clock edges
  @(negedge AFT_CLK);
  @(negedge AFT_CLK);
end
endtask

task check_ahb_output; 
    input logic [31:0] wdata; 
    input logic wen;
    input logic [3:0] byte_en; 
begin
    if (gbif.wdata != wdata) begin
        $display("Test failed: Address does not match.");
        $stop;
    end
    if (gbif.wen != wen) begin
        $display("Test failed: Write Enable not asserted.");
        $stop;
    end
    if(gbif.byte_en != byte_en) begin
        $display("Test failed: byte enable does not match.");
        $stop; 
    end 
end
endtask

task check_fifo_output; 
    input logic [31:0] wdata;
    // input logic winc; 
begin
    if(apif.wdata_fifo2 != wdata) begin
        $display("Test failed: write to fifo is wrong");
        $stop;
    end
    // if(apif.winc != winc) begin
    //     $display("Test failed: winc is wrong");
    //     $stop;
    // end
end
endtask

initial begin
    tb_test_num = 0; 
    tb_test_case = "Reset"; 
    nRST = 1'b1; 
    apif.rdata_fifo1 = 41'b0;
    apif.rempty = 1;
    gbif.busy = 0;

    reset_dut; 

    tb_test_num++; 
    tb_test_case = "Write wdata to AHB (byte)";

    reset_dut; 

    apif.rdata_fifo1 = {32'hABCD1234, 1'b1, 2'd0, 5'd0, 1'b1}; 
    apif.rempty = 0; 
    @(posedge AFT_CLK); 
    // apif.rempty = 1; 
    #(PERIOD * 32); 
    gbif.busy = 1; 
    
    check_ahb_output(32'hABCD1234, 1'b1, 4'd0); 
    apif.rempty = 0; 
    reset_dut; 
    tb_test_num++; 
    tb_test_case = "read data from AHB (byte) and write to fifo2";

    apif.rdata_fifo1 = {32'h0, 1'b1, 8'b0, 1'b0}; 
    gbif.rdata = 32'h12345678; 
    apif.rempty = 0; 
    @(posedge AFT_CLK); 
    // apif.rempty = 1; 
    apif.wfull = 0; 
    #(PERIOD * 32); 
    check_fifo_output(32'h12345678);

    // Finish the simulation
    $display("All tests passed.");
    $finish;
end
endprogram
