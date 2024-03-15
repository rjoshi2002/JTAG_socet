onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /afifo_tb/PROG/tb_test_num
add wave -noupdate /afifo_tb/PROG/tb_test_case
add wave -noupdate /afifo_tb/affif/wclk
add wave -noupdate /afifo_tb/affif/w_nrst
add wave -noupdate /afifo_tb/affif/rclk
add wave -noupdate /afifo_tb/affif/r_nrst
add wave -noupdate /afifo_tb/affif/wdata
add wave -noupdate /afifo_tb/affif/rdata
add wave -noupdate /afifo_tb/affif/winc
add wave -noupdate /afifo_tb/affif/rinc
add wave -noupdate /afifo_tb/affif/full
add wave -noupdate /afifo_tb/affif/empty
add wave -noupdate -expand -group WPTR /afifo_tb/DUT/wpif/waddr
add wave -noupdate -expand -group WPTR /afifo_tb/DUT/wpif/wptr
add wave -noupdate -expand -group WPTR /afifo_tb/DUT/WPTR/tran_raddr
add wave -noupdate -expand -group WPTR /afifo_tb/DUT/wpif/sync_rptr
add wave -noupdate -expand -group RPTR /afifo_tb/DUT/rpif/rptr
add wave -noupdate -expand -group RPTR /afifo_tb/DUT/rpif/raddr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {245 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ns} {416 ns}
