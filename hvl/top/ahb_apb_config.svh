class ahb_apb_config extends uvm_object;
	`uvm_object_utils(ahb_master_config)
	
	virtual ahb_if ahb_vif;
	virtual apb_if apb_vif;
	
	function new(string name);
		super.new(name);
	endfunction
	
endclass