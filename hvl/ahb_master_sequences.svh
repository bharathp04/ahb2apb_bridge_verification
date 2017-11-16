class ahb_master_idle_seq extends uvm_sequence #(ahb_master_transaction);
	`uvm_object_utils(ahb_master_idle_seq)
	
	function new(string name);
		super.new(name);
	endfunction
	
	task body();
		txn= ahb_master_transaction::type_id::create("txn");
		start_item(txn);
		assert(txn.randomize() with {HBURST == 0; HTRANS[0] == 0;});
		finish_item(txn);
	endtask
endclass

class ahb_master_wrap_seq extends uvm_sequence #(ahb_master_transaction);
	`uvm_object_utils(ahb_master_wrap_seq)
	
	function new(string name);
		super.new(name);
	endfunction
	
	task body();
		txn= ahb_master_transaction::type_id::create("txn");
		start_item(txn);
		assert(txn.randomize() with {HBURST inside{HBURST_WRAP4, HBURST_WRAP8, HBURST_WRAP16};});
		finish_item(txn);
	endtask
	
endclass

class ahb_master_incr_seq extends uvm_sequence #(ahb_master_transaction);
	`uvm_object_utils(ahb_master_incr_seq)
	
	function new(string name);
		super.new(name);
	endfunction
	
	task body();
		txn= ahb_master_transaction::type_id::create("txn");
		start_item(txn);
		assert(txn.randomize() with {HBURST inside{HBURST_INCR4, HBURST_INCR8, HBURST_INCR16};});
		finish_item(txn);
	endtask
endclass