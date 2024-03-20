/* Wen-Bo Hung, created at 2024/03/17, email: hong395@purdue.edu*/
// JTAG SoCET Team
// AHB FIFO READ

`include "ahb_fifo_read_if.vh"

module ahb_fifo_read #(
    parameter DATA_WIDTH = 8
)(
    input TCK,
    ahb_fifo_read_if.AHB_READ arif
);
    import jtag_types_pkg::*;
    logic timer_clear;
    logic [$clog2(DATA_WIDTH+2)-1:0] rollover_val;
    logic [$clog2(DATA_WIDTH+2)-1:0] count_out;
    logic rollover_flag;
    logic shift;
    logic update;
    logic sr_update;
    flex_counter #(.NUM_CNT_BITS($clog2(DATA_WIDTH+2))) COUNT (TCK, !arif.tlr_reset, timer_clear, shift, rollover_val, count_out, rollover_flag);
    flex_pts_sr #(.NUM_BITS(DATA_WIDTH+2), .SHIFT_MSB(0)) SR (TCK, !arif.tlr_reset, shift, update, {1'b0, arif.rdata, 1'b1}, arif.TDO); // start bit is 1, stop bit is zero
    typedef enum logic [1:0] {IDLE, CLEAR, READ} state_t;

    state_t state, nxt_state;

    assign rollover_val = DATA_WIDTH+2;
    always_comb begin: NXT_STATE
        nxt_state = state;
        case (state)
            IDLE: begin
                if(!arif.empty)
                    nxt_state = CLEAR;
                else
                    nxt_state = IDLE;
            end
            CLEAR: begin
                nxt_state = READ;
            end
            READ: begin
                if(arif.empty && rollover_flag)
                    nxt_state = IDLE;
                else
                    nxt_state = READ;
            end 
        endcase
    end

    always_ff @(posedge TCK, posedge arif.tlr_reset) begin : STATE
        if(arif.tlr_reset) begin
            state <= IDLE;
        end
        else begin
            state <= nxt_state;
        end
    end

    always_comb begin : OUTPUT_LOGIC
        timer_clear = 1'b0;
        sr_update = 1'b0;
        case (state)
            IDLE: begin
                timer_clear = 1'b0;
                sr_update = 1'b0;
            end
            CLEAR: begin
                timer_clear = 1'b1;
                sr_update = 1'b1;
            end
            READ: begin
                timer_clear = 1'b0;
                sr_update = 1'b0;
            end
        endcase
    end

    always_comb begin : UPDATE_LOGIC
        update = 1'b0;
        arif.rinc = 1'b0;
        if(sr_update) begin
            update = 1'b1;
        end
        else if((count_out == DATA_WIDTH+1) && (arif.dr_shift) && (arif.ahb_fifo_read_select) && (state == READ) && !arif.empty) begin
            update = 1'b1;
        end
        else
            update = 1'b0;

        if((count_out == DATA_WIDTH) && (arif.dr_shift) && (arif.ahb_fifo_read_select) && (state == READ)) begin
            arif.rinc = 1'b1;
        end
        else begin
            arif.rinc = 1'b0;
        end
    end

    always_comb begin : SHIFT
        shift = 1'b0;
        if(arif.dr_shift && arif.ahb_fifo_read_select)
            shift = 1'b1;
        else
            shift = 1'b0;
    end




endmodule