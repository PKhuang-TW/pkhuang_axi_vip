`ifndef AXI_CONFIG_SV
`define AXI_CONFIG_SV

`include "axi_define.svh"

class axi_config extends uvm_object;
    `uvm_object_param_utils(axi_config)

    role_e          role;
    axi_interface   vif;

    function new (string name = "axi_config");
        super.new(name);
    endfunction

endclass : axi_config

`endif