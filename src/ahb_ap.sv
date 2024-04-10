/* Linda Zhang
    AHB access point design 
*/ 

`include "ahb_ap_if.vh"
`include "generic_bus_if.vh"
`include "jtag_types_pkg.vh"

module ahb_ap (
    input logic AFT_CLK, nRST, 
    ahb_ap_if.ap apif, 
    generic_bus_if.cpu gbif 
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
    // logic [40:0] ahb_data;
    logic [31:0] real_data;  
    logic [1:0] size_ahb; 
    logic [4:0] addr_inc, addr_inc_reg, next_addr_inc_reg;
    logic [5:0] count, next_count;  

    // decode instruction 
    assign real_data = apif.rdata_fifo1[40:9]; 
    assign reg_select = apif.rdata_fifo1[8]; // addr 0 , data 1
    assign size_ahb = apif.rdata_fifo1[7:6]; 
    assign addr_inc = apif.rdata_fifo1[5:1];
    assign r_or_w = apif.rdata_fifo1[0]; // read 0, write 1 
    
    logic [31:0] addr_reg, next_addr_reg, data_reg, next_data_reg, wdata_fifo2_reg, next_wdata_fifo2_reg; 

    always_ff @( posedge AFT_CLK, negedge nRST ) begin 
        if(1'b0 == nRST) begin
            state <= IDLE; 
            addr_reg <= '0; 
            data_reg <= '0; 
            wdata_fifo2_reg <= '0; 
            addr_inc_reg <= '0; 
        end else begin
            state <= next_state; 
            addr_reg <= next_addr_reg; 
            data_reg <= next_data_reg;
            wdata_fifo2_reg <= next_wdata_fifo2_reg;  
            addr_inc_reg <= next_addr_inc_reg; 
        end
    end

    always_comb begin: byte_en_logic 
        if(size_ahb == 2'b00) begin
            gbif.byte_en = 4'd0; // byte
            // next_addr_reg = addr_reg + 1; 
        end else if (size_ahb == 2'd1 || size_ahb == 2'd2) begin
            gbif.byte_en = 4'b1100; // half word 
            // next_addr_reg = addr_reg + 2
        end else begin
            gbif.byte_en = 4'b1111; // word
            // next_addr_reg = addr_reg + 4;  
        end 
    end 

    always_comb begin : state_transition
        next_state = state; 
        casez (state)
            IDLE: begin
                if(!apif.rempty & !reg_select) begin
                    next_state = ADDR; 
                end else if (!apif.rempty & reg_select & !addr_inc) begin
                    next_state = DATA; 
                end else begin
                    next_state = IDLE; 
                end
            end
            ADDR: next_state = r_or_w ? WAIT : READ; 
            READ: next_state = (gbif.busy & (addr_inc_reg == addr_inc)) ? IDLE : READ; 
            WAIT: next_state = apif.rempty ? WAIT: DATA;
            DATA: next_state = (r_or_w) ? WRITE : IDLE; 
            WRITE: next_state = gbif.busy ? IDLE : WRITE; 
        endcase
    end

    always_comb begin : output_logic
        gbif.ren = 0; 
        gbif.wen = 0; 
        // gbif.byte_en = '0; 
        apif.rinc = 0; 
        apif.winc = 0; 
        // apif.wdata_fifo2 = '0;  
        // gbif.addr = '0; 
        // gbif.wdata = '0;
        next_addr_reg = addr_reg; 
        next_data_reg = data_reg;  
        next_wdata_fifo2_reg = wdata_fifo2_reg; 
        next_addr_inc_reg = addr_inc_reg; 

        casez (state)
            READ: begin
                gbif.ren = 1'b1;
                next_wdata_fifo2_reg = gbif.rdata; 
                apif.winc = 1'b1; 
                next_addr_reg = real_data;
                next_addr_inc_reg += 1; 
            end
            DATA: begin
                if(addr_inc) begin
                    if(size_ahb == 2'b00) begin
                        next_addr_reg = addr_reg + 1; 
                    end else if (size_ahb == 2'd1 || size_ahb == 2'd2) begin
                        next_addr_reg = addr_reg + 2;
                    end else begin
                        next_addr_reg = addr_reg + 4;  
                    end 
                end
            end 
            WRITE: begin
                gbif.wen = 1'b1; 
                next_data_reg = real_data; 
                apif.rinc = 1; 
            end  
        endcase

    end

    // counter 
    always_ff @( posedge AFT_CLK, negedge nRST ) begin : counter
        if(!nRST) begin
            count <= '0; 
        end else begin
            count <= next_count; 
        end 
    end

    always_comb begin : count_logic 
        next_count = count; 
        if(count == 40) begin
            next_count = 0; 
        end else begin
            next_count = count + 1; 
        end

    end

// output to ahb generic bus 
assign gbif.addr = addr_reg; 
assign gbif.wdata = data_reg; 

//output to fifo 2 (read data from AHB to JTAG)
assign apif.wdata_fifo2 = wdata_fifo2_reg; 

endmodule
