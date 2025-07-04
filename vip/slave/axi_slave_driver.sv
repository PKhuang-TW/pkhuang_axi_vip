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

        // if ( !uvm_config_db #(virtual axi_if.slv_if) :: get (this, "", "vif.slv_if", vif) )
        //     `uvm_error("NOCFG", $sformatf("No vif is set for %s.vif", get_full_name()) )

        slv_bfm = new( .vif(vif.slv_if) );
    endfunction

    virtual task run_phase ( uvm_phase phase );
        forever begin
            @ ( posedge vif.ACLK );
            if ( !vif.ARESETn ) begin
                slv_bfm.reset_axi_signal();
            end else begin
                fork
                    slv_bfm.aw_signal_handler();
                    slv_bfm.w_signal_handler();
                    slv_bfm.b_signal_handler();
                    slv_bfm.ar_signal_handler();
                    slv_bfm.r_signal_handler();
                join
            end
        end
    endtask

endclass : axi_slave_driver

`endif