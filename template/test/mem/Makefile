VCOM_ARGS=-2008 -opt=-clkOpt -work work -suppress 1236 -novopt
VSIM_ARGS=-msgmode both

VHDL_FILES = \
	../../vhdl/mem_pkg.vhd\
	../../vhdl/core_pkg.vhd\
	../../vhdl/op_pkg.vhd\
	../../vhdl/memu.vhd\
	../../vhdl/mem.vhd
TB_FILES = \
        ./mem_tb.vhd

TIME_RESOLUTION = 1ps

TB= mem_tb
SIM_TIME =2ms
WAVE = scripts/wave.do

compile:
	rm -f log
	vlib work | tee log
	for i in $(VHDL_FILES); do \
                vcom $(VCOM_ARGS) $$i | tee -a log;\
        done;
	for i in $(TB_FILES); do \
                vcom $(VCOM_ARGS) $$i | tee -a log;\
        done;
	@echo "---------------------------------------"
	@echo "--//-- ERROR AND WARNING SUMMARY --//--"
	@echo "---------------------------------------"
	@cat log | grep 'Warning\|Error'

sim_gui:
	vsim -do "vsim $(TB) -t $(TIME_RESOLUTION) $(VSIM_ARGS); do $(WAVE); run $(SIM_TIME);"

sim:
	vsim -c -do "vsim $(TB) -t $(TIME_RESOLUTION) $(VSIM_ARGS); run $(SIM_TIME);"

clean:
	rm -f transcript
	rm -f vsim.wlf
	rm -f log
	rm -fr work 

