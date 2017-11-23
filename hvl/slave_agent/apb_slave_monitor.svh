class apb_slave_monitor extends uvm_monitor;
	`uvm_component_utils(apb_slave_monitor)
	
	//Declare analysis port to send txn to scoreboard
	uvm_analysis_port #(apb_slave_transaction) monitor_ap;
	
	//Declare config class which has the virtual interface and optional other
	//dut info
	ahb_apb_config iface_config;
	
	//Declare virtual interface
	virtual apb_if vif;
	
	extern function new(string name, uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	
endclass: apb_slave_monitor
	
function apb_slave_monitor::new(string name, uvm_component parent);
	super.new(name, parent);
endfunction

function void apb_slave_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	monitor_ap= new("monitor_ap", this);
	
	//Get virtual interface from parent
	assert(uvm_config_db #(ahb_apb_config)::get(this, "", "iface_config", iface_config));
	
	vif= iface_config.ahb_vif;
endfunction
/*
task apb_slave_monitor::run_phase(uvm_phase phase);
	ahb_master_transaction txn;
	txn= ahb_master_transaction::type_id::create("txn", this);
	txn.HTRANS= new[1];
	txn.HADDR= new[1];
	txn.HWDATA= new[1];
	
	forever begin
		vif.apb_slave_monitor(txn.HTRANS[1], txn.HBURST, txn.HSIZE, txn.HWRITE, txn.HADDR[1], txn.HWDATA[1], txn.HRDATA);
		//Send txn to subscribers
		monitor_ap.write(txn);
	end
endtask
*/