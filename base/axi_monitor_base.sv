`ifndef AXI_MONITOR_BASE
`define AXI_MONITOR_BASE

class axi_monitor_base #(
    type TXN = axi_transfer
) extends uvm_monitor;
    `uvm_component_param_utils(axi_monitor_base#(TXN))

    virtual axi_interface       vif;
    axi_config #(TXN)           cfg;

    uvm_analysis_port #(TXN)    ap_axi_write, ap_axi_read;

    function new (string name="axi_monitor_base");
        super.new();
        ap_axi_write    = new("ap_axi_write", this);
        ap_axi_read     = new("ap_axi_read", this);
    endfunction

    function build_phase (uvm_phase phase);
        super.build_phase(phase);

        if ( !uvm_config_db #(axi_config #(TXN)) :: get (this, "", "cfg", cfg) )
            `uvm_error("NOCFG", "No master config is set for: ", get_full_name(), ".cfg")

        vif = cfg.vif;
    endfunction

    pure virtual task monitor_aw_channel();
    pure virtual task monitor_w_channel();
    pure virtual task monitor_b_channel();
    pure virtual task monitor_ar_channel();
    pure virtual task monitor_r_channel();
    
endclass

`endif