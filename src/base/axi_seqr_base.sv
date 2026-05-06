`ifndef AXI_SEQR_BASE_SV
`define AXI_SEQR_BASE_SV

class axi_seqr_base extends uvm_sequencer #(axi_seq_item);
    `uvm_component_utils(axi_seqr_base)

    virtual axi_if      vif;

    function new ( string name = "axi_seqr_base", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        if ( !uvm_config_db #(virtual axi_if) :: get (this, "", "vif", vif) )
            `uvm_error("NOCFG", $sformatf("No vif is set for %s.vif", get_full_name()) )
    endfunction

endclass : axi_seqr_base

`endif