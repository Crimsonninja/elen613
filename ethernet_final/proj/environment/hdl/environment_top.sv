`timescale 1ns/1ps

//
// Template for Top module
//

`ifndef ENVIRONMENT_TOP__SV
`define ENVIRONMENT_TOP__SV

`include "../src/eth_wishbone_intf.sv"
`include "eth.v"
`include "defines.v"

module environment_top();

   logic clk;
   logic rst;

   // Clock Generation
   parameter sim_cycle = 10;
   
   // Reset Delay Parameter
   parameter rst_delay = 50;

   always 
      begin
         #(sim_cycle/2) clk = ~clk;
      end

   tx_intf mst_if(clk,rst);
   rx_intf slv_if(clk,rst);
   wb_intf wb_if(clk, rst);   
   environment_tb_mod test(); 
   
   logic clk_xgmii_tx;
   logic clk_xgmii_rx;
   logic reset_xgmii_tx_n;
   logic reset_xgmii_rx_n;

   wire [7:0] xgmii_txc;
   wire [63:0] xgmii_txd;
   wire [7:0] xgmii_rxc;
   wire [63:0] xgmii_rxd;

   // ToDo: Include Dut instance here
  xge_mac dut(.wb_clk_i(clk),
              .clk_xgmii_tx(clk),
              .clk_xgmii_rx(clk),
              .clk_156m25(clk),
              .wb_rst_i(wb_if.wb_rst_i),
              .wb_adr_i(wb_if.wb_adr_i),
              .wb_dat_i(wb_if.wb_dat_i),
              .wb_we_i(wb_if.wb_we_i),
              .wb_stb_i(wb_if.wb_stb_i),
              .wb_cyc_i(wb_if.wb_cyc_i),
              .wb_dat_o(wb_if.wb_dat_o),
              .wb_int_o(wb_if.wb_int_o),
              .wb_ack_o(wb_if.wb_ack_o),
              .reset_xgmii_tx_n(reset_xgmii_tx_n),
              .xgmii_txc(xgmii_txc),
              .xgmii_txd(xgmii_txd),
              .reset_xgmii_rx_n(reset_xgmii_rx_n),
              .xgmii_rxc(xgmii_rxc),
              .xgmii_rxd(xgmii_rxd),
              .reset_156m25_n(!rst),
              .pkt_rx_ren(slv_if.pkt_rx_ren),
              .pkt_tx_data(mst_if.pkt_tx_data),
              .pkt_tx_eop(mst_if.pkt_tx_eop),
              .pkt_tx_mod(mst_if.pkt_tx_mod),
              .pkt_tx_sop(mst_if.pkt_tx_sop),
              .pkt_tx_val(mst_if.pkt_tx_val),
              .pkt_rx_eop(slv_if.pkt_rx_eop),
              .pkt_rx_err(slv_if.pkt_rx_err),
              .pkt_rx_mod(slv_if.pkt_rx_mod),
              .pkt_rx_sop(slv_if.pkt_rx_sop),
              .pkt_rx_val(slv_if.pkt_rx_val),
              .pkt_tx_full(mst_if.pkt_tx_full),
              .pkt_rx_avail(slv_if.pkt_rx_avail),
              .pkt_rx_data(slv_if.pkt_rx_data)
             );

        assign xgmii_rxc = xgmii_txc;
        assign xgmii_rxd = xgmii_txd;

initial begin
    // reset_156m25_n = 1'b0;
    reset_xgmii_rx_n = 1'b0;
    reset_xgmii_tx_n = 1'b0;
    #20ns;
    // reset_156m25_n = 1'b1;
    reset_xgmii_rx_n = 1'b1;
    reset_xgmii_tx_n = 1'b1;
end  
initial begin
    wb_if.wb_adr_i <= 8'b0;
    wb_if.wb_cyc_i <= 1'b0;
    wb_if.wb_dat_i <= 32'b0;
    //wb_if.wb_rst_i <= 1'b1;
    wb_if.wb_stb_i <= 1'b0;
    wb_if.wb_we_i <= 1'b0;
    //@(posedge wb_clk_i);
    // wb_if.wb_rst_i <= 1'b0;
end
   //Driver reset depending on rst_delay
   initial
      begin
         clk = 0;
         rst = 0;
      #1 rst = 1;
         repeat (rst_delay) @(clk);
         rst = 1'b0;
         @(clk);
   end

endmodule: environment_top

`endif // ENVIRONMENT_TOP__SV
