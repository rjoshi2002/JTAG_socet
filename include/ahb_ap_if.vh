/* Linda Zhang
    ahb access point interface
*/ 

`ifndef AHB_AP_IF_VH
`define AHB_AP_IF_VH

interface ahb_ap_if;
    // import types
    import jtag_types_pkg::*;

    logic en, full, busy; 
    logic [31:0] rdata; 
    logic [41:0] ahb_reg_data; 
    logic ack, wen_buf, ren, wen_ahb, byte_en; 
    logic [31:0] wdata_ahb, wdata_buf, addr; 

    modport ap (
        input en, data, full, busy, rdata, 
        output ack, wdata_buf, wen_buf, addr, ren, wen_ahb, wdata_ahb, byte_en
    );

endinterface
`endif // AHB_AP_IF_VH