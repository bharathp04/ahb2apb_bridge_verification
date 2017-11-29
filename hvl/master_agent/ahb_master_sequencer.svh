class ahb_master_sequencer extends uvm_sequencer #(ahb_master_transaction);
	`uvm_component_utils(ahb_master_sequencer)
	
	function new(string name= "", uvm_component parent);
		super.new(name, parent);
	endfunction
endclass