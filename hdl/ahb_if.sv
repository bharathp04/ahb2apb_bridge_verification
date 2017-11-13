import ahb3lite_pkg::*;

interface ahb_if;
	logic HRESETn;
	logic HCLK;
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
	
	task ahb_master_driver(input logic [2:0]burst_mode,
		logic [2:0]trans_size,
		logic rw_sig,
		);
		fork
			begin: driver
				wait(HRESETn);
				disable resp_handler;
				disable rst_handler;
				drive();
			end: driver
			
			begin: resp_handler
				wait(HRESETn);
				
				//If error response, change the transfer type to idle
				wait(HRESP);
				disable driver;
				disable rst_handler;
				@(posedge HCLK);
				HTRANS<= HTRANS_IDLE;
			end: resp_handler
			
			begin: rst_handler
				forever begin
					wait(!HRESETn);
					$display("Reset Detected...");
					disable driver;
					disable resp_handler;
					HTRANS<= 0;
					HBURST<= 0;
					HSIZE<= 0;
					HWRITE<= 0;
					HADDR<= 0;
					HWDATA<= 0;
					
					@(posedge HCLK);
					if(HRESETn) begin
						disable rst_handler;
					end
				end
			end: rst_handler
		join
	endtask: ahb_master_driver
	
	task drive;
		int j= 0; //To iterate through transfer type
		$display("Transaction from AHB Master...");
		
		//Transfer Control signals
		HBURST<= burst_mode;
		HSIZE<= trans_size;
		HWRITE<= rw_sig;
		
		//Transfer an address and corresponding trans_type every cycle
		foreach(address[i]) begin
			HADDR<= address[i];
			
			//While transfer type is busy, maintain same address and don't drive data
			while(trans_type[j] == HTRANS_BUSY) begin
				HTRANS<= trans_type[j];
				@(posedge HCLK);
				j<= j+1;
			end
			
			HTRANS<= trans_type[j];
			
			//Wait for HREADY to go low indicating previous transfer is complete
			while(!HREADY) @(posedge HCLK);
			
			//Write data if write transaction
			if(rw_sig) begin
				HWDATA<= w_data[i];
			end
			
			
		end
	endtask: drive
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
endinterface