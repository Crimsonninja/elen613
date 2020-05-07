//
// Template for UVM-compliant interface
//

`ifndef RX_INTF__SV
`define RX_INTF__SV

interface rx_intf (input bit clk156m25, input bit reset_156m25_n);

   // ToDo: Define default setup & hold times

   parameter setup_time = 5/*ns*/;
   parameter hold_time  = 3/*ns*/;

   // ToDo: Define synchronous and asynchronous signals as wires

   logic       async_en;
   logic       async_rdy;

   logic [63:0] pkt_rx_data;
   logic pkt_rx_avail;
   logic pkt_rx_eop;
   logic pkt_rx_err;
   logic [2:0] pkt_rx_mod;
   logic pkt_rx_sop;
   logic pkt_rx_val;
   logic pkt_rx_ren;

   // ToDo: Define one clocking block per clock domain
   //       with synchronous signal direction from a
   //       master perspective

   clocking mck @(posedge clk156m25);
      default input #setup_time output #hold_time;
output pkt_rx_ren;
input pkt_rx_eop, pkt_rx_err, pkt_rx_mod, pkt_rx_sop, pkt_rx_val, pkt_rx_avail, pkt_rx_data;
      // ToDo: List the synchronous signals here

   endclocking: mck

   clocking sck @(posedge clk156m25);
      default input #setup_time output #hold_time;

      // ToDo: List the synchronous signals here

   endclocking: sck

   clocking pck @(posedge clk156m25);
      default input #setup_time output #hold_time;
input pkt_rx_eop, pkt_rx_err, pkt_rx_mod, pkt_rx_sop, pkt_rx_val, pkt_rx_avail, pkt_rx_data;
output pkt_rx_ren;
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

endinterface: rx_intf

`endif // RX_INTF__SV
