#---------------------------------------------------------------------- 
# Team: Bharath Tupaki and Vinod Sake
# Design: AHB to APB Bridge
#----------------------------------------------------------------------

HDL_TOP= hdl/hdl_top.sv
HVL_TOP= hvl/top/testbench_top.sv
HDL= hdl/*.sv
HVL_PKG= hvl/top/ahb_apb_bridge_pkg.sv
UVM_HOME= /pkgs/mentor/questa/10.3/questasim/verilog_src/uvm-1.1d/src
QUESTA_HOME= /pkgs/mentor/questa/10.3/questasim
WORK= work
INC= +incdir+hvl/env +incdir+hvl/master_agent +incdir+hvl/slave_agent +incdir+hvl/top 
UVM_INC= +incdir+/pkgs/mentor/questa/10.3/questasim/verilog_src/uvm-1.1d/src

lib:
	vlib $(WORK)
	vmap work $(WORK)
	
build:
	vlog -work $(UVM_INC) $(UVM_HOME)/uvm_pkg.sv $(UVM_HOME)/dpi/uvm_dpi.cc $(QUESTA_HOME)/verilog_src/questa_uvm_pkg-1.2/src/questa_uvm_pkg.sv
	vlog -work $(WORK) $(INC) $(HDL) $(HVL_PKG) $(HVL_TOP)
	
ahb_apb_incr_test:
	vsim -c $(HDL_TOP) $(HVL_TOP) -do "run -all" +UVM_TESTNAME=ahb_apb_incr_test +tbxrun+velrunquesta
	