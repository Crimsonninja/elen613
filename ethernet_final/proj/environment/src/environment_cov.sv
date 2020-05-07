//
// Template for UVM-compliant Coverage Class
//

`ifndef ENVIRONMENT_COV__SV
`define ENVIRONMENT_COV__SV

class environment_cov extends uvm_component;
   event cov_event;
   eth_data tr;
   uvm_analysis_imp #(eth_data, environment_cov) cov_export;
   `uvm_component_utils(environment_cov)
 
   covergroup cg_trans @(cov_event);
      coverpoint tr.kind;
      // ToDo: Add required coverpoints, coverbins
   endgroup: cg_trans

  covergroup ethernet_cg  @(posedge environment_top.dut.clk_xgmii_rx) ;
   TX_ENABLE :   coverpoint environment_top.dut.wishbone_if0.cpureg_config0
   {
      bins  enable = {1} ;
      ignore_bins  unused = {0};
   }
   INT_PENDING :   coverpoint environment_top.dut.wishbone_if0.cpureg_int_pending[8:0] ;
   STATUS_CRC_ERROR :   coverpoint environment_top.dut.wishbone_if0.status_crc_error
   {
      bins  enable = {1} ;
      ignore_bins  unused = {0};
   }
   STATUS_FRAGMENT_ERROR :   coverpoint environment_top.dut.wishbone_if0.status_fragment_error
   {
      bins  enable = {1} ;
      ignore_bins  unused = {0};
   }
   STATUS_TXDFIFO_OVFLOW :   coverpoint environment_top.dut.wishbone_if0.status_txdfifo_ovflow
   {
      bins  enable = {1} ;
      ignore_bins  unused = {0};
   }
   STATUS_TXDFIFO_UDFLOW :   coverpoint environment_top.dut.wishbone_if0.status_txdfifo_udflow
   {
      bins  enable = {1} ;
      ignore_bins  unused = {0};
   }
   STATUS_RXDFIFO_OVFLOW :   coverpoint environment_top.dut.wishbone_if0.status_rxdfifo_ovflow
   {
      bins  enable = {1} ;
      ignore_bins  unused = {0};
   }
   STATUS_RXDFIFO_UDFLOW :   coverpoint environment_top.dut.wishbone_if0.status_rxdfifo_udflow
   {
      bins  enable = {1} ;
      ignore_bins  unused = {0};
   }
   STATUS_PAUSE_FRAME_RX :   coverpoint environment_top.dut.wishbone_if0.status_pause_frame_rx
   {
      bins  enable = {1} ;
      ignore_bins  unused = {0};
   }
   STATUS_LOCAL_FAULT :   coverpoint environment_top.dut.wishbone_if0.status_local_fault
   {
      bins  enable = {1} ;
      ignore_bins  unused = {0};
   }
   STATUS_REMOTE_FAULT :   coverpoint environment_top.dut.wishbone_if0.status_remote_fault
   {
      bins  enable = {1} ;
      ignore_bins  unused = {0};
   }

   STATUS_LENGTH_ERROR :   coverpoint environment_top.dut.wishbone_if0.status_lenght_error
   {
      bins  enable = {1} ;
      ignore_bins  unused = {0};
   }

   INT_MASK :    coverpoint environment_top.dut.wishbone_if0.cpureg_int_mask[8:0] ;
   
   TX_OCTETS :   coverpoint environment_top.dut.stats0.stats_tx_octets[31:0]
   {
      bins  ten = { [1:10] } ;
      bins  twenty = { [11:20] } ;
      bins  thirty = { [21:30] } ;
      bins  forty = { [31:40] } ;
      bins  fifty = { [41:50] } ;
      bins  hundred = {[51:100]} ;
      bins  thousand = {[101:1000]} ;
      bins  tenthousand = {[1001:10000]} ;
      bins  hundredthousand = {[100001:1000000]} ;
      bins  million = {[1000000:9999999]} ;
      bins  huge = {[10000000:100000000]} ;
   }
   RX_OCTETS :   coverpoint environment_top.dut.stats0.stats_rx_octets[31:0]
   {
      bins  ten = { [1:10] } ;
      bins  twenty = { [11:20] } ;
      bins  thirty = { [21:30] } ;
      bins  forty = { [31:40] } ;
      bins  fifty = { [41:50] } ;
      bins  hundred = {[51:100]} ;
      bins  thousand = {[101:1000]} ;
      bins  tenthousand = {[1001:10000]} ;
      bins  hundredthousand = {[100001:1000000]} ;
      bins  million = {[1000000:9999999]} ;
      bins  huge = {[10000000:100000000]} ;
   }
   TX_PKTS :     coverpoint environment_top.dut.stats0.stats_tx_pkts[31:0]
   {
      bins  ten = { [1:10] } ;
      bins  twenty = { [11:20] } ;
      bins  thirty = { [21:30] } ;
      bins  forty = { [31:40] } ;
      bins  fifty = { [41:50] } ;
      bins  hundred = {[51:100]} ;
      bins  thousand = {[101:1000]} ;
      bins  tenthousand = {[1001:10000]} ;
      bins  huge = {[10001:1000000]} ;
   }

   RX_PKTS :     coverpoint environment_top.dut.stats0.stats_rx_pkts[31:0]
   {
      bins  ten = { [1:10] } ;
      bins  twenty = { [11:20] } ;
      bins  thirty = { [21:30] } ;
      bins  forty = { [31:40] } ;
      bins  fifty = { [41:50] } ;
      bins  hundred = {[51:100]} ;
      bins  thousand = {[101:1000]} ;
      bins  tenthousand = {[1001:10000]} ;
      bins  huge = {[10001:1000000]} ;
   }
  
  /* PKT_LENGTH:  coverpoint eth_data.pkt_data.size()
   {
      bins  ten = { [1:10] } ;
      bins  twenty = { [11:20] } ;
      bins  thirty = { [21:30] } ;
      bins  forty = { [31:40] } ;
      bins  fifty = { [41:50] } ;
      bins  hundred = {[51:100]} ;
      bins  thousand = {[101:1000]} ;
      bins  tenthousand = {[1001:10000]} ;
      bins  huge = {[10001:1000000]} ;
   }*/

endgroup

   function new(string name, uvm_component parent);
      super.new(name,parent);
      ethernet_cg = new;
      // cg_trans = new;
      cov_export = new("Coverage Analysis",this);
   endfunction: new

   virtual function write(eth_data tr);
      this.tr = tr;
      -> cov_event;
   endfunction: write

endclass: environment_cov

`endif // ENVIRONMENT_COV__SV

