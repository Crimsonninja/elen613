//
// Template for UVM-compliant testcase

`ifndef TEST__SV
`define TEST__SV

typedef class environment_env;

class environment_test extends uvm_test;

  `uvm_component_utils(environment_test)

  environment_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = environment_env::type_id::create("env", this);
    uvm_config_db #(uvm_object_wrapper)::set(this, "env.master_agent.mast_sqr.main_phase",
                    "default_sequence", tx_sequencer_sequence_library::get_type()); 
  endfunction

  virtual task main_phase(uvm_phase phase);
    uvm_objection objection;
    super.main_phase(phase);
    objection = phase.get_objection();
    objection.set_drain_time(this,1us);
  endtask

endclass : environment_test

`endif //TEST__SV

