class apb_slave_driver extends uvm_driver #(apb_slave_transaction);
	`uvm_component_utils(apb_slave_driver);
	
	//Declare config class which has the virtual interface and optional other
	//dut info
	ahb_apb_config iface_config;
	
	//Declare virtual interface
	virtual apb_if vif;
	
	extern function new(string name, uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	
endclass: apb_slave_driver
	
function apb_slave_driver::new(string name, uvm_component parent);
	super.new(name, parent);
endfunction: new

function void apb_slave_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	//Get virtual interface
	assert(uvm_config_db #(ahb_apb_config)::get(this, "", "iface_config", iface_config))
	else begin 
		`uvm_fatal(get_full_name(), "Cannot get iface_config from uvm_config_db");
	end
	
	vif= iface_config.apb_vif;
endfunction: build_phase


task apb_slave_driver::run_phase(uvm_phase phase);
	apb_slave_transaction txn;
	//first get an item from sequencer
	//uvm_report_info("APB_DRIVER",$psprint("Got Transaction %s",txn.convert2string()));
	
	forever begin
		seq_item_port.get_next_item(txn);
		//$display("apb_slave_driver: txn.PRDATA= %0h, txn.PREADY= %0b, txn.PSLVERR= %0b", txn.PRDATA, txn.PREADY, txn.PSLVERR);
		vif.apb_slave_driver(txn.PRDATA, txn.PREADY, txn.PSLVERR);
		seq_item_port.item_done();
	end
	
endtask: run_phase