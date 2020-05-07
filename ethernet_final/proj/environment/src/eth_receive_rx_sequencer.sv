//
// Template for UVM-compliant sequencer class
//


`ifndef RX_SEQUENCER__SV
`define RX_SEQUENCER__SV


typedef class eth_data;
class rx_sequencer extends uvm_sequencer # (eth_data);

   `uvm_component_utils(rx_sequencer)
   function new (string name,
                 uvm_component parent);
   super.new(name,parent);
   endfunction:new 
endclass:rx_sequencer

`endif // RX_SEQUENCER__SV
