`ifndef AXI_SLAVE_DRIVER_SV
`define AXI_SLAVE_DRIVER_SV

class axi_slave_driver extends axi_driver_base;
    `uvm_component_utils(axi_slave_driver)

    virtual axi_if.slv_if       vif;

    function new ( string name = "axi_slave_driver", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        if ( !uvm_config_db #(virtual axi_if.slv_if) :: get (this, "", "vif.slv_if", vif) )
            `uvm_error("NOCFG", $sformatf("No vif is set for %s.vif", get_full_name()) )

    endfunction

    virtual task run_phase ( uvm_phase phase );
        fork
    endtask

endclass : axi_slave_driver

`endif