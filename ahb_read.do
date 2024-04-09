onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ahb_fifo_read_tb/PROG/tb_test_num
add wave -noupdate /ahb_fifo_read_tb/PROG/tb_test_case
add wave -noupdate -expand -group {Asynchronous FIFO} /ahb_fifo_read_tb/affif/wdata
add wave -noupdate -expand -group {Asynchronous FIFO} /ahb_fifo_read_tb/affif/winc
add wave -noupdate -expand -group {Asynchronous FIFO} /ahb_fifo_read_tb/affif/rinc
add wave -noupdate -expand -group {Asynchronous FIFO} /ahb_fifo_read_tb/affif/rdata
add wave -noupdate -expand -group {Asynchronous FIFO} /ahb_fifo_read_tb/affif/full
add wave -noupdate -expand -group {Asynchronous FIFO} /ahb_fifo_read_tb/affif/empty
add wave -noupdate -expand -group {Asynchronous FIFO} /ahb_fifo_read_tb/affif/wclk
add wave -noupdate -expand -group {Asynchronous FIFO} /ahb_fifo_read_tb/affif/rclk
add wave -noupdate -expand -group {Asynchronous FIFO} /ahb_fifo_read_tb/affif/w_nrst
add wave -noupdate -expand -group {Asynchronous FIFO} /ahb_fifo_read_tb/affif/r_nrst
add wave -noupdate -expand -group {AHB read} /ahb_fifo_read_tb/arif/tlr_reset
add wave -noupdate -expand -group {AHB read} /ahb_fifo_read_tb/arif/dr_shift
add wave -noupdate -expand -group {AHB read} /ahb_fifo_read_tb/arif/ahb_fifo_read_select
add wave -noupdate -expand -group {AHB read} /ahb_fifo_read_tb/arif/TDO
add wave -noupdate -expand -group {AHB read} /ahb_fifo_read_tb/arif/empty
add wave -noupdate -expand -group {AHB read} -radix binary /ahb_fifo_read_tb/arif/rdata
add wave -noupdate -expand -group {AHB read} /ahb_fifo_read_tb/arif/rinc
add wave -noupdate -expand -group DUT /ahb_fifo_read_tb/DUT/TCK
add wave -noupdate -expand -group DUT /ahb_fifo_read_tb/DUT/timer_clear
add wave -noupdate -expand -group DUT -radix unsigned /ahb_fifo_read_tb/DUT/rollover_val
add wave -noupdate -expand -group DUT /ahb_fifo_read_tb/DUT/count_out
add wave -noupdate -expand -group DUT /ahb_fifo_read_tb/DUT/rollover_flag
add wave -noupdate -expand -group DUT /ahb_fifo_read_tb/DUT/shift
add wave -noupdate -expand -group DUT /ahb_fifo_read_tb/DUT/update
add wave -noupdate -expand -group DUT /ahb_fifo_read_tb/DUT/sr_update
add wave -noupdate -expand -group DUT /ahb_fifo_read_tb/DUT/state
add wave -noupdate -expand -group DUT /ahb_fifo_read_tb/DUT/nxt_state
add wave -noupdate -group WPTR /ahb_fifo_read_tb/FIFO/wpif/sync_rptr
add wave -noupdate -group WPTR /ahb_fifo_read_tb/FIFO/wpif/wptr
add wave -noupdate -group WPTR /ahb_fifo_read_tb/FIFO/wpif/waddr
add wave -noupdate -expand -group RPTR /ahb_fifo_read_tb/FIFO/rpif/sync_wptr
add wave -noupdate -expand -group RPTR /ahb_fifo_read_tb/FIFO/rpif/rptr
add wave -noupdate -expand -group RPTR /ahb_fifo_read_tb/FIFO/rpif/raddr
add wave -noupdate -expand -group {Output logic} /ahb_fifo_read_tb/OUTPUT_LOGIC/olif/instruction
add wave -noupdate -expand -group {Output logic} /ahb_fifo_read_tb/OUTPUT_LOGIC/olif/dr_shift
add wave -noupdate -expand -group {Output logic} /ahb_fifo_read_tb/OUTPUT_LOGIC/olif/ahb
add wave -noupdate -expand -group {Output logic} /ahb_fifo_read_tb/OUTPUT_LOGIC/olif/TDO
add wave -noupdate -expand -group {Output logic} /ahb_fifo_read_tb/OUTPUT_LOGIC/olif/tlr_reset
add wave -noupdate -expand -group {Output logic} /ahb_fifo_read_tb/OUTPUT_LOGIC/olif/ir_shift
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {127 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 182
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {66 ns} {154 ns}
