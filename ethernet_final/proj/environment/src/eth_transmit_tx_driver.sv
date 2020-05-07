//
// Template for UVM-compliant physical-level transactor
//

`ifndef TX_DRIVER__SV
`define TX_DRIVER__SV

typedef class eth_data;
typedef class tx_driver;

class tx_driver_callbacks extends uvm_callback;

   // ToDo: Add additional relevant callbacks
   // ToDo: Use "task" if callbacks cannot be blocking

   // Called before a transaction is executed
   virtual task pre_tx( tx_driver xactor,
                        eth_data tr);
                                   
     // ToDo: Add relevant code

   endtask: pre_tx


   // Called after a transaction has been executed
   virtual task post_tx( tx_driver xactor,
                         eth_data tr);
     // ToDo: Add relevant code

   endtask: post_tx

endclass: tx_driver_callbacks


class tx_driver extends uvm_driver # (eth_data);

   typedef virtual tx_intf v_if; 
   v_if drv_if;
   `uvm_register_cb(tx_driver,tx_driver_callbacks); 
   
   extern function new(string name = "tx_driver",
                       uvm_component parent = null); 
 
      `uvm_component_utils_begin(tx_driver)
      // ToDo: Add uvm driver member
      `uvm_component_utils_end
   // ToDo: Add required short hand override method

   extern task send_data(eth_data tr);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void end_of_elaboration_phase(uvm_phase phase);
   extern virtual function void start_of_simulation_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern protected virtual task send(eth_data tr); 
   extern protected virtual task tx_driver1();

endclass: tx_driver


function tx_driver::new(string name = "tx_driver",
                   uvm_component parent = null);
   super.new(name, parent);

   
endfunction: new


function void tx_driver::build_phase(uvm_phase phase);
   super.build_phase(phase);
   //ToDo : Implement this phase here

endfunction: build_phase

function void tx_driver::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   uvm_config_db#(v_if)::get(this, "", "mst_if", drv_if);
endfunction: connect_phase

function void tx_driver::end_of_elaboration_phase(uvm_phase phase);
   super.end_of_elaboration_phase(phase);
   if (drv_if == null)
       `uvm_fatal("NO_CONN", "Virtual port not connected to the actual interface instance");   
endfunction: end_of_elaboration_phase

function void tx_driver::start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
   //ToDo: Implement this phase here
endfunction: start_of_simulation_phase

// DO STUFF HERE
task tx_driver::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
   drv_if.mck.pkt_tx_data <= 64'b0;
   drv_if.mck.pkt_tx_val <= 1'b0;
   drv_if.mck.pkt_tx_sop <= 1'b0;
   drv_if.mck.pkt_tx_eop <= 1'b0;
   drv_if.mck.pkt_tx_mod <= 3'b0;
   // ToDo: Reset output signals
endtask: reset_phase

task tx_driver::configure_phase(uvm_phase phase);
   super.configure_phase(phase);
   //ToDo: Configure your component here
endtask:configure_phase


task tx_driver::run_phase(uvm_phase phase);
   super.run_phase(phase);
   // phase.raise_objection(this,""); //Raise/drop objections in sequence file
   fork 
      tx_driver1();
   join
   // phase.drop_objection(this);
endtask: run_phase

task tx_driver::send_data(eth_data tr); 
  $display("Transmit packet with length: %d", tr.pkt_data.size);
  @(drv_if.mck) ;
  #1ns;
  drv_if.mck.pkt_tx_val <= 1'b1;
  for (int i = 0; i < tr.pkt_data.size; i = (i+8)) begin
    drv_if.mck.pkt_tx_sop <= 1'b0;
    drv_if.mck.pkt_tx_eop <= 1'b0;
    drv_if.mck.pkt_tx_mod <= 2'b0;
    if (i == 0) begin
      drv_if.mck.pkt_tx_sop <= 1'b1;
    end
    if ((i + 8) >= tr.pkt_data.size) begin
      drv_if.mck.pkt_tx_eop <= 1'b1;
      drv_if.mck.pkt_tx_mod <= (tr.pkt_data.size % 8);
    end
    drv_if.mck.pkt_tx_data[63:56] <= tr.pkt_data[i];
    drv_if.mck.pkt_tx_data[55:48] <= tr.pkt_data[(i + 1)];
    drv_if.mck.pkt_tx_data[47:40] <= tr.pkt_data[(i + 2)];
    drv_if.mck.pkt_tx_data[39:32] <= tr.pkt_data[(i + 3)];
    drv_if.mck.pkt_tx_data[31:24] <= tr.pkt_data[(i + 4)];
    drv_if.mck.pkt_tx_data[23:16] <= tr.pkt_data[(i + 5)];
    drv_if.mck.pkt_tx_data[15:8] <= tr.pkt_data[(i + 6)];
    drv_if.mck.pkt_tx_data[7:0] <= tr.pkt_data[(i + 7)];
    @(drv_if.mck) ;
    #1ns;
  end
  drv_if.mck.pkt_tx_val <= 1'b0;
  drv_if.mck.pkt_tx_eop <= 1'b0;
  drv_if.mck.pkt_tx_mod <= 3'b0;
  // tx_count = (tx_count + 1);
endtask:send_data


task tx_driver::tx_driver1();
 forever begin
      eth_data tr;
      // ToDo: Set output signals to their idle state
      this.drv_if.master.async_en      <= 0;
      `uvm_info("environment_DRIVER", "Starting transaction...",UVM_LOW)
      seq_item_port.get_next_item(tr);
	  `uvm_do_callbacks(tx_driver,tx_driver_callbacks,
                    pre_tx(this, tr))
      send(tr); 
      seq_item_port.item_done();
      `uvm_info("environment_DRIVER", "Completed transaction...",UVM_LOW)
      `uvm_info("environment_DRIVER", tr.sprint(),UVM_HIGH)
      `uvm_do_callbacks(tx_driver,tx_driver_callbacks,
                    post_tx(this, tr))

   end
endtask : tx_driver1

task tx_driver::send(eth_data tr);
   // ToDo: Drive signal on interface
  send_data(tr);
endtask: send


`endif // TX_DRIVER__SV


