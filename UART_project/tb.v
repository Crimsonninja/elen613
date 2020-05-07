//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_test.v                                                 ////
////                                                              ////
////                                                              ////
////  This file is part of the "UART 16550 compatible" project    ////
////  http://www.opencores.org/cores/uart16550/                   ////
////                                                              ////
////  Documentation related to this project:                      ////
////  - http://www.opencores.org/cores/uart16550/                 ////
////                                                              ////
////  Projects compatibility:                                     ////
////  - WISHBONE                                                  ////
////  RS232 Protocol                                              ////
////  16550D uart (mostly supported)                              ////
////                                                              ////
////  Overview (main Features):                                   ////
////  UART core test bench                                        ////
////                                                              ////
////  Known problems (limits):                                    ////
////  A very simple test bench. Creates two UARTS and sends       ////
////  data on to the other.                                       ////
////                                                              ////
////  To Do:                                                      ////
////  More complete testing should be done!!!                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - gorban@opencores.org                                  ////
////      - Jacob Gorban                                          ////
////                                                              ////
////  Created:        2001/05/12                                  ////
////  Last Updated:   2001/05/17                                  ////
////                  (See log for the revision history)          ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Jacob Gorban, gorban@opencores.org        ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  //// //// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: uart_test.v,v $
// Revision 1.3  2001/05/31 20:08:01  gorban // FIFO changes and other corrections.
//
// Revision 1.2  2001/05/17 18:34:18  gorban // First 'stable' release. Should be sythesizable now. Also added new header.
//
// Revision 1.0  2001-05-17 21:27:12+02  jacob // Initial revision // // //`define DATA_BUS_WIDTH_8 `include "timescale.v"
`timescale 1ns/1ps
module uart_test ();

`include "uart_defines.v"

bit       clk;
always #5 clk = !clk; 

intf_uart_t intf_uart(clk); 


uart_top  uart_snd(.wb_clk_i(intf_uart.wb_clk_i), .wb_rst_i(intf_uart.wb_rst_i), .wb_adr_i(intf_uart.wb_adr_i), .wb_dat_i(intf_uart.wb_dat_i), .wb_dat_o(intf_uart.wb_dat_o), .wb_we_i(intf_uart.wb_we_i), .wb_stb_i(intf_uart.wb_stb_i), .wb_cyc_i(intf_uart.wb_cyc_i), .wb_ack_o(intf_uart.wb_ack_o), .wb_sel_i(intf_uart.wb_sel_i), .int_o(intf_uart.int_o), .stx_pad_o(intf_uart.stx_pad_o), .srx_pad_i(intf_uart.srx_pad_i), .rts_pad_o(intf_uart.rts_pad_o), .cts_pad_i(intf_uart.cts_pad_i), .dtr_pad_o(intf_uart.dtr_pad_o), .dsr_pad_i(intf_uart.dsr_pad_i), .ri_pad_i(intf_uart.ri_pad_i), .dcd_pad_i(intf_uart.dcd_pad_i));   // TODO

logic [40*8-1:0] line;
logic flush_line=1;
logic [7:0] tx_byte;
int new_char,new_line;
integer bd_mult; 

class UART_DATA_t;
  rand logic [15:0]  bd_mult;
  rand byte chars[];
  // CONSTRAINTS
  constraint char_size_constraint { chars.size inside {[0:400]}; }
  constraint char_data_printable {
    foreach(chars[k])
      (k < chars.size - 1) -> 
      (chars[k] > 33) && (chars[k] < 126);
  }
  constraint bd_rate_constraint { bd_mult inside {[0:1000]}; }
