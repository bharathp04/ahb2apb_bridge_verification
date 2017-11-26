class apb_slave_okay_seq extends uvm_sequence #(apb_slave_transaction);
	`uvm_object_utils(apb_slave_okay_seq)
	
	function new(string name= "");
		super.new(name);
	endfunction
	
	task body();
		apb_slave_transaction txn;
		txn= apb_slave_transaction::type_id::create("txn");
		start_item(txn);
		assert(txn.randomize() with {PREADY == 1; PSLVERR == 0;});
		finish_item(txn);
	endtask
endclass

class apb_slave_err_seq extends uvm_sequence #(apb_slave_transaction);
	`uvm_object_utils(apb_slave_okay_seq)
	
	function new(string name= "");
		super.new(name);
	endfunction
	
	task body();
		apb_slave_transaction txn;
		txn= apb_slave_transaction::type_id::create("txn");
		start_item(txn);
		assert(txn.randomize() with {PREADY == 1; PSLVERR == 1;});
		finish_item(txn);
	endtask
endclass
