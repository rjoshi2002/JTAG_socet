/* Testbench connecting AHB access point and AHB master 
    author: Linda Zhang 
    AHB manager works as the AHB master 
    source code from AHB on AFTx07 SoCET team 
    Note: we modified the interface to allow setting up hready 
*/ 

`timescale 1ns / 1ns
`include "ahb_ap_if.vh"
// `include "generic_bus_if.vh"
// `include "bus_protocol_if.sv"
`include "ahb_if.sv"
`include "jtag_types_pkg.vh"

module tb_ahb_master;

    localparam CLK_PERIOD = 10;

    logic AFT_CLK = 0;
    logic nRST;

    always #(CLK_PERIOD/2) AFT_CLK++; 

    ahb_ap_if apif();
    // generic_bus_if gbif();
    bus_protocol_if busif(); 
    ahb_if ahbif (.HCLK(AFT_CLK), .HRESETn(nRST));  
    

    test #(.PERIOD(CLK_PERIOD)) PROG (
        .AFT_CLK(AFT_CLK), .nRST(nRST), .apif(apif), .busif(busif), .ahbif(ahbif.jtag_temp) //.gbif(gbif)
    ); 
        
    ahb_ap DUT( .AFT_CLK(AFT_CLK), .nRST(nRST), .apif(apif), .busif(busif));
    ahb_manager ahb_m (.busif(busif), .ahbif(ahbif.jtag_temp)); 

endmodule

program test #(parameter PERIOD = 10)(
    input logic AFT_CLK, output logic nRST, ahb_ap_if apif, bus_protocol_if busif, ahb_if ahbif
); 
    import jtag_types_pkg::*; 
    // parameter PERIOD;
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
    input logic [31:0] addr; 
begin
    if (ahbif.HWDATA != wdata) begin
        $display("Test failed: Address does not match.");
        // $stop;
    end
    if (ahbif.HWRITE != wen) begin
        $display("Test failed: Write Enable not asserted.");
        // $stop;
    end
    if(ahbif.HWSTRB != byte_en) begin
        $display("Test failed: byte enable does not match.");
        // $stop; 
    end 
    if(ahbif.HADDR != addr) begin
        $display("Test failed: write address incorrect.");
        // $stop; 
    end
end
endtask

task check_fifo_output; 
    input logic [31:0] wdata;
    // input logic winc; 
begin
    if(apif.wdata_fifo2 != wdata) begin
        $display("Test failed: write to fifo is wrong");
        // $stop;
    end
end
endtask

initial begin
    tb_test_num = 0; 
    tb_test_case = "Reset"; 
    nRST = 1'b1; 
    apif.rdata_fifo1 = 41'b0;
    apif.rempty = 1;
    apif.wfull = 0; 
    ahbif.HRESP = 0; 
    ahbif.HREADYOUT = 0;  
    ahbif.HRDATA = '0; 

    reset_dut; 

    tb_test_num++; 
    tb_test_case = "Write wdata to AHB (byte)";

    reset_dut; 

    apif.rdata_fifo1 = {32'hABCD1234, 1'b1, 2'd0, 5'd0, 1'b1}; 
    apif.rempty = 0; 
    ahbif.HREADYOUT = 1; 
    ahbif.HRESP = 1; 
    @(posedge AFT_CLK); 
    // apif.rempty = 1; 
    #(PERIOD * 32); 
    // busif.request_stall = 1; 
    apif.wfull = 0; 
    
    
    check_ahb_output(32'hABCD1234, 1'b1, 4'd0, '0); 
    apif.rempty = 0; 
    reset_dut; 
    tb_test_num++; 
    tb_test_case = "read data from AHB (byte) and write to fifo2";

    apif.rdata_fifo1 = {32'h0, 1'b1, 8'b0, 1'b0}; 
    ahbif.HRDATA = 32'h12345678; 
    apif.rempty = 0; 
    @(posedge AFT_CLK); 
    #(PERIOD * 2); 
    apif.wfull = 0; 
    // apif.rempty = 1; 
    @(posedge AFT_CLK); 
    apif.wfull = 1; 
    ahbif.HRDATA = 32'h0000abcd;
    apif.wfull = 0; 
    #(PERIOD * 32); 
    // check_fifo_output(32'h12345678);

    reset_dut; 
    tb_test_num++; 
    tb_test_case = "write addr to ahb"; 

    apif.rempty = 1; 
    ahbif.HRDATA = '0; 
    ahbif.HREADYOUT = 1; 
    ahbif.HRESP = 1; 
    apif.rdata_fifo1 = {32'h12345678, 1'b0, 2'b11, 5'd0,1'b1}; 
    @(posedge AFT_CLK); 
    #(PERIOD*32);
    ahbif.HREADYOUT = 1; 
    apif.rempty = 0; 
    @(posedge AFT_CLK); 
    ahbif.HREADYOUT = 0; 
    apif.rempty = 1; 
    ahbif.HREADYOUT = 1; 
    apif.rdata_fifo1 = {32'h456789ab, 1'b1, 2'b11, 5'd0, 1'b1}; 
    apif.rempty = 0; 
    ahbif.HREADYOUT = 1; 
    ahbif.HRESP = 1; 
    @(posedge AFT_CLK); 
    // apif.rempty = 1; 
    #(PERIOD * 32); 
    // busif.request_stall = 1; 
    apif.wfull = 0; 
    check_ahb_output(32'h456789ab, 1'b1, 4'b1111, 32'h12345678); 

    // Finish the simulation
    // $display("All tests passed.");
    // $finish;
end
endprogram
