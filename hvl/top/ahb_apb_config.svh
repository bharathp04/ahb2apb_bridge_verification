class ahb_apb_config extends uvm_object;
	`uvm_object_utils(ahb_apb_config)
	
	virtual ahb_if ahb_vif;
	virtual apb_if apb_vif;
	
	function new(string name= "ahb_apb_config");
		super.new(name);
	endfunction
	
endclass