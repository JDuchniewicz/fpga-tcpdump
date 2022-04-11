RTL_DIR = ./rtl
TB_DIR 	= ./tb

ifneq ($(wildcard ./tb/wave.do),) # TODO does not load simulation
	DO_CMD = "do ./tb/wave.do; run -a;"
else
	DO_CMD 	= "run -a;"
endif

else
	GUI_OPT = -gui
endif

all default: comp sim

comp:
	vlog -sv -f filelist.f -work work

sim:
	vsim -t ns -do $(DO_CMD) -work work $(GUI_OPT) # Add support for questa?

clean:
	rm -rf _work/* transcript *~ *.wlf *.vstf *.log *.tgz *.db *.bin

.PHONY: clean sim
