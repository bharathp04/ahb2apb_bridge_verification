`include "ahb_apb_bridge_pkg.sv"

interface ahb_if(input logic HCLK,
	input logic HRESETn);
	//pragma attribute ahb_if partition_interface_xif

	logic HSEL;
	logic [HADDR_SIZE-1:0]HADDR;
	logic [HDATA_SIZE-1:0]HWDATA;
	logic [HDATA_SIZE-1:0]HRDATA;
	logic HWRITE;
	logic [2:0]HSIZE;
	logic [2:0]HBURST;
	logic [3:0]HPROT;
	logic [1:0]HTRANS;
	logic HMASTLOCK;
	logic HREADYOUT;
	logic HREADY;
	logic HRESP;
	
	assign HSEL= 1;
	assign HPROT= 4'b0011;
	assign HREADY= HREADYOUT;
	
	//Property Definitions & Verification by using the assertions for AHB protocol
	//this will be asserted when the slave address exceeds the limit,also applies for configuarable slaves.
	property error_check;
	@(posedge HCLK) disable iff (HTRANS == BUSY || HTRANS == IDLE)
	(HADDR > ((2**10)* 1))|-> (HRESP == 1'b1) || (HRESP == 1'b0); 
	endproperty
	
	//Checks whether the address is in the Read only Memory of Slave,in our case we have considered 1st three address as ROM (Note for Krsihna:This is working,could introduce errors)
	property  read_only_error_check;
	@(posedge HCLK) disable iff ( (HADDR[9:0] > 9'd3))
	(HWRITE == 1'b1) |=> (HRESP == 1);
	endproperty
	
	//assertion- for basic write -> hwrite is detected high at the 2nd clk,at the third clk,hready goes high
	property basic_write;
		@(posedge HCLK) disable iff ((HTRANS==IDLE || HTRANS==BUSY) && HBURST>'0) $rose(HWRITE) |=> HREADY;
	endproperty
	
	//assertion- for basic read -> hwrite is detected low at the 2nd clk,at the third clk,hready goes high
	property basic_read;
		@(posedge HCLK) disable iff ((HTRANS==IDLE || HTRANS==BUSY) && HBURST>'0 || (HADDR > ((2**10)* 1))) $fell(HWRITE) |=> HREADY;
	endproperty
	
	// assertion- for burst write -> hwrite is detected high & htrans is in non sequential state at the 2nd clk,at the third clk,hready goes high,disabled if it is busy in state.
	property basic_burst_write;
	@(posedge HCLK)
	disable iff (HTRANS == BUSY)
	((HWRITE==1)&&(HTRANS == NONSEQ) )|=>	(HREADY=='1) ;
	endproperty	
	
	// assertion- for burst write -> hwrite is detected low & htrans is in non sequential state at the 2nd clk,at the third clk,hready goes high,disabled if it is busy in busy state.
	property basic_burst_read;
	@(posedge HCLK)
	disable iff (HTRANS == BUSY || (HADDR > ((2**10)* 1)))
	((HWRITE=='0)&&(HTRANS == NONSEQ) )|=>	(HREADY=='1) ;
	endproperty	
	
	// assertion for - non_seq to seq transition
	property seq_check;
	@(posedge HCLK)
	(( (HWRITE=='1) || (HWRITE=='0) ) && (HTRANS==NONSEQ) ) |=> (HTRANS == SEQ);
	endproperty
	
	//assertion for HREADY -if HREADY is low then HADDR and HWRITE and HWDATA should remain in the same state until it HREADY goes high.
	property HREADY_check;
	@(posedge HCLK) (HREADY == 1'b0) |=> $stable (HADDR && HWRITE && HWDATA) ;
	endproperty
	
	//idle check is not implemented(Note for Krishna: Shall I remove this?)
	property idle_check;
	@(posedge HCLK) (HTRANS ==IDLE) |=> (HREADY == 1'b1 && HRESP == 1'b0);  // In idle state in the next clock edge hready and hresp must be 1 
	endproperty                                                                           // indicating that the slave is ready for the next transfer.
	
	//checks for 4 incrementing bursts whether the state transitions is going on properly,i.e. non-sequential followed by 3 sequential states
	property bursts_count_check4;                                     
	@(posedge HCLK) disable iff(HTRANS == BUSY || HBURST !=3'b011)  
	(HTRANS == 2'b10) |=> (HTRANS == SEQ)|=> (HTRANS == SEQ)[*2];
	endproperty
	
	//checks for 8 incrementing bursts whether the state transitions is going on properly,i.e. non-sequential followed by 7 sequential states
	property bursts_count_check8;                                
	@(posedge HCLK)disable iff(HTRANS == BUSY || HBURST !=3'b101) 
	(HTRANS == NONSEQ) |=> (HTRANS == SEQ)|=> (HTRANS == SEQ)[*7];
	endproperty
	
	//checks for 16 incrementing bursts whether the state transitions is going on properly,i.e. non-sequential followed by 15 sequential states
	property bursts_count_check16;      
	@(posedge HCLK)disable iff(HTRANS == BUSY  || HBURST !=3'b111) 
	(HTRANS == NONSEQ) |=> (HTRANS == SEQ) |=> (HTRANS == SEQ)[*14];
	endproperty
	
	//checks for 4 incrementing bursts whether the address change is happening over period of next 3 clock cycles 
	property address_change4;
	@(posedge HCLK) disable iff (HBURST!=3'b011)
	(HTRANS == NONSEQ) |=> not ($stable(HADDR)[*3]);
	endproperty
	
	//checks for 8 incrementing bursts whether the address change is happening over period of next 7 clock cycles 
	property address_change8;
	@(posedge HCLK) disable iff (HBURST!=3'b101)
	(HTRANS == NONSEQ) |=> not ($stable(HADDR)[*7]); 
	endproperty
	
	//checks for 16 incrementing bursts whether the address change is happening over period of next 3 clock cycles 
	property address_change16;
	@(posedge HCLK) disable iff (HBURST!=3'b111)
	(HTRANS == NONSEQ) |=> not ($stable(HADDR)[*15]); 
	endproperty
	
	
	
	
	assert property(error_check);
	assert property(read_only_error_check);
	assert property(basic_write);
	assert property(basic_read);
	assert property(basic_burst_write);
	assert property(basic_burst_read);
	assert property(HREADY_check);
	assert property(idle_check);
	assert property(bursts_count_check4);
	assert property(bursts_count_check8);
	assert property(bursts_count_check16);
	assert property(address_change4);
	assert property(address_change8);
	assert property(address_change16);
	
	task ahb_master_driver(input trans_type_t trans_type,
		burst_type_t burst_type,
		size_t trans_size,
		rw_t rw,
		logic [HADDR_SIZE-1:0]addr,
		logic [HADDR_SIZE-1:0]wdata
	);
		//pragma tbx xtf
		@(posedge HCLK);
		
		//Handle reset
		if(!HRESETn) begin
			//$display("AHB Master: Reset Detected...");
			HTRANS<= 0;
			HBURST<= 0;
			HSIZE<= 0;
			HWRITE<= 0;
			HADDR<= 0;
			HWDATA<= 0;
		end
		
		//Handle response from slave
		else if(HRESP == 1) begin
			//$display("AHB Master: Error response from slave...");
		end
		
		//Drive transaction to slave
		else begin
			//$display("AHB Master: Driving transaction to slave...");
			HTRANS<= trans_type;
			HBURST<= burst_type;
			HSIZE<= trans_size;
			HWRITE<= rw;
			HADDR<= addr;
			
			//Drive wdata when slave has completed its previous transaction
			if(!HREADY && rw) begin
				HWDATA<= wdata;
			end
		end
		
	endtask
	
	
	task ahb_master_monitor(output trans_type_t trans_type,
		burst_type_t burst_type,
		size_t trans_size,
		rw_t rw,
		logic [HADDR_SIZE-1:0]addr,
		logic [HADDR_SIZE-1:0]wdata,
		logic [HADDR_SIZE-1:0]rdata
	);
		//pragma tbx xtf
		
		@(posedge HCLK);
		
		if(HRESETn) begin
			//trans_type<= HTRANS;
			//burst_type<= HBURST;
			//trans_size<= HSIZE;
			//rw<= HWRITE;
			$cast(trans_type, HTRANS);
			$cast(burst_type, HBURST);
			$cast(trans_size, HSIZE);
			$cast(rw, HWRITE);
			addr<= HADDR;
			if(rw) begin
				wdata<= HWDATA;
			end
			else begin
				rdata<= HRDATA;
			end
		end
	endtask
	
endinterface