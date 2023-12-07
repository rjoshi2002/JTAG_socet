// Modified from Cole Nelson's code in Spring 2020 JTAG Team 
//  https://github.com/Purdue-SoCET/JTAG/blob/master/src/tap_controller.sv

`include "tap_ctrl_if.vh"

module tap_ctrl (
    input logic TCK, TRST, 
    tap_ctrl_if.tap tapif
);
    // import pkg
    import jtag_types_pkg::*; 

    state_t state, next_state; 
    always_ff @( posedge TCK, negedge TRST ) begin : blockName
       if(1'b0 == TRST) begin
            state <= TEST_LOGIC_RESET;
       end else begin
            state <= next_state; 
       end
    end

    always_comb begin : next_state_logic 
        next_state = state;
        casez(state)
            TEST_LOGIC_RESET: next_state = (tapif.TMS) ? TEST_LOGIC_RESET : RUN_TEST_IDLE; 
            RUN_TEST_IDLE: next_state = (tapif.TMS) ? SELECT_DR_SCAN : RUN_TEST_IDLE; 

            // Neither instruction or data register enabled
            SELECT_DR_SCAN: next_state = (tapif.TMS) ? SELECT_IR_SCAN : CAPTURE_DR; 

            // Allow parallel load of data register, instruction not changed
            CAPTURE_DR: next_state = (tapif.TMS) ? EXIT1_DR : SHIFT_DR; 

            // Shift enable for DR, instruction not changed
            SHIFT_DR: next_state = (tapif.TMS) ? EXIT1_DR: SHIFT_DR; 

            // Stop shifting DR, no load enable, instruction not changed
            EXIT1_DR: next_state = (tapif.TMS) ? UPDATE_DR: PAUSE_DR; 

            // Shift disable, load disable
            PAUSE_DR: next_state = (tapif.TMS) ? EXIT2_DR: PAUSE_DR; 

            // Disable everything
            EXIT2_DR: next_state = (tapif.TMS) ? UPDATE_DR : SHIFT_DR; 
            
            // Shift disable, DR load enable.
            UPDATE_DR: next_state = (tapif.TMS) ? SELECT_DR_SCAN: RUN_TEST_IDLE; 

            // Same as DR scan
            SELECT_IR_SCAN: next_state = (tapif.TMS) ? TEST_LOGIC_RESET: CAPTURE_IR; 

            // IR load
            CAPTURE_IR: next_state = (tapif.TMS) ? EXIT1_DR: SHIFT_IR; 

            // IR shift
            SHIFT_IR: next_state = (tapif.TMS) ? EXIT1_IR: PAUSE_IR; 

            // Disable all
            EXIT1_IR: next_state = (tapif.TMS) ? UPDATE_IR : PAUSE_IR; 

            // Disable all
            PAUSE_IR: next_state = (tapif.TMS) ? EXIT2_IR: PAUSE_IR; 

            // Disable all
            EXIT2_IR: next_state = (tapif.TMS) ? UPDATE_IR: SHIFT_IR; 

            // load enable
            UPDATE_IR: next_state = (tapif.TMS) ? SELECT_DR_SCAN: RUN_TEST_IDLE; 
        endcase
    end


    always_comb begin // State Output Decoding
        tapif.tap_state_uir = 1'b0;
        tapif.ir_update = 1'b0;
        tapif.ir_capture = 1'b0;
        tapif.ir_shift = 1'b0;
        tapif.dr_shift = 1'b0;
        tapif.dr_update = 1'b0;
        tapif.dr_capture = 1'b0;
        tapif.tap_reset = 1'b0;

        casez(state)
            TEST_LOGIC_RESET: begin
                tapif.tap_reset = 1'b1;
            end

            CAPTURE_DR: begin
                tapif.dr_capture = 1'b1;
            end

            SHIFT_DR: begin
                tapif.dr_shift = 1'b1;
            end

            UPDATE_DR: begin
                tapif.dr_update = 1'b1;
            end

            CAPTURE_IR: begin
                tapif.ir_capture = 1'b1;
            end

            SHIFT_IR: begin
                tapif.ir_shift = 1'b1;
            end

            UPDATE_IR: begin
                tapif.ir_update = 1'b1;
                tapif.tap_state_uir = 1'b1;
            end

        endcase
    end
    
endmodule
