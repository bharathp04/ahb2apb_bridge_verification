class ahb_apb_base_test extends uvm_test;
	
	`uvm_component_utils(ahb_apb_base_test)
	
	ahb_apb_env env;
	ahb_apb_config iface_config;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		iface_config= new();
		
		//Get ahb and apb virtual interface 
		assert(uvm_config_db #(virtual ahb_if)::get(this, "", "ahb_iface", iface_config.ahb_vif))
		else begin 
			`uvm_fatal(get_full_name(), "Cannot get vif from uvm_config_db");
		end
		
		assert(uvm_config_db #(virtual apb_if)::get(this, "", "apb_iface", iface_config.apb_vif))
		else begin 
			`uvm_fatal(get_full_name(), "Cannot get vif from uvm_config_db");
		end
		
		//Send vif to driver and monitor
		uvm_config_db #(ahb_apb_config)::set(this, "*", "iface_config", iface_config);
		
		env= ahb_apb_env::type_id::create("env", this);
		
	endfunction
	
	//Default sequencer. If you need to change the sequencer override this function
	//in child tests
	function void default_seqr(ahb_apb_vseq_base vseq);
		vseq.a_sequencer= env.master_agent_h.sequencer_h;
		vseq.b_sequencer= env.slave_agent_h.sequencer_h;
	endfunction
	
endclass


class ahb_apb_incr_test extends ahb_apb_base_test;

	`uvm_component_utils(ahb_apb_incr_test)
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	task run_phase(uvm_phase phase);
		ahb_apb_incr_vseq vseq;
		vseq= ahb_apb_incr_vseq::type_id::create("vseq");
		
		phase.raise_objection(this);
		default_seqr(vseq);
		
		//Virtual sequence doesn't run on any sequencer
		vseq.start(null);
		phase.drop_objection(this);
	endtask

endclass

class ahb_apb_wrap_test extends ahb_apb_base_test;

	`uvm_component_utils(ahb_apb_wrap_test)
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	task run_phase(uvm_phase phase);
		ahb_apb_wrap_vseq vseq;
		vseq= ahb_apb_wrap_vseq::type_id::create("vseq");
		
		phase.raise_objection(this);
		default_seqr(vseq);
		
		repeat(30000) begin
			
			//Virtual sequence doesn't run on any sequencer
			vseq.start(null);
		end
		phase.drop_objection(this);
	endtask

endclass
