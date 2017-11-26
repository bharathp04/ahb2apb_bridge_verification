class ahb_master_agent extends uvm_agent;
	`uvm_component_utils(ahb_master_agent)
	
	ahb_master_sequencer sequencer_h;
	ahb_master_driver driver_h;
	//ahb_master_monitor monitor_h;
	
	uvm_analysis_port #(ahb_master_transaction) agent_ap;
	
	extern function new(string name, uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	
endclass

function ahb_master_agent::new(string name, uvm_component parent);
	super.new(name, parent);
endfunction

function void ahb_master_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	sequencer_h= ahb_master_sequencer::type_id::create("sequencer_h", this);
	driver_h= ahb_master_driver::type_id::create("driver_h", this);
	//monitor_h= ahb_master_monitor::type_id::create("monitor_h", this);
	
endfunction

function void ahb_master_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	
	//monitor_h.monitor_ap.connect(agent_ap);
	driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
	
endfunction