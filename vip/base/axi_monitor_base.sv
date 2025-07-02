`ifndef AXI_MONITOR_BASE
`define AXI_MONITOR_BASE

class axi_monitor_base extends uvm_monitor;
    `uvm_component_utils(axi_monitor_base)

    axi_seq_item                        txn;
    virtual axi_interface               vif;

    uvm_analysis_port #(axi_seq_item)   ap;

    function new (string name="axi_monitor_base");
        super.new();
        ap = new("ap", this);
    endfunction

    function build_phase (uvm_phase phase);
        super.build_phase(phase);

        if ( !uvm_config_db #(virtual axi_interface) :: get (this, "", "vif", vif) )
            `uvm_error("NOCFG", $sformatf("No vif is set for %s.vif", get_full_name()) )
    endfunction
    
endclass

`endif