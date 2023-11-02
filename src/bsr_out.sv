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

module bsr_out (
    input logic parallel_in, scan_in, shift_dr, capture_dr, update_dr, mode, TRST, 
    output logic scan_out, parallel_out);
  

  logic d_0;
  logic q_0;
  logic d_1;
  logic q_1;

  assign scan_out = q_0;

  //capture flip flop
  always @(posedge capture_dr or negedge TRST)
  begin
    if (TRST == 1'b0) begin
      // Asynchronous reset when reset goes low
      q_0 <= 1'b0;
    end else begin
      // Assign D to Q on positive clock edge
      q_0 <= d_0;
    end
  end
  
  //update cell flip flop
  always @(posedge update_dr or negedge TRST)
  begin
    if (TRST == 1'b0) begin
      // Asynchronous reset when reset goes low
      q_1 <= 1'b0;
    end else begin
      // Assign D to Q on positive clock edge
      q_1 <= d_1;
    end
  end
  
  always comb
  begin
    d_1 = q_0;
    d_0 = parallel_in;
  	parallel_out = parallel_in;
    if(mode == 1'b1)
    begin
    	parallel_out = q_1;    
    end
    if(shift_dr == 1'b1)
    begin
    	d_0 = scan_in;    
    end
  end
  
endmodule