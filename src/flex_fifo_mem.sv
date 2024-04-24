// Developed by Karthik Maiya, Xianmeng Zhang, Feb 15 2020 
// JTAG SoCET team
`include "flex_fifo_mem_if.vh"
`include "jtag_types_pkg.vh"
module flex_fifo_mem #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 32)(
    flex_fifo_mem_if.FIFO ffif
);

logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH-1:0];

always @(posedge ffif.wclk) begin
    if (ffif.wclk_en) 
        mem[ffif.waddr] <= ffif.wdata;
end

assign ffif.rdata = mem[ffif.raddr];

// initial begin
//     $srandom('d555);
//     for(int i = 0; i < 2**ADDR_WIDTH; i++) begin
//         mem[i] = $urandom();
//     end

// end


endmodule