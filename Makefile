#---------------------------------------------------------------------- 
# Team: Bharath Tupaki and Vinod Sake
# Design: AHB to APB Bridge
#----------------------------------------------------------------------

HDL_TOP= hdl_top
HVL_TOP= testbench_top
HDL= hdl/*.sv
HVL= hvl/top/testbench_top.sv
HDL_PKG= hdl/ahb_apb_bridge_pkg.sv
HVL_PKG= hvl/top/ahb_apb_uvm_include_pkg.sv
WORK= work
INC= +incdir+hvl/env +incdir+hvl/master_agent +incdir+hvl/slave_agent +incdir+hvl/top 
MODE= veloce

lib:
	vlib $(WORK)
	vmap work $(WORK)
	
build:
	vlog -mfcu -work $(WORK) $(INC) $(HDL) $(HDL_PKG) $(HVL_PKG) $(HVL)
ifeq ($(MODE),puresim)
	velhvl -sim $(MODE)
else 
	velanalyze -mfcu -work $(WORK) $(HDL) $(HDL_PKG)
	velcomp -top hdl_top
	velhvl -sim $(MODE)
endif
	
ahb_apb_incr_test:
	vsim -c $(HDL_TOP) $(HVL_TOP) -do "run -all; simstats" +UVM_TESTNAME=ahb_apb_incr_test
	
ahb_apb_wrap_test:
	vsim -c $(HDL_TOP) $(HVL_TOP) -do "run -all; simstats" +UVM_TESTNAME=ahb_apb_wrap_test
	
clean:
	rm -rf tbxbindings.h modelsim.ini transcript.veloce transcript.puresim work work.puresim work.veloce transcript vsim.wlf *.log dgs.dbg dmslogdir veloce.med veloce.wave veloce.map velrunopts.ini edsenv