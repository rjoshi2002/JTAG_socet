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
        READ = 3'd2, 
        WAIT = 3'd3, 
        DATA = 3'd4, 
        WRITE = 3'd5 
    } state_t;

    state_t state, next_state; 
    logic [40:0] ahb_data;
    logic [31:0] real_data;  
    logic [1:0] size_ahb; 
    logic [4:0] addr_inc;
    logic [5:0] count, next_count;  

    // decode instruction 
    assign real_data = apif.rdata_fifo1[41:10]; 
    assign reg_select = apif.rdata_fifo1[9]; 
    assign size_ahb = apif.rdata_fifo1[8:7]; 
    assign addr_inc = apif.rdata_fifo1[6:2];
    assign r_or_w = apif.rdata_fifo1[1]; // read 0, write 1 
    

    always_ff @( posedge AFT_CLK, negedge TRST ) begin 
        if(1'b0 == TRST) begin
            state <= IDLE; 
        end else begin
            state <= next_state; 
        end
    end

    always_comb begin: byte_en_logic 
        if(size_ahb == 2'b00) begin
            byte_en = 4'd0; // byte
        end else if (size_ahb == 2'd1 || size_ahb == 2'd2) begin
            byte_en = 4'b1100; // half word 
        end else begin
            byte_en = 4'b1111; // word 
        end 
    end 

    always_comb begin : state_transition
        next_state = state; 
        casez (state)
            IDLE: begin
                if(!apif.rempty & reg_select) begin
                    next_state = ADDR; 
                end else if (!apif.rempty & reg_select & !addr_inc) begin
                    next_state = DATA; 
                end else begin
                    next_state = IDLE; 
                end
            end
            ADDR: next_state = r_or_w ? WAIT : READ; 
            READ: next_state = (apif.busy & (count == addr_inc)) ? IDLE : READ; 
            WAIT: next_state = apif.rempty ? WAIT: DATA;
            DATA: next_state = (r_or_w) ? WRITE : IDLE; 
            WRITE: next_state = apif.busy ? IDLE : WRITE; 
        endcase
    end

    always_comb begin : output_logic
        apif.ren = 0; 
        apif.wen = 0; 
        apif.byte_en = '0; 
        apif.rinc = 0; 
        apif.winc = 0; 
        apif.wdata_fifo2 = '0; 
        apif.wdata_aft = '0; 
        apif.addr_aft = '0; 

        casez (state)
            ADDR: 
        endcase


    end

    // counter 
    always_ff @( posedge AFT_CLK, negedge TRST ) begin : counter
        if(!TRST) begin
            count <= '0; 
        end else begin
            count <= next_count; 
        end 
    end

    always_comb begin : count_logic 
        if(count == 40) begin

    end


endmodule