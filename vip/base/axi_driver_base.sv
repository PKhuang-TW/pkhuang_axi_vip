`ifndef AXI_DRIVER_BASE_SV
`define AXI_DRIVER_BASE_SV

class axi_driver_base extends uvm_driver #(axi_seq_item);
    `uvm_component_utils(axi_driver_base)

    function new ( string name = "axi_driver_base", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

endclass : axi_driver_base

`endif