class ahb_master_idle_seq extends uvm_sequence #(ahb_master_transaction);
	`uvm_object_utils(ahb_master_idle_seq)
	
	function new(string name= "");
		super.new(name);
	endfunction
	
	task body();
		ahb_master_transaction txn;
		txn= ahb_master_transaction::type_id::create("txn");
		start_item(txn);
		assert(txn.randomize() with {HBURST == SINGLE; HTRANS[0] == IDLE;});
		finish_item(txn);
	endtask
endclass

class ahb_master_wrap_seq extends uvm_sequence #(ahb_master_transaction);
	`uvm_object_utils(ahb_master_wrap_seq)
	
	function new(string name= "");
		super.new(name);
	endfunction
	
	task body();
		ahb_master_transaction txn;
		txn= ahb_master_transaction::type_id::create("txn");
		start_item(txn);
		assert(txn.randomize() with {HBURST inside{WRAP4, WRAP8, WRAP16};});
		//$display("ahb_master_wrap_seq: txn.HBURST= %0d, txn.HADDR.size= %0d", txn.HBURST, txn.HADDR.size);
		finish_item(txn);
	endtask
	
endclass

class ahb_master_incr_seq extends uvm_sequence #(ahb_master_transaction);
	`uvm_object_utils(ahb_master_incr_seq)
	
	function new(string name= "");
		super.new(name);
	endfunction
	
	task body();
		ahb_master_transaction txn;
		txn= ahb_master_transaction::type_id::create("txn");
		start_item(txn);
		assert(txn.randomize() with {HBURST inside{INCR4, INCR8, INCR16};});
		finish_item(txn);
	endtask
endclass