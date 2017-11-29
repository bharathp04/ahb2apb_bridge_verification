import ahb_apb_bridge_pkg::*;

class ahb_master_transaction extends uvm_sequence_item;
	`uvm_object_utils(ahb_master_transaction)
	
	logic HSEL;
	rand trans_type_t HTRANS[];
	rand logic [HADDR_SIZE-1:0]HADDR[];
	rand logic [HDATA_SIZE-1:0]HWDATA[];
	logic [HDATA_SIZE-1:0]HRDATA;
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
	
	constraint wdata_size{
		HWDATA.size == HADDR.size;
	}
	
	//kb_boundary constraint
	constraint kb_boundry {
		if(HBURST == 1)
			HADDR[0][10:0] <= (1024 - ((HADDR.size)*(2**HSIZE)));
		if((HBURST == 2) || (HBURST == 3))
			HADDR[0][10:0] <= (1024 - 4*(2**HSIZE));
		if((HBURST == 4) || (HBURST == 5))
			HADDR[0][10:0] <= (1024 - 8*(2**HSIZE));
		if((HBURST == 6) || (HBURST == 7))
			HADDR[0][10:0] <= (1024 - 16*(2**HSIZE));
	}
	
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
	
	constraint addr_value_wrap{
		if((HBURST == WRAP4) && (HSIZE == BYTE)){
			foreach(HADDR[i]){
				if(i != 0){
					HADDR[i][1:0] == HADDR[i-1][1:0] + 1;
					HADDR[i][31:2] == HADDR[i-1][31:2];
				}
			}
		}
		
		if((HBURST == WRAP4) && (HSIZE == HALFWORD)){
			foreach(HADDR[i]){
				if(i != 0){
					HADDR[i][2:0] == HADDR[i-1][2:0] + 2;
					HADDR[i][31:3] == HADDR[i-1][31:3];
				}
			}
		}
		
		if((HBURST == WRAP4) && (HSIZE == WORD)){
			foreach(HADDR[i]){
				if(i != 0){
					HADDR[i][3:0] == HADDR[i-1][3:0] + 4;
					HADDR[i][31:4] == HADDR[i-1][31:4];
				}
			}
		}
		
		if((HBURST == WRAP8) && (HSIZE == BYTE)){
			foreach(HADDR[i]){
				if(i != 0){
					HADDR[i][2:0] == HADDR[i-1][2:0] + 1;
					HADDR[i][31:3] == HADDR[i-1][31:3];
				}
			}
		}
		
		if((HBURST == WRAP8) && (HSIZE == HALFWORD)){
			foreach(HADDR[i]){
				if(i != 0){
					HADDR[i][3:0] == HADDR[i-1][3:0] + 2;
					HADDR[i][31:4] == HADDR[i-1][31:4];
				}
			}
		}
		
		if((HBURST == WRAP8) && (HSIZE == WORD)){
			foreach(HADDR[i]){
				if(i != 0){
					HADDR[i][4:0] == HADDR[i-1][4:0] + 4;
					HADDR[i][31:5] == HADDR[i-1][31:5];
				}
			}
		}
		
		if((HBURST == WRAP16) && (HSIZE == BYTE)){
			foreach(HADDR[i]){
				if(i != 0){
					HADDR[i][3:0] == HADDR[i-1][3:0] + 1;
					HADDR[i][31:4] == HADDR[i-1][31:4];
				}
			}
		}
		
		if((HBURST == WRAP16) && (HSIZE == HALFWORD)){
			foreach(HADDR[i]){
				if(i != 0){
					HADDR[i][4:0] == HADDR[i-1][4:0] + 2;
					HADDR[i][31:5] == HADDR[i-1][31:5];
				}
			}
		}
		
		if((HBURST == WRAP16) && (HSIZE == WORD)){
			foreach(HADDR[i]){
				if(i != 0){
					HADDR[i][5:0] == HADDR[i-1][5:0] + 4;
					HADDR[i][31:6] == HADDR[i-1][31:6];
				}
			}
		}
	}
	
	constraint trans_type{
		if(HBURST == SINGLE){
			HTRANS.size == 1;
			HTRANS[0] inside {IDLE, NONSEQ};
		}
		else{
			HTRANS.size == HADDR.size;
			foreach(HTRANS[i]){
				if(i == 0)
					HTRANS[i] == NONSEQ;
				else
					HTRANS[i] == SEQ;
			}
		}
	}
	
	function new(string name= "");
		super.new(name);
	endfunction

endclass: ahb_master_transaction