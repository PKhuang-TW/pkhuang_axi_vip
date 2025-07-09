`ifndef AXI_VIP_PKG_SVH
`define AXI_VIP_PKG_SVH

package axi_vip_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "axi_define.svh"
    `include "axi_typedef.svh"
    import axi_typedef::*;

    `include "axi_seq_item.sv"
    `include "axi_id_info_map.sv"
    `include "axi_mem_model.sv"

    `include "axi_monitor_base.sv"
    `include "axi_master_monitor.sv"
    `include "axi_slave_monitor.sv"

    // `include "axi_master_bfm.sv"
    `include "axi_slave_bfm.sv"

    `include "axi_driver_base.sv"
    `include "axi_master_driver.sv"
    `include "axi_slave_driver.sv"

    `include "axi_agent_base.sv"
    `include "axi_master_agent.sv"
    `include "axi_slave_agent.sv"

    `include "axi_scoreboard.sv"
    `include "axi_env.sv"

    `include "axi_aw_seq.sv"
    `include "axi_rand_rw_seq.sv"

    `include "axi_basic_test.sv"
    `include "axi_rand_rw_test.sv"

endpackage

`endif