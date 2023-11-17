//Author: Rohan Joshi
// Adapted from IEEE 1149.1
// tmp_status_reg (status register for boundary scan cells)
//inputs: 
//  tmp_state:      signal from tmp_controller
//  capture_dr:     signal from TAP controller (THIS MAY HAVE TO BE IR NOT SURE)
//  TDI:            JTAG serial input
//  shift_dr:       singal from TAP controller (THIS MAY HAVE TO BE IR NOT SURE)
//  TCK:            JTAG clock signal
//  TRST:           JTAG reset signal
//outputs:
//  tmp_tdo:        Output of status register showing TMP status 0 for OFF 1 for ON
//  bypass_escape:  Bypass escape bit signal which keep TMP on 

module tmp_status_reg
(
    input logic tmp_state, capture_dr, TDI, shift_dr, TCK, TRST,
    output logic tmp_tdo, bypass_escape
);

logic d0, d1, q0, q1;

always_ff @( posedge TCK, negedge TRST ) begin : ff
    if(TRST == 1'b0)
    begin
        q0 <= 1'b0;
        q1 <= 1'b0;
    end
    else
    begin
        q0 <= d0;
        q1 <= d1;
    end
end

always_comb begin : combLog
    d0 = q0;
    d1 = q1;

    if(capture_dr == 1'b1)
    begin
        d0 = tmp_state;
    end

    if(shift_dr == 1'b1)
    begin
        d1 = q0;
        d0 = TDI;
    end

end

endmodule