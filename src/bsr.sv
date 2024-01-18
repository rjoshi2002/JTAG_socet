// Design
// bsr output cell (for input, parallel_in and parallel_out must be reversed)
//parallel_in: parallel input coming from core
//scan_in: input from prior boundary scan cell in chain
//shift_dr: shift_dr sets first mux to either shift from scan in or use parallel input
//capture_dr: ? is this TCK can't find information
//update_dr: updates the flip flop holding output information
//mode: sets the boundary scan cell mode to observe or control mode
//TRST: reset signal for JTAG module
//scan_out: output from captured value to next bsr cell
//parallel_out: output from cell to IO
// Do we need tlr_reset in bsr?
`include "bsr_if.vh"
`include "jtag_types_pkg.vh"
module bsr(
    input TCK, TRST, 
    bsr_if.BSR bsrif
);
  parameter NUM_IN = 9;
  parameter NUM_OUT = 5;
  integer i, j;

  logic [NUM_IN - 1: 0] scan1; // Signals on the Capture/Scan FF (bsr_in)
  logic [NUM_OUT - 1: 0] scan2; // Signals on the Capture/Scan FF (bsr_out)
  logic [NUM_IN - 1: 0] nxt_scan1;
  logic [NUM_OUT - 1: 0] nxt_scan2;
  logic [NUM_IN - 1: 0] outputff1; // Signals on the Output FF (bsr_in)
  logic [NUM_OUT - 1: 0] outputff2; // Signals on the Output FF (bsr_out)
  logic [NUM_IN - 1: 0] nxt_outputff1;
  logic [NUM_OUT - 1: 0] nxt_outputff2;

  //TDO
  assign bsrif.TDO = scan2[NUM_OUT-1];

  //capture flip flop
  always_ff @(posedge TCK, negedge TRST)
  begin
    if (TRST == 1'b0) begin
      // Asynchronous reset when reset goes low
      scan1 <= '0;
      scan2 <= '0;
    end else begin
      // Assign D to Q on positive clock edge
      scan1 <= nxt_scan1;
      scan2 <= nxt_scan2;
    end
  end
  
  // Capture FF input
  always_comb begin : NXT_SCAN_LOGIC 
    nxt_scan1 = scan1;
    nxt_scan2 = scan2;
    if(bsrif.dr_capture && bsrif.bsr_select) begin // Capture from system input pin and system logic output
      nxt_scan1 = bsrif.parallel_in;
      nxt_scan2 = bsrif.parallel_system_logic_out;
    end
    else if(bsrif.dr_shift && bsrif.bsr_select) begin // Data Scan in from TDI
      nxt_scan1[0] = bsrif.TDI;
      for(i = 1; i < NUM_IN; i++) begin
        nxt_scan1[i] = scan1[i-1];
      end
      nxt_scan2[0] = scan1[NUM_IN-1];
      for(j = 1; j < NUM_OUT; j++) begin
        nxt_scan2[j] = scan2[j-1];
      end
    end
  end

  //output flip flop
  always_ff @(negedge TCK, negedge TRST) // Parallel output update at negative edge of TCK
  begin
    if (TRST == 1'b0) begin
      // Asynchronous reset when reset goes low
      outputff1 <= '0;
      outputff2 <= '0;
    end 
    else begin
      // Assign D to Q on positive clock edge
      outputff1 <= nxt_outputff1;
      outputff2 <= nxt_outputff2;
    end
  end
  
  // Output ff input logic
  always_comb begin: NXT_BSR_OUTPUT 
    if(bsrif.dr_update && bsrif.bsr_select) begin
      nxt_outputff1 = scan1;
      nxt_outputff2 = scan2;
    end
    else begin
      nxt_outputff1 = outputff1;
      nxt_outputff2 = outputff2;
    end
  end

  // Mode MUX
  always_comb begin : MODE_MUX
    if(bsrif.mode) begin
      bsrif.to_system_logic = outputff1;
      bsrif.to_output_pin = outputff2;
    end
    else begin
      bsrif.to_system_logic = bsrif.parallel_in;
      bsrif.to_output_pin = bsrif.parallel_system_logic_out;
    end
  end
  
endmodule