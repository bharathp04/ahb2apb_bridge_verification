import ahb_apb_bridge_pkg::*;

class ahb_master_transaction extends uvm_sequence_item;
	`uvm_object_utils(ahb_master_transaction)
	
	logic HSEL;
	rand trans_type_t HTRANS[];
	rand logic [HADDR_SIZE-1:0]HADDR[];
	rand logic [HDATA_SIZE-1:0]HWDATA[];
	rand rw_t HWRITE;
	rand size_t HSIZE;
	rand burst_type_t HBURST;
	rand logic [3:0]HPROT;
	rand logic HMASTLOCK;
	
	constraint addr_size{
		if(HBURST == SINGLE)
			HADDR.size == 1;
						
		if(HBURST == INCR)
			HADDR.size < (1024/2^HSIZE);
			
		if(HBURST inside {WRAP4, INCR4}) 
			HADDR.size == 4;
			
		if(HBURST inside {WRAP8, INCR8})
			HADDR.size == 8;
			
		if(HBURST inside {WRAP16, INCR16})
			HADDR.size == 16;
			
		HADDR.size > 0;
	}
	
	//Add kb_boundary constraint
	
	constraint addr_boundary{
		if(HSIZE == HALFWORD)
			foreach(HADDR[i])
				HADDR[i][0] == 0;
		
		if(HSIZE == WORD)
			foreach(HADDR[i])
				HADDR[i][1:0] == 0;
	}
	
	constraint addr_value_incr{
		if(HBURST != SINGLE){
			if(HBURST inside {INCR, INCR4, INCR8, INCR16}){
				foreach(HADDR[i]){
					if(i != 0){
						HADDR[i] == HADDR[i-1] + 2**HSIZE;
					}
				}
			}
		}
	}
	
	
	
	function new(string name= "");
		super.new(name);
	endfunction
	
	//function string convert2string;

endclass: ahb_master_transaction