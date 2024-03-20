/* Made by Wen-Bo Hung, 2024/03/15*/
`include "afifo_if.vh"
`include "jtag_types_pkg.vh"

`timescale 1 ns/1 ns

module afifo_tb;
    parameter PERIOD1 = 10;
    parameter PERIOD2 = 3;
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 3;
    //interface
    afifo_if #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) affif();

    
    //test program
    test #(.PERIOD1 (PERIOD1), .PERIOD2(PERIOD2), .DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) PROG (
        .affif(affif)
    );
    // DUT
    `ifndef MAPPED
        afifo #(.DATA_WIDTH(8), .ADDR_WIDTH(3)) DUT(affif);
    `else
        afifo #(.DATA_WIDTH(8), .ADDR_WIDTH(3)) DUT(
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
endmodule

program test(
    afifo_if affif
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


    task check_routput;
    input logic exp_empty;
    input logic [DATA_WIDTH-1:0] exp_rdata;
    begin
        $display("%0d test case: %s", tb_test_num, tb_test_case);
        if(exp_empty == affif.empty) begin
            $display("empty signal is as espected: %0b", affif.empty);
        end
        else begin
            $display("empty signal is not as espected: %0b", affif.empty);
        end
        if(exp_rdata == affif.rdata) begin
            $display("rdata is as espected: %0b", affif.rdata);
        end
        else begin
            $display("rdata is not as espected: %0b", affif.rdata);
        end
        $display("");
    end
    endtask

    task check_woutput;
    input logic exp_full;
    begin
        $display("%0d test case: %s", tb_test_num, tb_test_case);
        if(exp_full == affif.full) begin
            $display("full signal is as espected: %0b", affif.full);
        end
        else begin
            $display("full signal is not as espected: %0b", affif.full);
        end
    end
    endtask

    task data_read;
    begin
        @(negedge affif.rclk);
        affif.rinc = 1'b1;
        @(negedge affif.rclk);
        affif.rinc = 1'b0;
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
        affif.rinc = 1'b0;
        r_reset();
        w_reset();
        check_routput(1'b1, 'x);
        check_woutput(1'b0);
        
        // Case 1: write a data onto the buffer
        tb_test_num++;
        tb_test_case = "Write a data onto the buffer";
        r_reset();
        w_reset();
        data_write(8'b11110000);
        check_routput(1'b0, 8'b11110000);
        data_read();
        check_routput(1'b1, 8'bxxxxxxxx);

        // Case 2: write over 8 data to check whether the full signal is raised
        tb_test_num++;
        tb_test_case = "Write over 8 data to check whether the full signal is raised";
        r_reset();
        w_reset();
        data_write(8'h00);
        data_write(8'h11);
        data_write(8'h22);
        data_write(8'h33);
        data_write(8'h44);
        data_write(8'h55);
        data_write(8'h66);
        data_write(8'h77);
        data_write(8'h88);
        data_write(8'h99);
        data_write(8'haa);
        check_woutput(1'b1);
        check_routput(1'b0, 8'h00);
        data_read();
        check_routput(1'b0, 8'h11);
        data_read();
        check_routput(1'b0, 8'h22);
        data_read();
        check_routput(1'b0, 8'h33);
        data_read();
        check_routput(1'b0, 8'h44);
        data_read();
        check_routput(1'b0, 8'h55);
        data_read();
        check_routput(1'b0, 8'h66);
        data_read();
        check_routput(1'b1, 8'hxx);
        data_read();
        check_routput(1'b1, 8'hxx);


        
        $stop();
    end
endprogram