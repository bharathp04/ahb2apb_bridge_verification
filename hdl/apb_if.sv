`include "ahb_apb_bridge_pkg.sv"

interface apb_if(input logic PCLK,
	input logic PRESETn);
	//pragma attribute apb_if partition_interface_xif

	logic PSEL;
	logic PENABLE;
	logic [2:0] PPROT;
	logic PWRITE;
	logic [PDATA_SIZE/8-1:0] PSTRB;
	logic [PDATA_SIZE  -1:0] PADDR;
	logic [PDATA_SIZE  -1:0] PWDATA;
	logic [PDATA_SIZE  -1:0] PRDATA;
	logic PREADY;
	logic PSLVERR;
	
	task apb_slave_driver(input logic [PDATA_SIZE -1:0] prdata,
							logic pready,
							logic pslverr
	);
		//pragma tbx xtf
		
		@(posedge PCLK);

		if(!PRESETn) begin
			//$display("APB Slave: Reset Detected....");
			PRDATA<= 0;
			PREADY<= 0;
			PSLVERR<=0;
		end
		//Drive transaction to Master
		else begin
			//$display("APB Slave: Driving transaction to Master...");
			PREADY<= pready;;
			PSLVERR<= pslverr;

			//Drive rdata when slave is ready to send
			while(!PENABLE) @(posedge PCLK);
			
			if(!PWRITE && pready && PSEL) begin
				PRDATA<= prdata;				
			end
		end
		
	endtask
	
	task apb_slave_monitor(output logic pwrite,
							logic [PDATA_SIZE  -1:0] paddr,
							logic [PDATA_SIZE  -1:0] pwdata,
							logic [PDATA_SIZE  -1:0] prdata,
							logic pslverr
	);
		//pragma tbx xtf
		
		@(posedge PCLK);
		
		if(PRESETn) begin
			pwrite<= PWRITE;
			paddr<= PADDR;
			pslverr<= PSLVERR;
			if(pwrite) begin
				pwdata<= PWDATA;
			end
			else begin
				prdata<= PRDATA;
			end
		end
	endtask	
	
endinterface