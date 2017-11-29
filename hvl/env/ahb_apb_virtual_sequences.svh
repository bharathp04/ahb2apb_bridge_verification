typedef uvm_sequencer #(ahb_master_transaction) a_sequencer_t;
typedef uvm_sequencer #(apb_slave_transaction) b_sequencer_t;

class ahb_apb_vseq_base extends uvm_sequence #(uvm_sequence_item);
	`uvm_object_utils(ahb_apb_vseq_base)
	
	//Sequencer path will be defined by the calling tests
	a_sequencer_t a_sequencer;
	b_sequencer_t b_sequencer;
	
	function new(string name= "");
		super.new(name);
	endfunction
	
	task body();
		//override with child class
	endtask
endclass

class ahb_apb_wrap_vseq extends ahb_apb_vseq_base;
	`uvm_object_utils(ahb_apb_wrap_vseq)
	
	function new(string name= "");
		super.new(name);
	endfunction
	
	task body();
		ahb_master_wrap_seq seq1;
		apb_slave_okay_seq seq2;
		
		seq1= ahb_master_wrap_seq::type_id::create("seq1");
		seq2= apb_slave_okay_seq::type_id::create("seq2");
		
		fork
			seq1.start(a_sequencer);
			seq2.start(b_sequencer);
		join
	endtask
	
endclass

class ahb_apb_incr_vseq extends ahb_apb_vseq_base;
	`uvm_object_utils(ahb_apb_incr_vseq)
	
	function new(string name= "");
		super.new(name);
	endfunction
	
	task body();
		ahb_master_incr_seq seq1;
		apb_slave_okay_seq seq2;
		
		seq1= ahb_master_incr_seq::type_id::create("seq1");
		seq2= apb_slave_okay_seq::type_id::create("seq2");
		
		fork
			seq1.start(a_sequencer);
			seq2.start(b_sequencer);
		join
	endtask
	
endclass