RTL_DIR = ./rtl
TB_DIR 	= ./tb
LIBS = altera_mf_ver

ifneq ($(wildcard ./tb/wave.do),)
	DO_CMD = "do ./tb/wave.do; run -a;"
else
	DO_CMD 	= "run -a;"
endif

ifeq ($(GUI),)
	GUI_OPT = -c
else
	GUI_OPT = -gui
endif

all default: comp sim

comp:
	vlog -sv -f filelist.f -work work

sim:
	vsim -t ns -do $(DO_CMD) -work work $(GUI_OPT) -L $(LIBS) tb_top # Add support for questa?

clean:
	rm -rf _work/* transcript *~ *.wlf *.vstf *.log *.tgz *.db *.bin

.PHONY: clean sim
