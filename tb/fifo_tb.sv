/* Wen-Bo Hung, 2024/02/10
    email: hong395@purdue.edu*/
// JTAG SoCET team
`include "fifo_if.vh"
`include "jtag_types_pkg.vh"

`timescale 1 ns/1 ns

module fifo_tb;
    parameter PERIOD = 10;
    logic TCK = 0, TRST;
    // clock
    always #(PERIOD/2) TCK++;

    //interface
    fifo_if ffif();
    //test program
    test #(.PERIOD (PERIOD)) PROG (
        .TCK(TCK),
        .TRST(TRST),
        .ffif(ffif)
    );
    // DUT
    `ifndef MAPPED
        fifo DUT(TCK, TRST, ffif);
    `else
        fifo DUT(
            .\ffif.data_in (ffif.data_in),
            .\ffif.wr_en (ffif.wr_en),
            .\ffif.rd_en (ffif.rd_en),
            .\ffif.data_out (ffif.data_out),
            .\ffif.full (ffif.full),
            .\ffif.empty (ffif.empty),
            .\TCK (TCK),
            .\TRST (TRST)
        );
    `endif
endmodule

program test(
    input logic TCK,
    output logic TRST,
    fifo_if ffif
);
    import jtag_types_pkg::*;
    parameter PERIOD = 10;
    parameter WIDTH = 8;
    parameter DEPTH = 64;
    int tb_test_num;
    string tb_test_case;

    task reset;
    begin
        TRST = 0;
        @(posedge TCK);
        @(posedge TCK);
        @(negedge TCK);
        TRST = 1;
    end
    endtask


    task check_output;
    input logic [WIDTH-1:0] exp_data_out;
    input logic exp_full;
    input logic exp_empty;
    begin
        $display("%0d test case: %s", tb_test_num, tb_test_case);
        if(exp_data_out == ffif.data_out) begin
            $display("data_out is as espected: %0d", ffif.data_out);
        end
        else begin
            $display("data_out is not as espected: %0d", ffif.data_out);
        end
        if(exp_full == ffif.full) begin
            $display("full is as espected: %0b", ffif.full);
        end
        else begin
            $display("full is not as espected: %0b", ffif.full);
        end
        if(exp_empty == ffif.empty) begin
            $display("empty is as espected: %0b", ffif.empty);
        end
        else begin
            $display("empty is not as espected: %0b", ffif.empty);
        end
        $display("");
    end
    endtask

    task store_data;
    input logic [WIDTH-1:0] data;
    begin
        @(negedge TCK);
        ffif.wr_en = 1'b1;
        ffif.data_in = data;
        @(negedge TCK);
        ffif.wr_en = 1'b0;
    end
    endtask

    task read_data;
    begin
        @(negedge TCK);
        ffif.rd_en = 1'b1;
        @(negedge TCK);
        ffif.rd_en = 1'b0;
    end
    endtask


    initial begin
        // Case 1: Reset DUT
        tb_test_num = 0;
        tb_test_case = "Reset";
        TRST = 1'b1;
        ffif.wr_en = 1'b0;
        ffif.rd_en = 1'b0;
        TRST = 1'b1;
        reset();
        check_output('0, 1'b0, 1'b1);
        // Case 2: Write a data into the buffer
        tb_test_num++;
        tb_test_case = "Write a data into the buffer";
        reset();
        store_data(8'hBE);
        check_output(8'hBE, 1'b0, 1'b0);
        read_data();
        check_output('0, 1'b0, 1'b1);
        // Case 3: Write the data until full
        tb_test_num++;
        tb_test_case = "Write the data until full";
        reset();
        for(int i = 1; i < 66; i++) begin
            store_data(i);
        end
        check_output(8'd1, 1'b1, 1'b0); // Check full
        for(int i = 0; i < 65; i++) begin
            read_data();
            if(i == 62)
                check_output(i+2, 1'b0, 1'b1);
            else
                check_output(i+2, 1'b0, 1'b0);
        end
        // Case 4: Read enable is on when buffer is empty
        tb_test_num++;
        tb_test_case = "Read enable is on when buffer is empty";
        reset();
        for(int i = 1; i < 65; i++) begin
            store_data(i);
        end
        for(int i = 0; i < 65; i++) begin
            read_data();
        end
        check_output(8'd63, 1'b0, 1'b1);
        $stop();
    end


endprogram