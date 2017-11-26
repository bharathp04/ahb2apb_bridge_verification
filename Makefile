#---------------------------------------------------------------------- 
# Team: Bharath Tupaki and Vinod Sake
# Design: AHB to APB Bridge
#----------------------------------------------------------------------

HDL_TOP= hdl_top
HVL_TOP= testbench_top
HDL= hdl/*.sv
HVL= hvl/top/testbench_top.sv
PKG= hvl/top/ahb_apb_bridge_pkg.sv
UVM_HOME= /pkgs/mentor/questa/10.3/questasim/verilog_src/uvm-1.1d/src
QUESTA_HOME= /pkgs/mentor/questa/10.3/questasim
WORK= work
INC= +incdir+hvl/env +incdir+hvl/master_agent +incdir+hvl/slave_agent +incdir+hvl/top 
UVM_INC= +incdir+/pkgs/mentor/questa/10.3/questasim/verilog_src/uvm-1.1d/src

lib:
	vlib $(WORK)
	vmap work $(WORK)
	
build:
	vlog -mfcu -work $(WORK) $(UVM_INC) $(UVM_HOME)/uvm_pkg.sv $(UVM_HOME)/dpi/uvm_dpi.cc $(QUESTA_HOME)/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv
	vlog -mfcu -work $(WORK) $(UVM_INC) $(INC) $(HDL) $(PKG) $(HVL)
	
ahb_apb_incr_test:
	vsim -c $(HDL_TOP) $(HVL_TOP) -do "run -all" +UVM_TESTNAME=ahb_apb_incr_test +tbxrun+velrunquesta
	