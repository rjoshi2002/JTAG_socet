// Design Adapted from Prior JTAG TMP controller design by: Fred Owens
// Author: Rohan Joshi
// Adapted from IEEE 1149.1
// tmp_controller (FSM for TMP control)
//inputs: 
//  tap_reset:              test reset state of TAP
//  clamp_hold_decode:      signal if clamp hold instruction has been given
//  clamp_release_decode:   signal if clamp release instruction given
//  TCK:                    JTAG clock
//  bypass_escape:          signal if bypass escape must be activated
//  update_ir:              upate IR signal from TAP
//  bypass_decode:          signal if bypass instruction is given
//  TRST:                   JTAG reset
//outputs:
//  ch_reset:               BSR reset signal (active low)
//  tmp_state:              test mode persistence singal 0 for OFF 1 for ON

module tmp_controller 
(
    input logic tap_reset, clamp_hold_decode, clamp_release_decode, TCK, bypass_escape, update_ir, bypass_decode, TRST,
    output logic ch_reset, tmp_state
);

typedef enum logic{PERSISTENCE_OFF = 1'b0, PERSISTENCE_ON = 1'b1} tmp_state_t;

tmp_state_t state, next_state;

always_ff @( posedge TCK, negedge TRST ) begin : ff
    if(TRST == 1'b0) begin
        state <= PERSISTENCE_OFF;
    end
    else begin
        state <= next_state;
    end
end

always_comb begin : log 
    next_state = state;

    casez (state)
        PERSISTENCE_OFF: begin
            if(clamp_hold_decode == 1'b1) begin
                next_state = PERSISTENCE_ON;
            end
        end 
        PERSISTENCE_ON: begin
            if(((bypass_escape == 1'b1) && (update_ir == 1'b1) && (bypass_decode == 1'b1)) || (clamp_release_decode == 1'b1)) begin
                next_state = PERSISTENCE_OFF;
            end
        end
    endcase  
end

always_comb begin : chreset 
    ch_reset = (state == PERSISTENCE_ON) || tap_reset;
    tmp_state = (state == PERSISTENCE_ON);
end

    
endmodule