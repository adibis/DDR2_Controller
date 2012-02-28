###########################################################################
# Makefile Created By          Dr. Rashed Z. Bhatti                       #
# Date Created                 10/18/2007                                 #
# Last Modified                10/18/2007                                 #
###########################################################################
# This is a general purpose makefile to compile and run                   #
# Cadence NCSIM simulations                                               #
#                                                                         #
# To compile                                                              #
# ----------                                                              #
# %> make                                                                 #
#                                                                         #
# To run simulation in console mode                                       #
# ---------------------------------                                       #
# %> make sim                                                             #
#                                                                         #
# To run simulation in gui mode                                           #
# -----------------------------                                           #
# %> make simg                                                            #
#                                                                         #
# Directory Stucture                                                      #
# ------------------                                                      #
# This makefile assumes the following directory structure :               #
#                                                                         #
# ./        -- current directory, simulation is going to run from here    #
# ./work    -- Cadence work library to compile the design                 #
# ./design  -- holds all design verilog files                             #
# ./tb      -- holds testbench file(s)                                    #
# ./include -- files included in the verilog files using include command  #
# ./scripts -- holds tcl run scripts for simulation control               #
# ./etc     -- keep all auxiliary files in this directory                 #
#                                                                         #
###########################################################################
#                                                                          
# Setup environment variables to point the Cadence instal directories      
# and license files etc                                                      
# source ~ee577/vlsi_tools.csh

# top level module
TOP = tb

# List of the design files
DESIGN_FILES = ./design/*.v

# List of the testbench files
TB_FILES = ./tb/*.v

INCLUDE_DIRECTORY = ./include

# GUI simulation script file
SIM_SCRIPT_FILE_GUI = ./scripts/runscript.tcl

# Non GUI simulation script file
SIM_SCRIPT_FILE_NO_GUI = ./scripts/runscript_nogui.tcl

# ncvlog switch 
NCVLOG_SWITCHES = \
	-STATUS \
	-MESSAGES \
	-UPDATE \
	-INCDIR $(INCLUDE_DIRECTORY)

#ncelab switches
NCELAB_SWITCHES = \
	-ACCESS +rwc \
	-NCFATAL INVSUP \
	-NCFATAL CUNOTB \
	-ERRORMAX 5 \
	-UPDATE \
	-MESSAGES \
	-loadpli $(DENALI)/verilog/libdenpli.so:den_PLIPtr \
	-loadpli1 $(PWD)/fileio.so:bstrap \
	-TIMESCALE '1ps/1ps' \
	-LIBVERBOSE


# ncsim simulation switches for console simulation
NCSIM_SWITCHES_NO_GUI = \
	-STATUS \
	-NOCOPYRIGHT \
	-MESSAGES \
	-NCFATAL INVSUP \
	-NOWARN DLBRLK \
	-TCL \
	-NOLOG \
	-NOKEY \
	-INPUT $(SIM_SCRIPT_FILE_NO_GUI)

# ncsim switches for GUI simulations
NCSIM_SWITCHES_GUI = \
	-STATUS \
	-NOCOPYRIGHT \
	-MESSAGES \
	-NCFATAL INVSUP \
	-NOWARN DLBRLK \
	-TCL \
	-NOLOG \
	-NOKEY \
	-INPUT $(SIM_SCRIPT_FILE_GUI) \
	-GUI

all : elab~ $(DESIGN_FILES)

# analyze all the design and testbench files
ana~ : $(DESIGN_FILES) $(TB_FILES)
	for f in $(DESIGN_FILES); do ncvlog $(NCVLOG_SWITCHES) -work work $$f ; done
	for f in $(TB_FILES);     do ncvlog $(NCVLOG_SWITCHES) -work work $$f ; done
	@touch ana~

# elaborate the top module
elab~ : ana~ 
	ncelab $(NCELAB_SWITCHES) work.$(TOP)
	@touch elab~

# run simulation without gui
sim : elab~
	ncsim $(NCSIM_SWITCHES_NO_GUI) $(TOP)

# run simulation with gui
simg : elab~
	ncsim $(NCSIM_SWITCHES_GUI) $(TOP)

# clean the library to have a clean start
clean :
	@rm -rf `find . -name '*~'`
	@rm -rf work
	@rm -rf ncsim*
	@rm -rf *.log
	@mkdir work
	@echo 'All set for a clean start'

# create directory structure
dir : cds.lib hdl.var
	@mkdir work
	@mkdir design
	@mkdir tb
	@mkdir include
	@mkdir scripts
	@mkdir etc
	@echo 'Directory structure for simulation is created'

# create the basic cds.lib file
cds.lib :
	@echo 'DEFINE work work' > cds.lib
	@echo 'DEFINE osu018_stdcells /auto/home-scf-06/ee577/design_pdk/osu_stdcells/lib/tsmc018/lib/INCA_libs/osu018_stdcells' >> cds.lib


# create a blank hdl.var
hdl.var :
	@echo '# Hello Cadence' > hdl.var
