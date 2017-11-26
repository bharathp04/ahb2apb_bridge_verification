`include "ahb_apb_bridge_pkg.sv"

module ahb3lite_apb_bridge #(
  parameter HADDR_SIZE = 32,
  parameter HDATA_SIZE = 32,
  parameter PADDR_SIZE = 10,
  parameter PDATA_SIZE =  8,
  parameter SYNC_DEPTH =  3
)
(

	ahb_if ahb_iface,
	apb_if apb_iface
);
  ////AHB Slave Interface
  //input                         ahb_iface.HRESETn,
  //                              ahb_iface.HCLK,
  //input                         ahb_iface.HSEL,
  //input      [HADDR_SIZE  -1:0] ahb_iface.HADDR,
  //input      [HDATA_SIZE  -1:0] ahb_iface.HWDATA,
  //output reg [HDATA_SIZE  -1:0] ahb_iface.HRDATA,
  //input                         ahb_iface.HWRITE,
  //input      [             2:0] ahb_iface.HSIZE,
  //input      [             2:0] ahb_iface.HBURST,
  //input      [             3:0] ahb_iface.HPROT,
  //input      [             1:0] ahb_iface.HTRANS,
  //input                         ahb_iface.HMASTLOCK,
  //output reg                    ahb_iface.HREADYOUT,
  //input                         ahb_iface.HREADY,
  //output reg                    ahb_iface.HRESP,
  //
  ////APB Master Interface
  //input                         apb_iface.PRESETn,
  //                              apb_iface.PCLK,
  //output reg                    apb_iface.PSEL,
  //output reg                    apb_iface.PENABLE,
  //output reg [             2:0] apb_iface.PPROT,
  //output reg                    apb_iface.PWRITE,
  //output reg [PDATA_SIZE/8-1:0] apb_iface.PSTRB,
  //output reg [PADDR_SIZE  -1:0] apb_iface.PADDR,
  //output reg [PDATA_SIZE  -1:0] apb_iface.PWDATA,
  //input      [PDATA_SIZE  -1:0] apb_iface.PRDATA,
  //input                         apb_iface.PREADY,
  //input                         apb_iface.PSLVERR
  //////////////////////////////////////////////////////////////////
  //
  // Constants
  //

  typedef enum logic [1:0] {ST_AHB_IDLE=2'b00, ST_AHB_TRANSFER=2'b01, ST_AHB_ERROR=2'b10} ahb_fsm_states;
  typedef enum logic [1:0] {ST_APB_IDLE=2'b00, ST_APB_SETUP=2'b01, ST_APB_TRANSFER=2'b10} apb_fsm_states;


  //apb_iface.PPROT
  localparam [2:0] PPROT_NORMAL      = 3'b000,
                   PPROT_PRIVILEGED  = 3'b001,
                   PPROT_SECURE      = 3'b000,
                   PPROT_NONSECURE   = 3'b010,
                   PPROT_DATA        = 3'b000,
                   PPROT_INSTRUCTION = 3'b100;

  //SYNC_DEPTH
  localparam SYNC_DEPTH_MIN = 3;
  localparam SYNC_DEPTH_CHK = SYNC_DEPTH > SYNC_DEPTH_MIN ? SYNC_DEPTH : SYNC_DEPTH_MIN;


  ////////////////////////////////////////////////////////////////
  //
  // Checks (assertions)
  //
  initial
  begin
      //check if ahb_iface.HRDATA/ahb_iface.HWDATA/apb_iface.PRDATA/apb_iface.PWDATA are multiples of bytes
      a1: assert (HDATA_SIZE % 8 ==0)
          else $error("HDATA_SIZE must be an integer multiple of bytes (8bits)");

      a2: assert (PDATA_SIZE % 8 ==0)
          else $error("PDATA_SIZE must be an integer multiple of bytes (8bits)");


      //Check if PDATA_SIZE <= HDATA_SIZE
      a3: assert (PDATA_SIZE <= HDATA_SIZE)
          else $error("PDATA_SIZE must be less than or equal to HDATA_SIZE (PDATA_SIZE <= HDATA_SIZE");


      //Check SYNC_DEPTH >= 3
      a4: assert (SYNC_DEPTH >= SYNC_DEPTH_MIN)
          else $warning("SYNC_DEPTH=%0d is less than minimum. Changed to %0d", SYNC_DEPTH, SYNC_DEPTH_CHK);

  end


  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  logic                      ahb_treq;      //transfer request from AHB Statemachine
  logic                      treq_toggle;   //toggle-signal-version
  logic [SYNC_DEPTH_CHK-1:0] treq_sync;     //synchronized transfer request
  logic                      apb_treq_strb; //transfer request strobe to APB Statemachine

  logic                      apb_tack;      //transfer acknowledge from APB Statemachine
  logic                      tack_toggle;   //toggle-signal-version
  logic [SYNC_DEPTH_CHK-1:0] tack_sync;     //synchronized transfer acknowledge
  logic                      ahb_tack_strb; //transfer acknowledge strobe to AHB Statemachine


  //store AHB data locally (pipelined bus)
  logic [HADDR_SIZE    -1:0] ahb_haddr;
  logic [HDATA_SIZE    -1:0] ahb_hwdata;
  logic                      ahb_hwrite;
  logic [               2:0] ahb_hsize;
  logic [               3:0] ahb_hprot;

  logic                      latch_ahb_hwdata;


  //store APB data locally
  logic [HDATA_SIZE    -1:0] apb_prdata;
  logic                      apb_pslverr;


  //State machines
  ahb_fsm_states             ahb_fsm;
  apb_fsm_states             apb_fsm;


  //number of transfer cycles (AMBA-beats) on APB interface
  logic [               6:0] apb_beat_cnt;

  //running offset in ahb_iface.HWDATA
  logic [               9:0] apb_beat_data_offset;


  //////////////////////////////////////////////////////////////////
  //
  // Tasks
  //
  task ahb_no_transfer;
     ahb_fsm   <= ST_AHB_IDLE;

     ahb_iface.HREADYOUT <= 1'b1;
     ahb_iface.HRESP     <= HRESP_OKAY;
  endtask //ahb_no_transfer


  task ahb_prep_transfer;
     ahb_fsm    <= ST_AHB_TRANSFER;

     ahb_iface.HREADYOUT  <= 1'b0; //hold off master
     ahb_iface.HRESP      <= HRESP_OKAY;
     ahb_treq   <= 1'b1; //request data transfer
  endtask //ahb_prep_transfer


  //////////////////////////////////////////////////////////////////
  //
  // Functions
  //
  function logic [6:0] apb_beats;
    input [2:0] hsize;

    case (hsize)
       HSIZE_B1024: apb_beats = 1023/PDATA_SIZE; 
       HSIZE_B512 : apb_beats =  511/PDATA_SIZE;
       HSIZE_B256 : apb_beats =  255/PDATA_SIZE;
       HSIZE_B128 : apb_beats =  127/PDATA_SIZE;
       HSIZE_DWORD: apb_beats =   63/PDATA_SIZE;
       HSIZE_WORD : apb_beats =   31/PDATA_SIZE;
       HSIZE_HWORD: apb_beats =   15/PDATA_SIZE;
       default    : apb_beats =    7/PDATA_SIZE;
    endcase
  endfunction //apb_beats


  function logic [6:0] address_mask;
    input integer data_size;

    //Which bits in ahb_iface.HADDR should be taken into account?
    case (data_size)
          1024: address_mask = 7'b111_1111; 
           512: address_mask = 7'b011_1111;
           256: address_mask = 7'b001_1111;
           128: address_mask = 7'b000_1111;
            64: address_mask = 7'b000_0111;
            32: address_mask = 7'b000_0011;
            16: address_mask = 7'b000_0001;
       default: address_mask = 7'b000_0000;
    endcase
  endfunction //address_mask


  function logic [9:0] data_offset (input [HADDR_SIZE-1:0] haddr);
    logic [6:0] haddr_masked;

    //Generate masked address
    haddr_masked = haddr & address_mask(HDATA_SIZE);

    //calculate bit-offset
    data_offset = 8 * haddr_masked;
  endfunction //data_offset


  function logic [PDATA_SIZE/8-1:0] pstrb;
    input [           2:0] hsize;
    input [PADDR_SIZE-1:0] paddr;

    logic [127:0] full_pstrb;
    logic [  6:0] paddr_masked;

    //get number of active lanes for a 1024bit databus (max width) for this ahb_iface.HSIZE
    case (hsize)
       HSIZE_B1024: full_pstrb = 'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff; 
       HSIZE_B512 : full_pstrb = 'hffff_ffff_ffff_ffff;
       HSIZE_B256 : full_pstrb = 'hffff_ffff;
       HSIZE_B128 : full_pstrb = 'hffff;
       HSIZE_DWORD: full_pstrb = 'hff;
       HSIZE_WORD : full_pstrb = 'hf;
       HSIZE_HWORD: full_pstrb = 'h3;
       default    : full_pstrb = 'h1;
    endcase

    //generate masked address
    paddr_masked = paddr & address_mask(PDATA_SIZE);

    //create apb_iface.PSTRB
    pstrb = full_pstrb[PDATA_SIZE/8-1:0] << paddr_masked;
  endfunction //pstrb


  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //

  /*
   * AHB Statemachine
   */
  always @(posedge ahb_iface.HCLK,negedge ahb_iface.HRESETn)
    if (!ahb_iface.HRESETn)
    begin
        ahb_fsm    <= ST_AHB_IDLE;

        ahb_iface.HREADYOUT  <= 1'b1;
        ahb_iface.HRESP      <= HRESP_OKAY;

        ahb_treq   <= 1'b0;
        ahb_haddr  <=  'h0;
        ahb_hwrite <= 1'b0;
        ahb_hprot  <=  'h0;
        ahb_hsize  <=  'h0;
    end
    else
    begin
        ahb_treq <= 1'b0; //1 cycle strobe signal

        case (ahb_fsm)
           ST_AHB_IDLE:
           begin
               //store basic parameters
               ahb_haddr  <= ahb_iface.HADDR;
               ahb_hwrite <= ahb_iface.HWRITE;
               ahb_hprot  <= ahb_iface.HPROT;
               ahb_hsize  <= ahb_iface.HSIZE;

               if (ahb_iface.HSEL && ahb_iface.HREADY)
               begin
                   /*
                    * This (slave) is selected ... what kind of transfer is this?
                    */
                   case (ahb_iface.HTRANS)
                      HTRANS_IDLE  : ahb_no_transfer;
                      HTRANS_BUSY  : ahb_no_transfer;
                      HTRANS_NONSEQ: ahb_prep_transfer;
                      HTRANS_SEQ   : ahb_prep_transfer;
                   endcase //ahb_iface.HTRANS
               end
               else ahb_no_transfer;
           end

           ST_AHB_TRANSFER:
           if (ahb_tack_strb)
           begin
               /*
                * APB acknowledged transfer. Current transfer done
                * Check AHB bus to determine if another transfer is pending
                */

               //assign read data
               ahb_iface.HRDATA <= apb_prdata; 

               //indicate transfer done. Normally ahb_iface.HREADYOUT = '1', ahb_iface.HRESP=OKAY
               //ahb_iface.HRESP=ERROR requires 2 cycles
               if (apb_pslverr)
               begin
                   ahb_iface.HREADYOUT <= 1'b0;
                   ahb_iface.HRESP     <= HRESP_ERROR;
                   ahb_fsm   <= ST_AHB_ERROR;
               end
               else
               begin
                   ahb_iface.HREADYOUT <= 1'b1;
                   ahb_iface.HRESP     <= HRESP_OKAY;
                   ahb_fsm   <= ST_AHB_IDLE;
               end
           end
           else
           begin
               ahb_iface.HREADYOUT <= 1'b0; //transfer still in progress
           end

           ST_AHB_ERROR:
           begin
               //2nd cycle of error response
               ahb_fsm   <= ST_AHB_IDLE;
               ahb_iface.HREADYOUT <= 1'b1;
           end
        endcase //ahb_fsm
    end


  always @(posedge ahb_iface.HCLK)
    latch_ahb_hwdata <= ahb_iface.HSEL & ahb_iface.HREADY & ahb_iface.HWRITE & ((ahb_iface.HTRANS == HTRANS_NONSEQ) || (ahb_iface.HTRANS == HTRANS_SEQ));

  always @(posedge ahb_iface.HCLK)
    if (latch_ahb_hwdata) ahb_hwdata <= ahb_iface.HWDATA;



  /*
   * Clock domain crossing ...
   */
  //AHB -> APB
  always @(posedge ahb_iface.HCLK,negedge ahb_iface.HRESETn)
    if      (!ahb_iface.HRESETn ) treq_toggle <= 1'b0;
    else if ( ahb_treq) treq_toggle <= ~treq_toggle;


  always @(posedge apb_iface.PCLK,negedge apb_iface.PRESETn)
    if (!apb_iface.PRESETn) treq_sync <= 'h0;
    else          treq_sync <= {treq_sync[SYNC_DEPTH-2:0], treq_toggle};


  assign apb_treq_strb = treq_sync[SYNC_DEPTH-1] ^ treq_sync[SYNC_DEPTH-2];


  //APB -> AHB
  always @(posedge apb_iface.PCLK,negedge apb_iface.PRESETn)
    if      (!apb_iface.PRESETn ) tack_toggle <= 1'b0;
    else if ( apb_tack) tack_toggle <= ~tack_toggle;


  always @(posedge ahb_iface.HCLK,negedge ahb_iface.HRESETn)
    if (!ahb_iface.HRESETn) tack_sync <= 'h0;
    else          tack_sync <= {tack_sync[SYNC_DEPTH-2:0], tack_toggle};


  assign ahb_tack_strb = tack_sync[SYNC_DEPTH-1] ^ tack_sync[SYNC_DEPTH-2];


  /*
   * APB Statemachine
   */
  always @(posedge apb_iface.PCLK,negedge apb_iface.PRESETn)
    if (!apb_iface.PRESETn)
    begin
        apb_fsm        <= ST_APB_IDLE;
        apb_tack       <= 1'b0;

        apb_iface.PSEL    <= 1'b0;
        apb_iface.PPROT   <= 1'b0;
        apb_iface.PADDR   <= 'h0;
        apb_iface.PWRITE  <= 1'b0;
        apb_iface.PENABLE <= 1'b0;
        apb_iface.PWDATA  <= 'h0;
        apb_iface.PSTRB   <= 'h0;
    end
    else
    begin
        apb_tack <= 1'b0;

        case (apb_fsm)
           ST_APB_IDLE:
             if (apb_treq_strb)
             begin
                 apb_fsm              <= ST_APB_SETUP;

                 apb_iface.PSEL                 <= 1'b1;
                 apb_iface.PENABLE              <= 1'b0;
                 apb_iface.PPROT                <= ((ahb_hprot & HPROT_DATA      ) ? PPROT_DATA       : PPROT_INSTRUCTION) |
                                         ((ahb_hprot & HPROT_PRIVILEGED) ? PPROT_PRIVILEGED : PPROT_NORMAL     );
                 apb_iface.PADDR                <= ahb_haddr[PADDR_SIZE-1:0];
                 apb_iface.PWRITE               <= ahb_hwrite;
                 apb_iface.PWDATA               <= ahb_hwdata >> data_offset(ahb_haddr);
                 apb_iface.PSTRB                <= ahb_hwrite & pstrb(ahb_hsize,ahb_haddr[PADDR_SIZE-1:0]); //TODO: check/sim

                 apb_prdata           <= 'h0;                                   //clear prdata
                 apb_beat_cnt         <= apb_beats(ahb_hsize);
                 apb_beat_data_offset <= data_offset(ahb_haddr) + PDATA_SIZE;   //for the NEXT transfer
             end

           ST_APB_SETUP:
             begin
                 //retain all signals and assert apb_iface.PENABLE
                 apb_fsm <= ST_APB_TRANSFER;
                 apb_iface.PENABLE <= 1'b1;
             end

           ST_APB_TRANSFER:
             if (apb_iface.PREADY)
             begin
                 apb_beat_cnt         <= apb_beat_cnt -1;
                 apb_beat_data_offset <= apb_beat_data_offset + PDATA_SIZE;

                 apb_prdata           <= (apb_prdata << PDATA_SIZE) | (apb_iface.PRDATA << data_offset(ahb_haddr));//TODO: check/sim
                 apb_pslverr          <= apb_iface.PSLVERR;

                 apb_iface.PENABLE              <= 1'b0;

                 if (apb_iface.PSLVERR || ~|apb_beat_cnt)
                 begin
                     /*
                      * Transfer complete
                      * Go back to IDLE
                      * Signal AHB fsm, transfer complete
                      */
                     apb_fsm  <= ST_APB_IDLE;
                     apb_tack <= 1'b1;
                     apb_iface.PSEL     <= 1'b0;
                 end
                 else
                 begin
                     /*
                      * More beats in current transfer
                      * Setup next address and data
                      */
                     apb_fsm       <= ST_APB_SETUP;

                     apb_iface.PADDR  <= apb_iface.PADDR + (1 << ahb_hsize);
                     apb_iface.PWDATA <= ahb_hwdata >> apb_beat_data_offset;
                     apb_iface.PSTRB  <= ahb_hwrite & pstrb(ahb_hsize,apb_iface.PADDR + (1 << ahb_hsize));
                 end
             end
        endcase
    end

endmodule