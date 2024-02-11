/* Wen-Bo Hung, 2024/02/10
    email: hong395@purdue.edu*/
// JTAG SoCET team
`include "fifo_if.vh"
`include "jtag_types_pkg.vh"
module fifo#(
    parameter WIDTH = 8,
    parameter DEPTH = 64
)(
    input TCK, TRST, 
    fifo_if.FIFO ffif
);
  //FIFO Storage
  logic [WIDTH-1:0] buffer [DEPTH-1:0];
  // Pointers for read and write
  logic [$clog2(DEPTH):0] wr_ptr;
  logic [$clog2(DEPTH):0] rd_ptr;

  // Full and empty flags
  // the last slot of FIFO is intentionally kept empty, so we can write full = (rd_ptr == (wr_ptr + 1'b1))
  assign ffif.full = (rd_ptr == (wr_ptr + 1'b1));
  assign ffif.empty = (wr_ptr == rd_ptr);

  // Write logic
  always_ff @(posedge TCK, negedge TRST) begin
    if (!TRST)
      wr_ptr <= 0;
    else if (ffif.wr_en && !ffif.full)
      wr_ptr <= wr_ptr + 1'b1;
  end
    
  // Read logic
  always_ff @(posedge TCK, negedge TRST) begin
    if (!TRST)
      rd_ptr <= 0;
    else if (ffif.rd_en && !ffif.empty)
      rd_ptr <= rd_ptr + 1'b1;
  end

  // Read and write data
  always_comb begin
    ffif.data_out = buffer[rd_ptr];
  end

  always_ff @(posedge TCK, negedge TRST) begin
    if (!TRST)
      buffer[0] <= 0; 
    else if (ffif.wr_en && !ffif.full)
      buffer[wr_ptr] <= ffif.data_in;
  end
    
  
endmodule