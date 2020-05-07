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
   
   // rand integer pkt_length;
   rand logic [63:0] pkt_data[];
   // rand boolean fragment_error;
   
   // ToDo: Add constraint blocks to prevent error injection
   // ToDo: Add relevant class properties to define all transactions
   // ToDo: Modify/add symbolic transaction identifiers to match

   constraint eth_data_valid {
      // ToDo: Define constraint to make descriptor valid
      status == IS_OK;
   }

   constraint pkt_length_appropriate { pkt_data.size inside {[0:1152]}; }
   /*constraint pkt_data_printable {
     foreach(pkt_data[k])
       (k < pkt_data.size-1) ->
       (pkt_data[k] > 33) && pkt_data[k] < 126);
   }*/

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


`endif // ETH_DATA__SV
