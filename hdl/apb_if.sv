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
	
	// Reusable property to check that a signal is in safe state
	property SIGNAL_VALID(signal);
		@(posedge PCLK)
		!$isunknown(signal);
	endproperty: SIGNAL_VALID
	
	RESET_VALID: assert property(SIGNAL_VALID(PRESETn));
	PSEL_VALID: assert property(SIGNAL_VALID(PSEL));
	
	// Reusable property to check that if any PSEL is active, then
	// the signal is valid.
	property CONTROL_SIGNAL_VALID(signal);
		@(posedge PCLK)
		$onehot(PSEL) |-> !$isunknown(signal);
	endproperty: CONTROL_SIGNAL_VALID
	
	PADDR_VALID: assert property(CONTROL_SIGNAL_VALID(PADDR));
	PWRITE_VALID: assert property(CONTROL_SIGNAL_VALID(PADDR));
	PENABLE_VALID: assert property(CONTROL_SIGNAL_VALID(PENABLE));
	
	// Check that write data is valid if a write
	property PWDATA_SIGNAL_VALID;
		@(posedge PCLK)
		($onehot(PSEL) && PWRITE) |-> !$isunknown(PWDATA);
	endproperty: PWDATA_SIGNAL_VALID
	
	PWDATA_VALID: assert property(PWDATA_SIGNAL_VALID);
	
	// Check that if PENABLE is active, then the signal is valid
	property PENABLE_SIGNAL_VALID(signal);
		@(posedge PCLK)
		$rose(PENABLE) |-> !$isunknown(signal)[*1:$] ##1 $fell(PENABLE);
	endproperty: PENABLE_SIGNAL_VALID
	
	PREADY_VALID: assert property(PENABLE_SIGNAL_VALID(PREADY));
	
	// Check if PREADY is active, then PSLVERR is valid
	property PSLVERR_SIGNAL_VALID;
		@(posedge PCLK)
		PREADY |-> !$isunknown(PSLVERR);
	endproperty: PSLVERR_SIGNAL_VALID
	
	PSLVERR_VALID: assert property(PSLVERR_SIGNAL_VALID);
	
	// Check that read data is valid if a read
	property PRDATA_SIGNAL_VALID;
		@(posedge PCLK)
		($rose(PENABLE && !PWRITE && PREADY)) |-> !$isunknown(PRDATA)[*1:$] ##1 $fell(PENABLE);
	endproperty: PRDATA_SIGNAL_VALID
	
	PRDATA_VALID: assert property(PRDATA_SIGNAL_VALID);
	
	
	// Timing relationship checks
	//
	// When PREADY is active, signal is de-asserted in next cycle.
	property PREADY_SIGNAL_DEASSERTED(signal);
		@(posedge PCLK)
		$rose(PREADY) |=> $fell(signal); 
	endproperty: PREADY_SIGNAL_DEASSERTED
	
	PREADY_DEASSERT: assert property(PREADY_SIGNAL_DEASSERTED(PREADY));
	COV_PREADY_DEASSERT: cover property(PREADY_SIGNAL_DEASSERTED(PREADY));
	PENABLE_DEASSERT: assert property(PREADY_SIGNAL_DEASSERTED(PENABLE));
	COV_PENABLE_DEASSERT: cover property(PREADY_SIGNAL_DEASSERTED(PENABLE));
	
	
	// When PSEL is active, PENABLE goes high in next cycle.
	property PSEL_TO_PENABLE_ACTIVE;
		@(posedge PCLK)
		(!$stable(PSEL) && $onehot(PSEL)) |=> $rose(PENABLE);
	endproperty: PSEL_TO_PENABLE_ACTIVE
	
	PSEL_TO_PENABLE: assert property(PSEL_TO_PENABLE_ACTIVE);
	COV_PSEL_TO_PENABLE: cover property(PSEL_TO_PENABLE_ACTIVE);
	
	// From PSEL being active, the signal must be stable until end of transaction
	property PSEL_ASSERT_SIGNAL_STABLE(signal);
		@(posedge PCLK)
	(!$stable(PSEL) && $onehot(PSEL)) |=> $stable(signal)[*1:$] ##1 $fell(PENABLE);
	endproperty: PSEL_ASSERT_SIGNAL_STABLE
	
	PSEL_STABLE: assert property(PSEL_ASSERT_SIGNAL_STABLE(PSEL));
	COV_PSEL_STABLE: cover property(PSEL_ASSERT_SIGNAL_STABLE(PSEL));
	PWRITE_STABLE: assert property(PSEL_ASSERT_SIGNAL_STABLE(PWRITE));
	COV_PWRITE_STABLE: cover property(PSEL_ASSERT_SIGNAL_STABLE(PWRITE));
	PADDR_STABLE: assert property(PSEL_ASSERT_SIGNAL_STABLE(PADDR));
	COV_PADDR_STABLE: cover property(PSEL_ASSERT_SIGNAL_STABLE(PADDR));
	PWDATA_STABLE: assert property(PSEL_ASSERT_SIGNAL_STABLE(PWDATA));
	COV_PWDATA_STABLE: cover property(PSEL_ASSERT_SIGNAL_STABLE(PWDATA));
	
	// Other checks
	//
	// PSEL is onehot, at most one line can be active
	property PSEL_ONEHOT;
		@(posedge PCLK)
		$onehot0(PSEL);
	endproperty: PSEL_ONEHOT
	
	PSEL_ONLY_ONE: assert property(PSEL_ONEHOT);
	
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