onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_jtag/jtif/NUM_IN
add wave -noupdate /tb_jtag/jtif/NUM_OUT
add wave -noupdate /tb_jtag/jtif/TCK
add wave -noupdate /tb_jtag/jtif/clk
add wave -noupdate /tb_jtag/jtif/TDO
add wave -noupdate /tb_jtag/jtif/TMS
add wave -noupdate /tb_jtag/jtif/TDI
add wave -noupdate /tb_jtag/jtif/TRST
add wave -noupdate /tb_jtag/jtif/nRST
add wave -noupdate /tb_jtag/jtif/parallel_in
add wave -noupdate /tb_jtag/jtif/parallel_out
add wave -noupdate /tb_jtag/jtif/capture_check
add wave -noupdate /tb_jtag/jtif/scan_check
add wave -noupdate /tb_jtag/jtif/instruction
add wave -noupdate /tb_jtag/jtif/tap_series
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {22 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 195
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ns} {4290 ns}
