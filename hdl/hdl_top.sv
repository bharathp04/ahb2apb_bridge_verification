module hdl_top;

	//Instantiate AHB and APB interfaces
	ahb_if ahb_iface();
	apb_if apb_iface();
	
	//Instantiate DUV
	ahb3lite_apb_bridge duv(.ahb_iface(ahb_iface), .apb_iface(apb_iface));

endmodule