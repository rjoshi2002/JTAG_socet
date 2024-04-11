onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ahb_reg_tb/TCK
add wave -noupdate /ahb_reg_tb/PROG/tb_test_num
add wave -noupdate /ahb_reg_tb/PROG/tb_test_case
add wave -noupdate /ahb_reg_tb/ahbif/TDI
add wave -noupdate /ahb_reg_tb/ahbif/TDO
add wave -noupdate /ahb_reg_tb/ahbif/tlr_reset
add wave -noupdate /ahb_reg_tb/ahbif/dr_shift
add wave -noupdate /ahb_reg_tb/ahbif/dr_update
add wave -noupdate /ahb_reg_tb/ahbif/dr_capture
add wave -noupdate /ahb_reg_tb/ahbif/ahb_select
add wave -noupdate /ahb_reg_tb/ahbif/parallel_out
add wave -noupdate /ahb_reg_tb/ahbif/winc
add wave -noupdate /ahb_reg_tb/DUT/count
add wave -noupdate /ahb_reg_tb/DUT/ap_instruction
add wave -noupdate /ahb_reg_tb/DUT/nxt_count
add wave -noupdate /ahb_reg_tb/DUT/nxt_ap_instruction
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {56 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 123
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
WaveRestoreZoom {0 ns} {532 ns}
