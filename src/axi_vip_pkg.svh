`ifndef AXI_VIP_PKG_SVH
`define AXI_VIP_PKG_SVH

package axi_vip_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "axi_define.svh"
    `include "axi_typedef.svh"
    import axi_typedef::*;
    
    `include "axi_utils.svh"

    `include "axi_seq_item.sv"
    `include "axi_id_info_map.sv"
    `include "axi_mem_model.sv"

    `include "axi_monitor_base.sv"
    `include "axi_master_monitor.sv"
    `include "axi_slave_monitor.sv"

    `include "axi_driver_base.sv"
    `include "axi_master_driver.sv"
    `include "axi_slave_driver.sv"

    `include "axi_master_sequencer.sv"
    `include "axi_slave_sequencer.sv"
    `include "axi_virtual_sequencer.sv"

    `include "axi_agent_base.sv"
    `include "axi_master_agent.sv"
    `include "axi_slave_agent.sv"

    `include "axi_scoreboard.sv"
    `include "axi_env.sv"

    `include "axi_aw_seq.sv"
    `include "axi_w_seq.sv"
    `include "axi_b_seq.sv"
    `include "axi_slv_wr_seq.sv"

    `include "axi_vseq_base.sv"
    `include "axi_mst_inorder_wr_vseq.sv"

    `include "axi_test_base.sv"
    `include "test_axi_inorder_write_random.sv"

endpackage

`endif