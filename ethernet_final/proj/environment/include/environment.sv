//
// Template for UVM-compliant verification environment
//

`ifndef ENVIRONMENT__SV
`define ENVIRONMENT__SV




`include "mstr_slv_src.incl"

`include "environment_cfg.sv"


`include "eth_scoreboard.sv"

`include "environment_cov.sv"

`include "mon_2cov.sv"


// ToDo: Add additional required `include directives

`endif // ENVIRONMENT__SV
