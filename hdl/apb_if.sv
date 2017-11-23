import ahb3lite_pkg::*;

interface apb_if;
	logic PRESETn;
	logic PCLK;
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

		@(posedge PCLK);

		if(!PRESETn) begin
			$display("APB Slave: Reset Detected....");
			PRDATA<= 0;
			PREADY<= 0;
			PSLVERR<=0;
			PADDR<=0;
			PWDATA<=0;
	
		//Drive transaction to Master
		else begin
			$display("APB Master: Driving transaction to Master...");
			PREADY<= pready;;
			PSLVERR<= pslverr;

			//Drive rdata when slave is ready to send
			if(!PWRITE && PENABLE && PREADY) begin
				PRDATA<= prdata;				
			end
		end
		
	endtask
	
	task apb_slave_monitor(output logic [2:0] pprot,
							logic psel,
							logic penable,
							logic pwrite,
							logic [PDATA_SIZE/8-1:0] pstrb,
							logic [PDATA_SIZE  -1:0] paddr,
							logic [PDATA_SIZE  -1:0] pwdata,
							logic [PDATA_SIZE  -1:0] prdata,
							logic pready,
							logic pslverr
	);

		@(posedge PCLK);
		
		if(PRESETn) begin
			pprot<= PPROT;
			psel<= PSEL;
			penable<= PENABLE;
			pwrite<= PWRITE;
			pstrb<= PSTRB;
			paddr<= PADDR;
			pwdata<= PWDATA;
			prdata<= PRDATA;
			pready<= PREADY;
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