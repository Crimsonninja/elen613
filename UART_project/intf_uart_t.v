`timescale 1ns/1ps
interface intf_uart_t(input wb_clk_i); 

        // Wishbone signals
        logic wb_rst_i; 
        logic [4:0] wb_adr_i; 
        logic [31:0] wb_dat_i, wb_dat_o; 
        logic wb_we_i; 
        logic  wb_stb_i; 
        logic wb_cyc_i, wb_ack_o; 
        logic [3:0] wb_sel_i;
        logic int_o; // interrupt request

        // UART signals
        // serial input/output
        logic stx_pad_o, srx_pad_i;

        // modem signals
        logic rts_pad_o, cts_pad_i, dtr_pad_o, dsr_pad_i, ri_pad_i, dcd_pad_i;

clocking wb @(posedge wb_clk_i);
  output wb_rst_i, wb_adr_i, wb_dat_i,wb_we_i,wb_stb_i,wb_cyc_i,wb_sel_i;
  input wb_dat_o,wb_ack_o,int_o,stx_pad_o; 
endclocking

endinterface

