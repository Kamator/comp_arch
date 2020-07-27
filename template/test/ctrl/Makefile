VCOM_ARGS=-2008 -work work -suppress 1236 -novopt
VSIM_ARGS=-msgmode both

# The order is important!
VHDL_FILES = \
	../../vhdl/mem_pkg.vhd\
	../../vhdl/core_pkg.vhd\
	../../vhdl/op_pkg.vhd\
	../../vhdl/ctrl.vhd

TB_FILES = \
	./ctrl_tb.vhd

TIME_RESOLUTION = 1ps
TB = ctrl_tb

# For the simulation time -all can also be selected. Questa then simulates until no more singal changes occour.
SIM_TIME = 2 ms
WAVE_FILE = scripts/ctrl_wave.do

compile: log 

log: $(VHDL_FILES) $(TB_FILES)
	rm -f log
	vlib work | tee log
	for i in $(VHDL_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	for i in $(TB_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	@echo "--------------------------------------------------------------"
	@echo "--              Error and Warning Summary                   --"
	@echo "--------------------------------------------------------------"
	@cat log | grep 'Warning\|Error'
	@if [[ $$(grep "Error:" -m 1 log) ]]; then \
		echo "Compilation had errors!" \
		exit 1; \
	fi;

list_sources:
	@for i in $(VHDL_FILES) $(TB_FILES); do \
		echo $$i;\
	done;

sim_gui: compile
	vsim -do "vsim $(TB) -t $(TIME_RESOLUTION) $(VSIM_ARGS); do $(WAVE_FILE);run $(SIM_TIME)" 

sim: compile
	vsim -c -do "vsim $(TB) -t $(TIME_RESOLUTION) $(VSIM_ARGS); run $(SIM_TIME);quit"

clean:
	rm -f transcript
	rm -f vsim.wlf
	rm -f log
	rm -fr work

.PHONY: clean
.PHONY: compile
.PHONY: sim
.PHONY: sim_cl

