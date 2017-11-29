class ahb_master_driver extends uvm_driver #(ahb_master_transaction);
	`uvm_component_utils(ahb_master_driver);
	
	//Declare config class which has the virtual interface and optional other
	//dut info
	ahb_apb_config iface_config;
	
	//Declare virtual interface
	virtual ahb_if vif;
	
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
	assert(uvm_config_db #(ahb_apb_config)::get(this, "", "iface_config", iface_config))
	else begin 
		`uvm_fatal(get_full_name(), "Cannot get iface_config from uvm_config_db");
	end
	
	vif= iface_config.ahb_vif;
endfunction: build_phase

task ahb_master_driver::run_phase(uvm_phase phase);
	ahb_master_transaction txn;
	
	forever begin
		seq_item_port.get_next_item(txn);
		foreach(txn.HADDR[i]) begin
			//Call task from interface
			//$display("ahb_master_driver: txn.HBURST= %0d, txn.HADDR= %0h", txn.HBURST, txn.HADDR[i]);
			vif.ahb_master_driver(txn.HTRANS[i], txn.HBURST, txn.HSIZE, txn.HWRITE, txn.HADDR[i], txn.HWDATA[i]);
		end
		seq_item_port.item_done();
	end
endtask: run_phase