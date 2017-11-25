import ahb_apb_bridge_pkg::*;

class apb_slave_transaction extends uvm_sequence_item;
	`uvm_object_utils(apb_slave_transaction)
	
	rand logic [PDATA_SIZE-1:0] PRDATA;
	logic [PDATA_SIZE-1:0] PWDATA;
	logic [PADDR_SIZE-1:0] PADDR;
	rand logic PREADY;
	logic PWRITE;
	rand logic PSLVERR;


	function new(string name= "");
		super.new(name);
	endfunction
	
	function string convert2string();
		return $psprintf("PDATA= %0h, PREADY= %0b, PSLVERR= %0b", PDATA, PREADY, PSLVERR);
   endfunction

endclass: ahb_master_transaction