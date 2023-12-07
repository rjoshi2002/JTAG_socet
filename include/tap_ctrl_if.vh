/* 
    Current Author: Linda Zhang 
    Modified from Fall 2019 - Spring 2020 JTAG team 
    Code from Fred Owens, Xianmeng Zhang 
*/ 
`ifndef TAP_CTRL_IF_VH
`define TAP_CTRL_IF_VH

interface tap_ctrl_if;
    // import types 
    import jtag_types_pkg::*;

    logic TMS; 
    logic tap_state_uir;
    logic ir_update, ir_shift, ir_capture;
    logic dr_capture, dr_shift, dr_update;  
    logic tap_reset;
    modport tap (
        input TMS, 
        output tap_state_uir, 
		ir_shift, ir_update, ir_capture, 
		dr_shift, dr_update, dr_capture,
		tap_reset 
    );

endinterface 
`endif // TAP_CTRL_IF_VH
