//
// Template for UVM-compliant sequencer class
//


`ifndef TX_SEQUENCER__SV
`define TX_SEQUENCER__SV


typedef class eth_data;
class tx_sequencer extends uvm_sequencer # (eth_data);

   `uvm_component_utils(tx_sequencer)
   function new (string name,
                 uvm_component parent);
   super.new(name,parent);
   endfunction:new 
endclass:tx_sequencer

`endif // TX_SEQUENCER__SV
