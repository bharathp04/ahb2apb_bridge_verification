class apb_slave_agent extends uvm_agent;
	`uvm_component_utils(apb_slave_agent)
	
	apb_slave_sequencer sequencer_h;
	apb_slave_driver driver_h;
	//apb_slave_monitor monitor_h;
	
	uvm_analysis_port #(apb_slave_transaction) agent_ap;
	
	extern function new(string name, uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	
endclass

function apb_slave_agent::new(string name, uvm_component parent);
	super.new(name, parent);
endfunction

function void apb_slave_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	sequencer_h= apb_slave_sequencer::type_id::create("sequencer_h", this);
	driver_h= apb_slave_driver::type_id::create("driver_h", this);
	//monitor_h= apb_slave_monitor::type_id::create("monitor_h", this);
	
endfunction

function void apb_slave_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	
	//monitor_h.monitor_ap.connect(agent_ap);
	driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
	
endfunction	