endclass
UART_DATA_t uart_data;
initial begin 
    uart_data = new(); 
    reset(); 
    repeat (50000) begin 
       uart_data.randomize(); 
       $display("Number of characters is %d",uart_data.chars.size()); 
       $display("%p",uart_data); 
       bd_mult = uart_data.bd_mult;  
       wb_wr1(`UART_REG_FC,1,'h7);    // Fifo Control Settings
       wb_wr1(`UART_REG_LC,1,'h83);   // Set up baud rate 
       wb_wr1(`UART_REG_DL2,4,{4{bd_mult[15:8]}}); 
       wb_wr1(`UART_REG_DL1,8,{4{bd_mult[7:0]}}); 
       wb_wr1(`UART_REG_LC,1,'h3);   // End Set up baud rate
       for(int i = 0; i < uart_data.chars.size; i++) begin 
         wb_wr1(`UART_REG_TR,8,{uart_data.chars[i],24'h000000}); 
       end

       // Wait for uart transmit fifo to empty 
       wait (uart_test.uart_snd.regs.transmitter.fifo_tx.count == 0); 
       repeat(10*16*bd_mult) @(intf_uart.wb);
    end

     $finish;
end

always @ (posedge clk)
        uart_decoder;
////////////////////////////////////////////////////////////////////
//
// Reset Task
//
////////////////////////////////////////////////////////////////////
task reset;
  intf_uart.wb.wb_stb_i <= 0;
  intf_uart.wb.wb_sel_i <= 0;
  intf_uart.wb.wb_we_i <= 0;
  intf_uart.wb.wb_cyc_i <= 0; 

  @(intf_uart.wb);
  intf_uart.wb.wb_rst_i <= 1;
  @(intf_uart.wb);
  intf_uart.wb.wb_rst_i <= 0;
  @(intf_uart.wb);

endtask
////////////////////////////////////////////////////////////////////
//
// Write 1 Word Task
//
////////////////////////////////////////////////////////////////////

task wb_wr1;
input   [4:0]  addr;
input   [3:0]   sel;
input   [31:0]  data;

begin
@(intf_uart.wb)
intf_uart.wb.wb_adr_i <= addr;
intf_uart.wb.wb_dat_i <= data;
intf_uart.wb.wb_cyc_i <= 1;
intf_uart.wb.wb_stb_i <= 1;
intf_uart.wb.wb_we_i <= 1;
intf_uart.wb.wb_sel_i <= sel;

@(intf_uart.wb );
while(~intf_uart.wb.wb_ack_o )      @(intf_uart.wb);
intf_uart.wb.wb_cyc_i <= 0;
intf_uart.wb.wb_stb_i <=0;
intf_uart.wb.wb_adr_i <= 32'hxxxx_xxxx;
intf_uart.wb.wb_dat_i <= 32'hxxxx_xxxx;
intf_uart.wb.wb_we_i <= 0;
intf_uart.wb.wb_sel_i <= 4'h0;

end
endtask
////////////////////////////////////////////////////////////////////
//
// UART decoder Task
//
////////////////////////////////////////////////////////////////////
task uart_decoder;
	integer i;
	begin
        #20;
        new_char = 1'b0;
        new_line = 1'b0;
        // Wait for start bit
        while (intf_uart.wb.stx_pad_o == 1'b1) @(intf_uart.wb);
        repeat(16*bd_mult) @(intf_uart.wb); 
        for ( i = 0; i < 8 ; i = i + 1 ) begin
            tx_byte[i] = intf_uart.wb.stx_pad_o;
            repeat(16*bd_mult) @(intf_uart.wb); 
        end
        //Check for stop bit
        if (intf_uart.wb.stx_pad_o == 1'b0) begin
            $display("* WARNING: user stop bit not received when expected at time ",, $time);
            // Wait for return to idle
            while (intf_uart.wb.stx_pad_o == 1'b0) @(intf_uart.wb);
            $display("* USER UART returned to idle at time  ",,$time);
        end
        // display the char
        if ( 1'b1 )
            $write("%c",tx_byte); 
        if ( flush_line ) begin
            line = "";
            flush_line = 1'b1;
        end
        if ( tx_byte == "\n" ) begin
            new_line = 1'b1;
            flush_line = 1'b1;
        end
        else begin
            line = { line[39*8-1:0], tx_byte};
            new_char = 1'b1;
        end
    end
endtask

/*
////////////////////////////////////////////////////////////////////
//
// Read 1 Word Task
//

task wb_rd1;
input   [31:0]  a;
input   [3:0]   s;
output  [31:0]  d;

begin

@(posedge clk);
#1;
adr = a;
cyc = 1;
stb = 1;
we  = 0;
sel = s;

while(~ack & ~err)      @(posedge clk);
d = din;
#1;
cyc=0;
stb=0;
adr = 32'hxxxx_xxxx;
dout = 32'hxxxx_xxxx;
we = 1'hx;
sel = 4'hx;

end
endtask
*/
endmodule

