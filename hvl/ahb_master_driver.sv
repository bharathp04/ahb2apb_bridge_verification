class ahb_master_driver extends uvm_driver #(ahb_master_transaction);
	`uvm_component_utils(ahb_master_driver);
	
	//Declare config class which has the virtual interface and optional other
	//dut info
	my_dut_config dut_config;
	
	//Declare virtual interface
	virtual ahb_interface vif;
	
	extern function new(string name, uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	
endclass: ahb_master_driver
	
function ahb_master_driver::new(string name, uvm_component parent);
	super.new(name, parent);
endfunction: new

function void ahb_master_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	//Get virtual interface
	assert(uvm_config_db #(my_dut_config)::get(this, "", "dut_config", dut_config))
	else begin 
		`uvm_fatal(get_full_name(), "Cannot get vif from uvm_config_db");
	end
	
	vif= dut_config.vif;
endfunction: build_phase

task ahb_master_driver::run_phase(uvm_phase phase);
	ahb_master_transaction txn;
	
	forever begin
		seq_item_port.get(txn);
		
		//Call task from interface
		vif.ahb_master_driver(txn);
		
	end
endtask: run_phase