/* Linda Zhang
    AHB access point design 
*/ 

`include "ahb_ap_if.vh"
`include "jtag_types_pkg.vh"

module ahb_ap (
    input AFT_CLK, TRST, 
    ahb_ap_if.ap apif
);

    typedef enum logic [2:0] { 
        IDLE = 3'b0, 
        ADDR = 3'd1,
        BUF = 3'd2, 
        WAIT = 3'd3, 
        DATA = 3'd4, 
        WRITE_WAIT = 3'd5 
    } state_t;

    state_t state, next_state; 

    logic [41:0] ahb_data;

    logic [31:0] real_data;  

    logic [1:0] size_ahb; 

    logic [4:0] addr_inc; 

    assign real_data = apif.data[41:10]; 
    assign reg_select = apif.data[9]; 
    assign size_ahb = apif.data[8:7]; 
    assign addr_inc = apif.data[6:2];
    assign r_or_w = apif.data[1]; // read 0, write 1 
    assign empty = apif.data[0]; 

    always_ff @( AFT_CLK, TRST ) begin 
        if(1'b0 == TRST) begin
            state <= IDLE; 
        end else begin
            state <= next_state; 
        end
    end

    always_comb begin : state_transition
        next_state = state; 
        casez (state)
            IDLE: begin
                if(apif.en & !reg_select) begin
                    next_state = ADDR; 
                end else if (apif.en & reg_select) begin
                    next_state = DATA; 
                end else begin
                    next_state = IDLE; 
                end
            end
            ADDR: next_state = busy ? ADDR : BUF; 
            BUF: next_state = r_or_w ? WAIT : IDLE; 
            DATA: next_state = r_or_w ? IDLE : WRITE_WAIT; 
            WRITE_WAIT: next_state = busy ? WRITE_WAIT : IDLE; 
            default: 
        endcase
    end


endmodule