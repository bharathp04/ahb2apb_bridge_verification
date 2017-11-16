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
	
	task ahb_master_driver(input logic [2:0]trans_type,
		logic [2:0]burst_type,
		logic [2:0]trans_size,
		logic rw,
		logic [HADDR_SIZE-1:0]addr,
		logic [HADDR_SIZE-1:0]wdata
	);
		
		@(posedge HCLK);
		
		//Handle reset
		if(!HRESETn) begin
			$display("AHB Master: Reset Detected...");
			HTRANS<= 0;
			HBURST<= 0;
			HSIZE<= 0;
			HWRITE<= 0;
			HADDR<= 0;
			HWDATA<= 0;
		end
		
		//Handle response from slave
		else if(HRESP == 1) begin
			$display("AHB Master: Error response from slave...");
		end
		
		//Drive transaction to slave
		else begin
			$display("AHB Master: Driving transaction to slave...");
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
	
	
	task ahb_master_monitor(output logic [2:0]trans_type,
		logic [2:0]burst_type,
		logic [2:0]trans_size,
		logic rw,
		logic [HADDR_SIZE-1:0]addr,
		logic [HADDR_SIZE-1:0]wdata,
		logic [HADDR_SIZE-1:0]rdata
	);
		
		@(posedge HCLK);
		
		if(HRESETn) begin
			trans_type<= HTRANS;
			burst_type<= HBURST;
			trans_size<= HSIZE;
			rw<= HWRITE;
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