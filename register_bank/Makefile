RTL_DIR = ./rtl
TB_DIR 	= ./tb
DO_CMD 	= "run -a;"

ifeq ($(GUI),)
	GUI_OPT = -c
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
