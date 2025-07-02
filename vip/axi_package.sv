`ifndef AXI_PACKAGE_SV
`define AXI_PACKAGE_SV

package axi_package;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "axi_define.svh"
    `include "axi_seq_item.sv"
    `include "axi_monitor_base.sv"
    `include "axi_master_monitor.sv"
    `include "axi_driver_base.sv"
    `include "axi_master_driver.sv"
    `include "axi_agent_base.sv"
    `include "axi_master_agent.sv"
    `include "axi_env.sv"
    `include "axi_basic_test.sv"

endpackage

`endif