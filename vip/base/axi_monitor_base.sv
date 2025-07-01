`ifndef AXI_MONITOR_BASE
`define AXI_MONITOR_BASE

class axi_monitor_base extends uvm_monitor;
    `uvm_component_utils(axi_monitor_base)

    axi_seq_item                        txn;

    axi_config                          cfg;
    virtual axi_interface               vif;

    uvm_analysis_port #(axi_seq_item)   ap;

    function new (string name="axi_monitor_base");
        super.new();
        ap = new("ap", this);
    endfunction

    function build_phase (uvm_phase phase);
        super.build_phase(phase);

        if ( !uvm_config_db #(axi_config) :: get (this, "", "cfg", cfg) )
            `uvm_error("NOCFG", $sformatf("No config is set for %s.cfg", get_full_name()))
        vif = cfg.vif;
    endfunction
    
endclass

`endif