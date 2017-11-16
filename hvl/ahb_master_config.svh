class ahb_master_config extends uvm_object;
	`uvm_object_utils(ahb_master_config)
	
	virtual ahb_if vif;
	
	function new(string name);
		super.new(name);
	endfunction
	
endclass