import ahb_apb_bridge_pkg::*;

class ahb_master_transaction extends uvm_sequence_item;
	`uvm_object_utils(ahb_master_transaction)
	
	logic HSEL;
	rand logic [1:0]HTRANS;
	rand logic [HADDR_SIZE-1:0]HADDR;
	rand logic [HDATA_SIZE-1:0]HWDATA;
	rand logic HWRITE;
	rand logic [2:0]HSIZE;
	rand logic [2:0]HBURST;
	rand logic [3:0]HPROT;
	rand logic HMASTLOCK;
	
	//write constraints here
	
	function new(string name= "");
		super.new(name);
	endfunction
	
	//function string convert2string;

endclass: ahb_master_transaction