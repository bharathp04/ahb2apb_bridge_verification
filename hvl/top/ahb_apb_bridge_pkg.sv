package ahb_apb_bridge_pkg;
	parameter HADDR_SIZE= 32;
	parameter HDATA_SIZE= 32;
	parameter PDATA_SIZE= 32;
	
	typedef enum logic [1:0]{IDLE, BUSY, NONSEQ, SEQ} trans_type_t;
	typedef enum logic {READ, WRITE} rw_t;
	typedef enum logic [2:0]{SINGLE, INCR, WRAP4, INCR4, WRAP8, INCR8, WRAP16, INCR16} burst_type_t;
	typedef enum logic [1:0]{BYTE, HALFWORD, WORD} size_t;
	typedef enum logic {OKAY, ERROR} resp_t;
	
	`include "ahb_apb_env.svh"
	`include "ahb_apb_virtual_sequences.svh"
	`include "ahb_master_agent.svh"
	`include "ahb_master_driver.svh"
	`include "ahb_master_monitor.svh"
	`include "ahb_master_sequencer.svh"
	`include "ahb_master_sequences.svh"
	`include "ahb_master_transaction.svh"
	`include "apb_slave_agent.svh"
	`include "apb_slave_driver.svh"
	`include "apb_slave_monitor.svh"
	`include "apb_slave_sequencer.svh"
	`include "apb_slave_sequences.svh"
	`include "apb_slave_transaction.svh"
	`include "ahb_apb_config.svh"
	`include "ahb_apb_tests.svh"
	
endpackage

import ahb_apb_bridge_pkg::*;