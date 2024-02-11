# rtl source directory (may need to add multiple)
SRCDIR= src
# tb source directory
TBDIR= uvm_tb
# interface and package directory
IFDIR = include
# name of top-level testbench module
TBTOP= tb_jtag.sv
# name of UVM test to be run
TESTNAME= preload_test
# uvm source file
UVM_SRC_FILES = src/adder_Nbit.sv src/bsr.sv src/instruction_decoder.sv src/instruction_reg.sv src/jtag.sv src/output_logic.sv src/tap_ctrl.sv src/idr.sv src/bpr.sv src/flex_stp_sr.sv
# normal file
SRC_FILES = src/fifo.sv
# Select the Cell Library to use with simulations
GATE_LIB		:= $(AMI_05_LIB)
TESTBENCH        = tb/fifo_tb.sv
# Please add in extra files needed for specific simulations here
OSU05_STD_CELL := osu05/osu05_stdcells.v
build:
	vlog +incdir+$(SRCDIR)+$(TBDIR)+$(IFDIR) \
	+sv $(SRC_FILES) \
	+sv $(TESTBENCH) \
	-logfile normal_tb_compile.log \
	-printinfilenames=normal_file_search.log

run: build
	vsim -c fifo_tb \
	-voptargs=+acc\
	-coverage \
	+no_glitch_msg -suppress 12110 \
	-do "coverage save -onexit coverage.ucdb" -do "run -all" &

run_gui: build
	vsim -i bsr_tb \
	-voptargs=+acc\
	-coverage \
	+no_glitch_msg -suppress 12110 \
	-do "coverage save -onexit coverage.ucdb" -do "run -all" &

uvm_build:
	vlog +incdir+$(SRCDIR)+$(TBDIR)+$(IFDIR) \
	+sv include/jtag_types_pkg.sv $(UVM_SRC_FILES) \
	+acc \
	+cover \
	-L $$QUESTA_HOME/uvm-1.2 uvm_tb/$(TBTOP) \
	-logfile tb_compile.log \
	-printinfilenames=file_search.log

uvm_run: uvm_build
	vsim -c tb_jtag -L \
	$$QUESTA_HOME/uvm-1.2 \
	-voptargs=+acc \
	-coverage \
	+UVM_TESTNAME="$(TESTNAME)" \
	+UVM_VERBOSITY=UVM_LOW \
	-do "coverage save -onexit coverage.ucdb" -do "run -all" &

uvm_run_gui: uvm_build
	vsim -i tb_jtag -L \
	$$QUESTA_HOME/uvm-1.2 \
	-voptargs=+acc \
	-coverage \
	+UVM_TESTNAME="$(TESTNAME)" \
	+UVM_VERBOSITY=UVM_LOW \
	-do "do wave.do" -do "run -all" &

clean:
	rm -rf work
	rm -rf covhtmlreport
	rm *.log
	rm transcript
	rm *.ucdb
	rm *.wlf
	rm *.vstf

.phony: build, run, run_gui, clean
