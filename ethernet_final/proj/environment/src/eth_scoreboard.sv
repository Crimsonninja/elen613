//
// Template for UVM Scoreboard

`ifndef ETH_SCOREBOARD__SV
`define ETH_SCOREBOARD__SV


class eth_scoreboard extends uvm_scoreboard;

   uvm_analysis_export #(eth_data) before_export, after_export;
   uvm_in_order_class_comparator #(eth_data) comparator;

   `uvm_component_utils(eth_scoreboard)
	extern function new(string name = "eth_scoreboard",
                    uvm_component parent = null); 
	extern virtual function void build_phase (uvm_phase phase);
	extern virtual function void connect_phase (uvm_phase phase);
	extern virtual task main_phase(uvm_phase phase);
	extern virtual function void report_phase(uvm_phase phase);

endclass: eth_scoreboard


function eth_scoreboard::new(string name = "eth_scoreboard",
                 uvm_component parent);
   super.new(name,parent);
endfunction: new

function void eth_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    before_export = new("before_export", this);
    after_export  = new("after_export", this);
    comparator    = new("comparator", this);
endfunction:build_phase

function void eth_scoreboard::connect_phase(uvm_phase phase);
    before_export.connect(comparator.before_export);
    after_export.connect(comparator.after_export);
endfunction:connect_phase

task eth_scoreboard::main_phase(uvm_phase phase);
    super.main_phase(phase);
    phase.raise_objection(this,"scbd..");
	comparator.run();
    phase.drop_objection(this);
endtask: main_phase 

function void eth_scoreboard::report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SBRPT", $psprintf("Matches = %0d, Mismatches = %0d",
               comparator.m_matches, comparator.m_mismatches),
               UVM_MEDIUM);
endfunction:report_phase

`endif // ETH_SCOREBOARD__SV
