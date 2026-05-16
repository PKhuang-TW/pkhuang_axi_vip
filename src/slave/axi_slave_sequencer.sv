`ifndef AXI_SLAVE_SEQUENCER_SV
`define AXI_SLAVE_SEQUENCER_SV

class axi_slave_sequencer extends axi_seqr_base;
    `uvm_component_utils(axi_slave_sequencer)

    axi_mem_model           mem;
    axi_seq_item            aw_pending_q[bit[`D_ID_WIDTH-1:0]][$];
    axi_seq_item            w_pending_q[bit[`D_ID_WIDTH-1:0]][$];

    `uvm_analysis_imp_decl(_aw)
    `uvm_analysis_imp_decl(_w)

    uvm_analysis_imp_aw #( axi_seq_item, axi_slave_sequencer )      aw_export;
    uvm_analysis_imp_w #( axi_seq_item, axi_slave_sequencer )       w_export;

    function new ( string name = "axi_slave_sequencer", uvm_component parent );
        super.new(name, parent);
        aw_export = new("aw_export", this);
        w_export = new("w_export", this);
    endfunction

    function void build_phase ( uvm_phase phase );
        super.build_phase(phase);

        if ( !uvm_config_db #(axi_mem_model) :: get ( this, "", "mem", mem ) )
            `uvm_error("NOCFG", $sformatf("No mem is set for %s", get_full_name()) )
    endfunction

    virtual function void write_aw ( axi_seq_item aw_txn );
        aw_pending_q[aw_txn.aw_id].push_back(aw_txn);
    endfunction

    virtual function void write_w ( axi_seq_item w_txn );
        w_pending_q[w_txn.w_id].push_back(w_txn);
    endfunction
    
endclass

`endif