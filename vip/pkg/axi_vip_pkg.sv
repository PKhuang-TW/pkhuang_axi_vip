`ifndef AXI_VIP_PKG_SV
`define AXI_VIP_PKG_SV

package axi_vip_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "axi_define.svh"
    `include "axi_seq_item.sv"
    `include "axi_monitor_base.sv"
    `include "axi_master_monitor.sv"
    `include "axi_master_bfm.svh"
    `include "axi_master_bfm.sv"
    `include "axi_driver_base.sv"
    `include "axi_master_driver.sv"
    `include "axi_agent_base.sv"
    `include "axi_master_agent.sv"
    `include "axi_env.sv"
    `include "axi_basic_test.sv"

endpackage

`endif