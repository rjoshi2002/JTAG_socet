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
add wave -noupdate -expand -group BSR /tb_jtag/JTAG/bsrif/parallel_in
add wave -noupdate -expand -group BSR /tb_jtag/JTAG/bsrif/parallel_system_logic_out
add wave -noupdate -expand -group BSR /tb_jtag/JTAG/bsrif/to_system_logic
add wave -noupdate -expand -group BSR /tb_jtag/JTAG/bsrif/to_output_pin
add wave -noupdate -expand -group {Tap controller} /tb_jtag/JTAG/TAP_CTRL/state
add wave -noupdate -expand -group {Tap controller} /tb_jtag/JTAG/tcif/TMS
add wave -noupdate -expand -group {Tap controller} /tb_jtag/JTAG/tcif/tap_state_uir
add wave -noupdate -expand -group {Tap controller} /tb_jtag/JTAG/tcif/ir_update
add wave -noupdate -expand -group {Tap controller} /tb_jtag/JTAG/tcif/ir_shift
add wave -noupdate -expand -group {Tap controller} /tb_jtag/JTAG/tcif/ir_capture
add wave -noupdate -expand -group {Tap controller} /tb_jtag/JTAG/tcif/dr_capture
add wave -noupdate -expand -group {Tap controller} /tb_jtag/JTAG/tcif/dr_shift
add wave -noupdate -expand -group {Tap controller} /tb_jtag/JTAG/tcif/dr_update
add wave -noupdate -expand -group {Tap controller} /tb_jtag/JTAG/tcif/tap_reset
add wave -noupdate -expand -group {Instruction Register} /tb_jtag/JTAG/irif/TDI
add wave -noupdate -expand -group {Instruction Register} /tb_jtag/JTAG/irif/ir_capture
add wave -noupdate -expand -group {Instruction Register} /tb_jtag/JTAG/irif/ir_shift
add wave -noupdate -expand -group {Instruction Register} /tb_jtag/JTAG/irif/ir_update
add wave -noupdate -expand -group {Instruction Register} /tb_jtag/JTAG/irif/test_reset
add wave -noupdate -expand -group {Instruction Register} /tb_jtag/JTAG/irif/TDO
add wave -noupdate -expand -group {Instruction Register} /tb_jtag/JTAG/irif/parallel_out
add wave -noupdate -expand -group {Instruction Register} /tb_jtag/JTAG/irif/tlr_reset
add wave -noupdate -expand -group {Instruction Decoder} /tb_jtag/JTAG/idif/parallel_out
add wave -noupdate -expand -group {Instruction Decoder} /tb_jtag/JTAG/idif/bsr_select
add wave -noupdate -expand -group {Instruction Decoder} /tb_jtag/JTAG/idif/bsr_mode
add wave -noupdate -expand -group {Instruction Decoder} /tb_jtag/JTAG/idif/id_select
add wave -noupdate -expand -group {Instruction Decoder} /tb_jtag/JTAG/idif/bypass_select
add wave -noupdate -expand -group {Instruction Decoder} /tb_jtag/JTAG/idif/tmp_select
add wave -noupdate -expand -group {Instruction Decoder} /tb_jtag/JTAG/idif/ahb_select
add wave -noupdate -expand -group {Instruction Decoder} /tb_jtag/JTAG/idif/clamp_hold_decode
add wave -noupdate -expand -group {Instruction Decoder} /tb_jtag/JTAG/idif/clamp_release_decode
add wave -noupdate -expand -group {Instruction Decoder} /tb_jtag/JTAG/idif/bypass_decode
add wave -noupdate -expand -group {Nbit adder} /tb_jtag/JTAG/adif/BIT_WIDTH
add wave -noupdate -expand -group {Nbit adder} /tb_jtag/JTAG/adif/clk
add wave -noupdate -expand -group {Nbit adder} /tb_jtag/JTAG/adif/n_rst
add wave -noupdate -expand -group {Nbit adder} /tb_jtag/JTAG/adif/a
add wave -noupdate -expand -group {Nbit adder} /tb_jtag/JTAG/adif/b
add wave -noupdate -expand -group {Nbit adder} /tb_jtag/JTAG/adif/carry_in
add wave -noupdate -expand -group {Nbit adder} /tb_jtag/JTAG/adif/sum
add wave -noupdate -expand -group {Nbit adder} /tb_jtag/JTAG/adif/overflow
add wave -noupdate -expand -group {Output logic} /tb_jtag/JTAG/olif/dr_shift
add wave -noupdate -expand -group {Output logic} /tb_jtag/JTAG/olif/bypass_out
add wave -noupdate -expand -group {Output logic} /tb_jtag/JTAG/olif/bsr_out
add wave -noupdate -expand -group {Output logic} /tb_jtag/JTAG/olif/ir_shift
add wave -noupdate -expand -group {Output logic} /tb_jtag/JTAG/olif/instr_out
add wave -noupdate -expand -group {Output logic} /tb_jtag/JTAG/olif/instruction
add wave -noupdate -expand -group {Output logic} /tb_jtag/JTAG/olif/TDO
add wave -noupdate -expand -group {Output logic} /tb_jtag/JTAG/olif/tmp_status
add wave -noupdate -expand -group {Output logic} /tb_jtag/JTAG/olif/ahb
add wave -noupdate -expand -group {Output logic} /tb_jtag/JTAG/olif/idcode
add wave -noupdate -expand -group {Output logic} /tb_jtag/JTAG/olif/ahb_error
add wave -noupdate -expand -group {Output logic} /tb_jtag/JTAG/olif/tlr_reset
add wave -noupdate -expand -group {Shift Register} /tb_jtag/JTAG/SHIFT_REGISTER/NUM_BITS
add wave -noupdate -expand -group {Shift Register} /tb_jtag/JTAG/SHIFT_REGISTER/SHIFT_MSB
add wave -noupdate -expand -group {Shift Register} /tb_jtag/JTAG/SHIFT_REGISTER/clk
add wave -noupdate -expand -group {Shift Register} /tb_jtag/JTAG/SHIFT_REGISTER/n_rst
add wave -noupdate -expand -group {Shift Register} /tb_jtag/JTAG/SHIFT_REGISTER/shift_enable
add wave -noupdate -expand -group {Shift Register} /tb_jtag/JTAG/SHIFT_REGISTER/serial_in
add wave -noupdate -expand -group {Shift Register} /tb_jtag/JTAG/SHIFT_REGISTER/parallel_out
add wave -noupdate -expand -group {Shift Register} /tb_jtag/JTAG/SHIFT_REGISTER/next_output
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1170 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 252
configure wave -valuecolwidth 144
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
WaveRestoreZoom {273 ns} {2281 ns}
