`ifndef AXI_DRIVER_BASE_SV
`define AXI_DRIVER_BASE_SV

class axi_driver_base extends uvm_driver #(axi_seq_item);
    `uvm_component_utils(axi_driver_base)

    axi_seq_item            txn, rsp;
    // virtual axi_if          vif;

    function new ( string name = "axi_driver_base", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        // if ( !uvm_config_db #(virtual axi_if) :: get (this, "", "vif", vif) )
        //     `uvm_error("NOCFG", $sformatf("No vif is set for %s.vif", get_full_name()) )
    endfunction

endclass : axi_driver_base

`endif