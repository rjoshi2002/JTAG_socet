/* Linda Zhang
    ahb access point interface
*/ 

`ifndef AHB_AP_IF_VH
`define AHB_AP_IF_VH

interface ahb_ap_if;
    // import types
    import jtag_types_pkg::*;

    
    logic rempty, rinc, wfull, winc; 
    logic [40:0] rdata_fifo1; 
    logic [31:0] wdata_fifo2, rdata_aft, wdata_aft, addr_aft; 
    
    // generic bus 
    logic busy; 
    logic ren, wen; 
    logic [3:0] byte_en; 

    modport ap (
        input rempty, wfull, rdata_fifo1, busy, rdata_fifo1, rdata_aft,
        output wdata_fifo2, wdata_aft, rinc, winc, addr_aft, ren, wen, byte_en

    );

endinterface
`endif // AHB_AP_IF_VH