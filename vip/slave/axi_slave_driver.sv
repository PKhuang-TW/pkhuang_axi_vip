`ifndef AXI_SLAVE_DRIVER_SV
`define AXI_SLAVE_DRIVER_SV

class axi_slave_driver extends axi_driver_base;
    `uvm_component_utils(axi_slave_driver)

    axi_slave_bfm       slv_bfm;

    function new ( string name = "axi_slave_driver", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        slv_bfm = new( .vif(vif.slv_if) );
    endfunction

    virtual task run_phase ( uvm_phase phase );
        fork
            slv_bfm.reset_signal_handler();
            
            slv_bfm.aw_signal_handler();
            slv_bfm.w_signal_handler();
            slv_bfm.b_signal_handler();
            slv_bfm.ar_signal_handler();
            slv_bfm.r_signal_handler();
        join_none
    endtask

endclass : axi_slave_driver

`endif
