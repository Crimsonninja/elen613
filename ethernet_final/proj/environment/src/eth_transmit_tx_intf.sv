//
// Template for UVM-compliant interface
//

`ifndef TX_INTF__SV
`define TX_INTF__SV

interface tx_intf (input bit clk156m25, input bit reset_156m25_n);

   // ToDo: Define default setup & hold times

   parameter setup_time = 5/*ns*/;
   parameter hold_time  = 3/*ns*/;

   // ToDo: Define synchronous and asynchronous signals as wires
   
   logic       async_en;
   logic       async_rdy;

   logic [63:0] pkt_tx_data;
   logic pkt_tx_eop;
   logic [2:0] pkt_tx_mod;
   logic pkt_tx_sop;
   logic pkt_tx_val;
   logic pkt_tx_full;

   // ToDo: Define one clocking block per clock domain
   //       with synchronous signal direction from a
   //       master perspective

   clocking mck @(posedge clk156m25);
      default input #setup_time output #hold_time;
output pkt_tx_data, pkt_tx_eop, pkt_tx_mod, pkt_tx_sop, pkt_tx_val;
input pkt_tx_full;
      // ToDo: List the synchronous signals here

   endclocking: mck

   clocking sck @(posedge clk156m25);
      default input #setup_time output #hold_time;

      // ToDo: List the synchronous signals here

   endclocking: sck

   clocking pck @(posedge clk156m25);
      default input #setup_time output #hold_time;
input pkt_tx_data, pkt_tx_eop, pkt_tx_mod, pkt_tx_sop, pkt_tx_val, pkt_tx_full;
      //ToDo: List the synchronous signals here

   endclocking: pck

   modport master(clocking mck,
                  output async_en,
                  input  async_rdy);

   modport slave(clocking sck,
                 input  async_en,
                 output async_rdy);

   modport passive(clocking pck,
                   input async_en,
                   input async_rdy);

endinterface: tx_intf

`endif // TX_INTF__SV
