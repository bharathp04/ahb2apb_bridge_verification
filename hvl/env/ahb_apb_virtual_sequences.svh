typedef uvm_sequence #(uvm_sequence_item) ahb_apb_virtual_sequence;
typedef uvm_sequencer #(uvm_sequence_item) a_sequencer_t;
typedef uvm_sequencer #(uvm_sequence_item) b_sequencer_t;

class ahb_apb_vseq_base extends ahb_apb_virtual_sequence;
	
	//Sequencer path will be defined by the calling tests
	a_sequencer_t a_sequencer;
	b_sequencer_t b_sequencer;
	
	function new(string name, uvm_component parent);
		super.new(name);
	endfunction
	
	task body();
		//override with child class
	endtask
endclass

class ahb_apb_wrap_vseq extends ahb_apb_vseq_base;
	
	function new(string name, uvm_component parent);
		super.new(name);
	endfunction
	
	task body();
		ahb_master_wrap_seq seq1;
		ahb_slave_okay_seq seq2;
		
		fork
			seq1.start(a_sequencer);
			seq2.start(b_sequencer);
		join
	endtask
	
endclass

class ahb_apb_incr_vseq extends ahb_apb_vseq_base;
	
	function new(string name, uvm_component parent);
		super.new(name);
	endfunction
	
	task body();
		ahb_master_incr_seq seq1;
		ahb_slave_okay_seq seq2;
		
		fork
			seq1.start(a_sequencer);
			seq2.start(b_sequencer);
		join
	endtask
	
endclass