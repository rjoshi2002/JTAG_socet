/* Made by Wen-Bo Hung, 2024/03/17*/
`include "ahb_fifo_read_if.vh"
`include "afifo_if.vh"
`include "jtag_types_pkg.vh"

`timescale 1 ns/1 ns

module ahb_fifo_read_tb;
    parameter PERIOD1 = 10;
    parameter PERIOD2 = 3;
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 3;
    //interface
    afifo_if #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) affif();
    ahb_fifo_read_if #(.DATA_WIDTH(DATA_WIDTH)) arif();


    assign arif.rdata = affif.rdata;
    assign arif.empty = affif.empty;
    assign affif.rinc = arif.rinc;

    //test program
    test #(.PERIOD1 (PERIOD1), .PERIOD2(PERIOD2), .DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) PROG (
        .affif(affif), .arif(arif)
    );
    // DUT
    `ifndef MAPPED
        afifo #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) FIFO(affif);
    `else
        afifo #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) FIFO(
            .\affif.wdata (affif.wdata),
            .\affif.winc (affif.winc),
            .\affif.rinc (affif.rinc),
            .\affif.rdata (affif.rdata),
            .\affif.full (affif.full),
            .\affif.empty (affif.empty),
            .\affif.wclk (affif.wclk),
            .\affif.rclk (affif.rclk),
            .\affif.w_nrst (affif.w_nrst),
            .\affif.r_nrst (affif.r_nrst),
        );
    `endif

    `ifndef MAPPED
        ahb_fifo_read #(.DATA_WIDTH(8)) DUT(affif.rclk, arif);
    `else
        afifo #(.DATA_WIDTH(8)) DUT(
            .\arif.tlr_reset (arif.tlr_reset),
            .\arif.dr_shift (arif.dr_shift),
            .\arif.ahb_fifo_read_select (arif.ahb_fifo_read_select),
            .\arif.empty (arif.empty),
            .\arif.rdata (arif.rdata),
            .\arif.TDO (arif.TDO),
            .\arif.rinc (arif.rinc),
            .\TCK(affif.rclk)
        );
    `endif
endmodule

program test(
    afifo_if affif,
    ahb_fifo_read_if arif
);
    import jtag_types_pkg::*;
    parameter PERIOD1 = 10.1;
    parameter PERIOD2 = 3.3;
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 3;
    int tb_test_num;
    string tb_test_case;

    task r_reset;
    begin
        affif.r_nrst = 0;
        @(posedge affif.rclk);
        @(posedge affif.rclk);
        @(negedge affif.rclk);
        affif.r_nrst = 1;
    end
    endtask

    task w_reset;
    begin
        affif.w_nrst = 0;
        @(posedge affif.wclk);
        @(posedge affif.wclk);
        @(negedge affif.wclk);
        affif.w_nrst = 1;
    end
    endtask

    task ahb_read_reset;
    begin
        arif.tlr_reset = 1'b1;
        @(posedge affif.rclk);
        @(posedge affif.rclk);
        @(negedge affif.rclk);
        arif.tlr_reset = 1'b0;
    end
    endtask

    task check_data;
    input logic [DATA_WIDTH-1:0] exp_rdata;
    begin
        @(posedge affif.rclk);
        arif.dr_shift = 1'b1;
        arif.ahb_fifo_read_select = 1'b1;
        for(int i = 0; i < DATA_WIDTH + 2; i++) begin
            if(i == 0) begin // Start bit(1)
                @(posedge affif.rclk);
                if(arif.TDO == 1'b1) begin
                    $display("Start bit is as expected: %0b", arif.TDO);
                end
                else begin
                    $display("Start bit is not as expected: %0b", arif.TDO);
                end
            end
            else if(i == 9) begin // Stop bit(0)
                @(posedge affif.rclk);
                if(arif.TDO == 1'b0) begin
                    $display("Stop bit is as expected: %0b", arif.TDO);
                end
                else begin
                    $display("Stop bit is not as expected: %0b", arif.TDO);
                end
            end
            else begin
                @(posedge affif.rclk);
                if(arif.TDO == exp_rdata[i-1]) begin
                    $display("%d bit is as expected: %0b", i-1, arif.TDO);
                end
                else begin
                    $display("%d bit is not as expected: %0b", i-1, arif.TDO);
                end
            end
        end
        arif.dr_shift = 1'b0;
        arif.ahb_fifo_read_select = 1'b0;
    end
    endtask

    task data_write;
    input logic [DATA_WIDTH-1:0] data;
    begin
        @(negedge affif.wclk);
        affif.wdata = data;
        affif.winc = 1'b1;
        @(negedge affif.wclk);
        affif.winc = 1'b0;
    end
    endtask

    initial begin
    affif.wclk = 0;
    forever #(PERIOD1/2) begin
        affif.wclk = ~affif.wclk;
        end
    end

    initial begin
    affif.rclk = 0;
    forever #(PERIOD2/2) begin
        affif.rclk = ~affif.rclk;
        end
    end

    initial begin
        tb_test_num = 0;
        tb_test_case = "Reset";
        affif.w_nrst = 1'b1;
        affif.r_nrst = 1'b1;
        affif.winc = 1'b0;
        arif.tlr_reset = 1'b0;
        arif.dr_shift = 1'b0;
        arif.ahb_fifo_read_select = 1'b0;
        r_reset();
        w_reset();
        ahb_read_reset();

        // Case 1: Write a data onto buffer and read from it
        tb_test_num++;
        tb_test_case = "Write a data onto buffer and read from it";
        data_write(8'haa);
        @(negedge affif.rclk);
        @(negedge affif.rclk);
        @(negedge affif.rclk);
        check_data(8'haa);
        // Case 2: Write multiple data onto buffer and read from it
        tb_test_num++;
        tb_test_case = "Write multiple data onto buffer and read from it";
        data_write(8'haa);
        data_write(8'hbb);
        @(negedge affif.rclk);
        @(negedge affif.rclk);
        @(negedge affif.rclk);
        check_data(8'haa);
        check_data(8'hbb);



        
        $stop();
    end
endprogram