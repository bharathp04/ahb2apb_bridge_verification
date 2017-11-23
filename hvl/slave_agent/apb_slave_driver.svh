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
	
	@(this.vif.PCLK);
	//first get an item from sequencer
	seq_item_port.get_next_item(txn);
	@(this.vif.PCLK);
	uvm_report_info("APB_DRIVER",$psprint("Got Transaction %s",txn.convert2string()));
	//Decode the APB command and call either read or write task
	case (txn.apb_cmd)
		apb_slave_transaction::Read: apb_slave_monitor(txn.pprot, txn.psel, txn.penable, 	txn.pwrite,txn.[PDATA_SIZE/8-1:0] pstrb,txn.[PDATA_SIZE  -1:0] paddr,
			txn.[PDATA_SIZE  -1:0] pwdata,txn.[PDATA_SIZE  -1:0] prdata,txn.pready,
			txn.pslverr);
			
		apb_slave_transaction::Write: apb_slave_driver(txn.prdata,txn.pready,txn.pslverr);
		
	end
endtask: run_phase