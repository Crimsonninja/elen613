//
// Template for UVM-compliant physical-level monitor
//

`ifndef RX_MONITOR__SV
`define RX_MONITOR__SV


typedef class eth_data;
typedef class rx_monitor;

class rx_monitor_callbacks extends uvm_callback;

   // ToDo: Add additional relevant callbacks
   // ToDo: Use a task if callbacks can be blocking


   // Called at start of observed transaction
   virtual function void pre_trans(rx_monitor xactor,
                                   eth_data tr);
   endfunction: pre_trans


   // Called before acknowledging a transaction
   virtual function pre_ack(rx_monitor xactor,
                            eth_data tr);
   endfunction: pre_ack
   

   // Called at end of observed transaction
   virtual function void post_trans(rx_monitor xactor,
                                    eth_data tr);
   endfunction: post_trans

   
   // Callback method post_cb_trans can be used for coverage
   virtual task post_cb_trans(rx_monitor xactor,
                              eth_data tr);
   endtask: post_cb_trans

endclass: rx_monitor_callbacks

   

class rx_monitor extends uvm_monitor;

   uvm_analysis_port #(eth_data) mon_analysis_port;  //TLM analysis port
   typedef virtual rx_intf v_if;
   v_if mon_if;
   // ToDo: Add another class property if required
   extern function new(string name = "rx_monitor",uvm_component parent);
   `uvm_register_cb(rx_monitor,rx_monitor_callbacks);
   `uvm_component_utils_begin(rx_monitor)
      // ToDo: Add uvm monitor member if any class property added later through field macros

   `uvm_component_utils_end
      // ToDo: Add required short hand override method

   extern task rcv_data(ref eth_data tr);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void end_of_elaboration_phase(uvm_phase phase);
   extern virtual function void start_of_simulation_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);
   extern virtual task reset_phase(uvm_phase phase);
   extern virtual task configure_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern protected virtual task tx_monitor1();

endclass: rx_monitor


function rx_monitor::new(string name = "rx_monitor",uvm_component parent);
   super.new(name, parent);
   mon_analysis_port = new ("mon_analysis_port",this);
endfunction: new

function void rx_monitor::build_phase(uvm_phase phase);
   super.build_phase(phase);
   //ToDo : Implement this phase here

endfunction: build_phase

function void rx_monitor::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   uvm_config_db#(v_if)::get(this, "", "mon_if", mon_if);
endfunction: connect_phase

function void rx_monitor::end_of_elaboration_phase(uvm_phase phase);
   super.end_of_elaboration_phase(phase); 
   //ToDo: Implement this phase here

endfunction: end_of_elaboration_phase


function void rx_monitor::start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
   //ToDo: Implement this phase here

endfunction: start_of_simulation_phase


task rx_monitor::reset_phase(uvm_phase phase);
   super.reset_phase(phase);
   // ToDo: Implement reset here

endtask: reset_phase


task rx_monitor::configure_phase(uvm_phase phase);
   super.configure_phase(phase);
   //ToDo: Configure your component here
endtask:configure_phase


task rx_monitor::run_phase(uvm_phase phase);
   super.run_phase(phase);
  // phase.raise_objection(this,""); //Raise/drop objections in sequence file
   fork
      tx_monitor1();
   join
  // phase.drop_objection(this);

endtask: run_phase

task automatic rx_monitor::rcv_data(ref eth_data tr);
  logic done;
  integer i;
  tr = new();
  tr.pkt_data = new[1152];
  done = 0;
  i = 0;
  while (!mon_if.pck.pkt_rx_avail) @(mon_if.pck);
  mon_if.pck.pkt_rx_ren <= 1'b1;
  @(mon_if.pck);
  while ((!done)) begin
     if (mon_if.pck.pkt_rx_val) begin
      if (mon_if.pck.pkt_rx_sop) begin
        /*
        $display("\n\n------------------------");
        $display("Received Packet");
        $display("------------------------");
        */
        `uvm_info("environment_MONITOR", "Received Packet",UVM_LOW)
      end
      // $display("%x", mon_if.pck.pkt_rx_data);
      
      // reconstructing tr (the eth_data object)
      tr.pkt_data[i] = mon_if.pck.pkt_rx_data;
      i = i + 1;
      if (mon_if.pck.pkt_rx_eop) begin
        done = 1;
        mon_if.pck.pkt_rx_ren <= 1'b0;
      end
      if (mon_if.pck.pkt_rx_eop) begin
        $display("------------------------\n\n");
      end
    end
      @(mon_if.pck);
  end
  //rx_count = (rx_count + 1);

endtask: rcv_data

task rx_monitor::tx_monitor1();
   forever begin
      eth_data tr;
      // ToDo: Wait for start of transaction

      `uvm_do_callbacks(rx_monitor,rx_monitor_callbacks,
                    pre_trans(this, tr))
      `uvm_info(" Rx Monitor environment_MONITOR", "Starting transaction...",UVM_LOW)
      // ToDo: Observe first half of transaction

      // ToDo: User need to add monitoring logic and remove $finish
      // `uvm_info("environment_MONITOR"," User need to add monitoring logic ",UVM_LOW)
	    // $finish;
      rcv_data(tr);
      `uvm_do_callbacks(rx_monitor,rx_monitor_callbacks,
                    pre_ack(this, tr))
      // ToDo: React to observed transaction with ACK/NAK
      `uvm_info("environment_MONITOR", "Completed transaction...",UVM_LOW)
      `uvm_info("environment_MONITOR", tr.sprint(),UVM_LOW)
      `uvm_do_callbacks(rx_monitor,rx_monitor_callbacks,
                    post_trans(this, tr))
      mon_analysis_port.write(tr);
   end
endtask: tx_monitor1

`endif // RX_MONITOR__SV
