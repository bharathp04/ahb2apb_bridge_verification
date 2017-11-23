class apb_slave_sequencer extends uvm_sequencer #(apb_slave_transaction);
	`uvm_component_utils(apb_slave_sequencer)
	
	function new(string name= "apb_slave_sequencer", uvm_component parent);
		super.new(name, parent);
	endfunction
endclass