// Template for UVM-compliant interface
//

`ifndef WB_INTF__SV
`define WB_INTF__SV

interface wb_intf(input bit wb_clk_i, input bit wb_rst_i);
  // ToDo: Define default setup & hold times

  parameter setup_time = 5/*ns*/;
  parameter hold_time  = 3/*ns*/;

  // ToDo: Define synchronous and asynchronous signals as wires

  logic       async_en;
  logic       async_rdy;

  logic [7:0] wb_adr_i;
  logic [31:0] wb_dat_i, wb_dat_o;
  logic wb_we_i;
  logic wb_stb_i;
  logic wb_cyc_i, wb_ack_o;
  logic wb_int_o;

  
  // ToDo: Define one clocking block per clock domain
  //       with synchronous signal direction from a
  //       master perspective

  clocking mck @(posedge wb_clk_i);
    default input #setup_time output #hold_time;
output wb_adr_i, wb_dat_i, wb_we_i, wb_stb_i, wb_cyc_i;
input  wb_dat_o, wb_ack_o, wb_int_o;
    // ToDo: List the synchronous signals here

  endclocking: mck
 
  clocking sck @(posedge wb_clk_i);
    default input #setup_time output #hold_time;

    // ToDo: List the synchronous signals here
  endclocking: sck

  clocking pck @(posedge wb_clk_i);
    default input #setup_time output #hold_time;
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
endinterface: wb_intf

`endif // WB_INTF__SV
