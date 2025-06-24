`ifndef AXI_PACKAGE_SV
`define AXI_PACKAGE_SV

package axi_package;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "axi_defines.svh"
    `include "axi_types.sv"

    `include "axi_config_base.sv"
    `include "axi_config_mst.sv"
    `include "axi_config_slv.sv"
    
    `include "axi_seq_item.sv"

endpackage

`endif