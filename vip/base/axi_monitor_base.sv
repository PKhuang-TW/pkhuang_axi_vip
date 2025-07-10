`ifndef AXI_MONITOR_BASE_SV
`define AXI_MONITOR_BASE_SV

class axi_monitor_base extends uvm_monitor;
    `uvm_component_utils(axi_monitor_base)

    axi_seq_item                        txn;
    virtual axi_if.mon_if               vif;

    uvm_analysis_port #(axi_seq_item)   ap;

    function new ( string name="axi_monitor_base", uvm_component parent );
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        if ( !uvm_config_db #(virtual axi_if.mon_if) :: get (this, "", "vif.mon_if", vif) )
            `uvm_error("NOCFG", $sformatf("No vif is set for %s.vif", get_full_name()) )
    endfunction
    
    task wait_clk ( int cycle );
        #1;  // simulate delay to trigger mon_cb
        @ ( vif.mon_cb );
    endtask
    
endclass

`endif