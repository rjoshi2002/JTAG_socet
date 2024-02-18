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
  logic [$clog2(DEPTH)-1:0] wr_ptr;
  logic [$clog2(DEPTH)-1:0] nxt_wr_ptr;
  logic [$clog2(DEPTH)-1:0] rd_ptr;
  logic [$clog2(DEPTH)-1:0] nxt_rd_ptr;

  // Full and empty flags
  // the last slot of FIFO is intentionally kept empty, so we can write full = (rd_ptr == (wr_ptr + 1'b1))
  assign ffif.full = ((wr_ptr + 1'b1) == rd_ptr);
  assign ffif.empty = (wr_ptr == rd_ptr);

  // Write logic
  always_ff @(posedge TCK, negedge TRST) begin
    if (!TRST)
      wr_ptr <= 0;
    else
      wr_ptr <= nxt_wr_ptr;
  end
    
  always_comb begin : NXT_WR_PTR
    nxt_wr_ptr = wr_ptr;
    if(ffif.wr_en && !ffif.full) begin
      if(wr_ptr == 6'b111111)
        nxt_wr_ptr = 6'b1;
      else
        nxt_wr_ptr = wr_ptr + 1;
    end
      
  end

  // Read logic
  always_ff @(posedge TCK, negedge TRST) begin
    if (!TRST)
      rd_ptr <= 0;
    else
      rd_ptr <= nxt_rd_ptr;
  end

  always_comb begin : NXT_RD_PTR
    nxt_rd_ptr = rd_ptr;
    if(ffif.rd_en && !ffif.empty) begin
      if(rd_ptr == 6'b111111)
        nxt_rd_ptr = 6'b1;
      else
        nxt_rd_ptr = rd_ptr + 1;
    end
  end

  // Read and write data
  always_comb begin
    ffif.data_out = buffer[rd_ptr];
  end

  always_ff @(posedge TCK, negedge TRST) begin
    if (!TRST) begin
      buffer[0] <= '0;
    end
    else if (ffif.wr_en && !ffif.full)
      buffer[wr_ptr] <= ffif.data_in;
  end
    
  
endmodule