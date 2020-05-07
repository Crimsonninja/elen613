//
// Template for UVM-compliant Program block

`ifndef ENVIRONMENT_TB_MOD__SV
`define ENVIRONMENT_TB_MOD__SV

`include "mstr_slv_intfs.incl"
module environment_tb_mod;

import uvm_pkg::*;

`include "environment_env.sv"
`include "environment_test.sv"  //ToDo: Change this name to the testcase file-name
`include "test00.sv"

// ToDo: Include all other test list here
   typedef virtual tx_intf v_if1;
   typedef virtual rx_intf v_if2;
   initial begin
      uvm_config_db #(v_if1)::set(null,"","mst_if",environment_top.mst_if); 
      uvm_config_db #(v_if1)::set(null,"","mon_if",environment_top.mst_if); 
      uvm_config_db #(v_if2)::set(null,"","slv_if",environment_top.slv_if);
      uvm_config_db #(v_if2)::set(null,"","mon_if",environment_top.slv_if); 
      run_test();
   end

endmodule: environment_tb_mod

`endif // ENVIRONMENT_TB_MOD__SV

