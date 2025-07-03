`ifndef AXI_SLAVE_DRIVER_SV
`define AXI_SLAVE_DRIVER_SV

class axi_slave_driver extends axi_driver_base;
    `uvm_component_utils(axi_slave_driver)

    axi_slave_bfm       slv_bfm;

    function new (string name = "axi_slave_driver");
        super.new(name);
    endfunction

    function build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase ( uvm_phase phase );
        forever begin
            @ ( posedge vif.ACLK );
            if ( !vif.ARESETn ) begin
                reset_axi_signal();
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