/* Made by Wen-Bo Hung and Rohan Joshi, 2023/11/2
   SoCET JTAG team
*/

`ifndef BSR_IF_VH
`define BSR_IF_VH
// Default num of input and output pins are adder's pin
interface bsr_if #(parameter NUM_IN = 9, parameter NUM_OUT = 5);
import jtag_types_pkg::*;
	logic [NUM_IN - 1: 0] parallel_in;
    logic [NUM_OUT - 1: 0] parallel_system_logic_out;
    logic [NUM_IN - 1: 0] to_system_logic;
    logic [NUM_OUT - 1: 0] to_output_pin
    logic TDI, TDO;
    logic mode;
    logic dr_shift, dr_capture, dr_update;
    logic bsr_select;
    //logic tlr_reset;

	modport BSR
	(
		input parallel_in, parallel_system_logic_out, TDI, mode, dr_shift, dr_capture, dr_update, bsr_select, 
		output to_system_logic, to_output_pin, TDO
	);
endinterface

`endif //BSR_IF_VH