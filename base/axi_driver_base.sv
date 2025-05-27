`ifndef AXI_DRIVER_BASE
`define AXI_DRIVER_BASE

class axi_driver_base #(
    type TXN = axi_transfer
) extends uvm_driver;
    `uvm_component_param_utils(axi_driver_base#(TXN))

    axi_config #(TXN)       cfg;
    virtual axi_interface   vif;

    function new (string name = "axi_driver_base");
        super.new(name);
    endfunction

    function build_phase (uvm_phase phase);
        super.build_phase(phase);

        if ( !uvm_config_db #(axi_config#(TXN)) :: get (this, "", "cfg", cfg) )
            `uvm_error("NOCFG", $sformatf("No master config is set for %s.cfg", get_full_name()) )
        vif = cfg.vif;

        reset_axi_signal();
    endfunction

    virtual task run_phase ( uvm_phase phase );
        forever begin
            seq_item_port.get_next_item(req);
            $cast(rsp, req.clone());
            drive_item(rsp);
            seq_item_port.item_done();

            // Put response to avoid if the req has some problem
            seq_item_port.put_response(rsp);
        end        
    endtask

    pure virtual task drive_item(TXN txn);

    pure virtual task reset_aw_signal();
    pure virtual task reset_w_signal();
    pure virtual task reset_b_signal();
    pure virtual task reset_ar_signal();
    pure virtual task reset_r_signal();

    extern virtual task reset_axi_signal();

endclass : axi_driver_base

virtual task axi_driver_base::reset_axi_signal();
    reset_aw_signal();
    reset_w_signal();
    reset_b_signal();
    reset_ar_signal();
    reset_r_signal();
endtask : reset_axi_signal

`endif