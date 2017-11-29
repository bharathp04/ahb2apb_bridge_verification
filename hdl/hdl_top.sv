module hdl_top;
	
	logic HCLK;
	logic PCLK;
	logic HRESETn;
	logic PRESETn;
	
	//Instantiate AHB and APB interfaces
	ahb_if ahb_iface(HCLK, HRESETn);
	apb_if apb_iface(PCLK, PRESETn);
	
	//tbx clkgen
	initial begin
		PCLK= 0;
		forever begin
			#5 PCLK= ~PCLK;
		end
	end
	
	//tbx clkgen
	initial begin
		PRESETn= 0;
		#20 PRESETn= 1;
	end
	
	//tbx clkgen
	initial begin
		HCLK= 0;
		forever begin
			#5 HCLK= ~HCLK;
		end
	end
	
	//tbx clkgen
	initial begin
		HRESETn= 0;
		#20 HRESETn= 1;
	end
	
	//Instantiate DUV
	ahb3lite_apb_bridge duv(.ahb_iface(ahb_iface), .apb_iface(apb_iface));

endmodule