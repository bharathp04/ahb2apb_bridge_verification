class ahb_apb_env extends uvm_env;
	`uvm_component_utils(ahb_apb_env)
	
	ahb_master_agent master_agent_h;
	apb_slave_agent slave_agent_h;
	
	//ahb_apb_coverage coverage_h;
	
	extern function new(string name, uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	//extern function void connect_phase(uvm_phase phase);
		
endclass

function ahb_apb_env::new(string name, uvm_component parent);
	super.new(name, parent);
endfunction

function void ahb_apb_env::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	master_agent_h= ahb_master_agent::type_id::create("master_agent_h", this);
	
	slave_agent_h= apb_slave_agent::type_id::create("slave_agent_h", this);
	
endfunction