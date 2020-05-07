//
// Template for UVM-compliant transaction descriptor


`ifndef ETH_DATA__SV
`define ETH_DATA__SV


class eth_data extends uvm_sequence_item;

   typedef enum {READ, WRITE } kinds_e;
   rand kinds_e kind;
   typedef enum {IS_OK, ERROR} status_e;
   rand status_e status;
   rand byte sa;
  
   rand logic [63:0] pkt_data[];

   // ToDo: Add constraint blocks to prevent error injection
   // ToDo: Add relevant class properties to define all transactions
   // ToDo: Modify/add symbolic transaction identifiers to match

   constraint eth_data_valid {
      // ToDo: Define constraint to make descriptor valid
      status == IS_OK;
   }
   constraint pkt_length_appropriate { pkt_data.size inside {[0:1152]}; }
   
   `uvm_object_utils_begin(eth_data) 

      // ToDo: add properties using macros here
   
      `uvm_field_enum(kinds_e,kind,UVM_ALL_ON)
      `uvm_field_enum(status_e,status, UVM_ALL_ON)
   `uvm_object_utils_end
 
   extern function new(string name = "Trans");
endclass: eth_data


function eth_data::new(string name = "Trans");
   super.new(name);
endfunction: new

class eth_data_oversized extends eth_data;

  `uvm_object_utils(eth_data_oversized)
  //pkt_length_appropriate.constraint_mode(0);
  constraint pkt_length_appropriate
    {
      pkt_data.size() inside {[1501:9000]};
    }

  function new(input string name="eth_data_oversized");
    super.new(name);
  endfunction : new
endclass:eth_data_oversized
`endif // ETH_DATA__SV
