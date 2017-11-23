import ahb_apb_bridge_pkg::*;

class apb_slave_transaction extends uvm_sequence_item;
	`uvm_object_utils(apb_slave_transaction)
	
	//typedef for READ/Write transaction type
	typedef enum{Read, Write} kind_e; 
	rand bit [31:0] addr;		// Address
	rand logic [31:0] data;		// Data - for Read and  Write response
	rand kind_e apb_cmd;		// Command Type


	function new(string name= "");
		super.new(name);
	endfunction
	
	function string convert2string();
		return $psprintf("kind=%s addr=%0h data=%0h ",apb_cmd,addr,data);
   endfunction

endclass: ahb_master_transaction