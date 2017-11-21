`include "uvm_macros.svh"

module testbench_top();
	initial begin
		uvm_config_db #(virtual ahb_if)::set(null, "uvm_test_top", "ahb_iface", hdl_top.ahb_iface);
		uvm_config_db #(virtual apb_if)::set(null, "uvm_test_top", "apb_iface", hdl_top.apb_iface);
		
		run_test();
	end
endmodule