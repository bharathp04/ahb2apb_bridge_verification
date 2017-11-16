package ahb_apb_bridge_pkg;
	parameter HADDR_SIZE= 32;
	parameter HDATA_SIZE= 32;
	
	typedef enum logic [1:0]{IDLE, BUSY, NONSEQ, SEQ} trans_type_t;
	typedef enum logic {READ, WRITE} rw_t;
	typedef enum logic [2:0]{SINGLE, INCR, WRAP4, INCR4, WRAP8, INCR8, WRAP16, INCR16} burst_type_t;
	typedef enum logic [1:0]{BYTE, HALFWORD, WORD} size_t;
	typedef enum logic {OKAY, ERROR} resp_t;
	
endpackage