`ifndef AXI_SLAVE_SEQUENCER_SV
`define AXI_SLAVE_SEQUENCER_SV

class axi_slave_sequencer extends axi_seqr_base;
    `uvm_component_utils(axi_slave_sequencer)

    axi_mem_model           mem;
    axi_seq_item            aw_pending_q[$];
    axi_seq_item            w_pending_q[$];

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
        // AXI-4 Slave handles AW and W transaction inorder
        aw_pending_q.push_back(aw_txn);
        `uvm_info ("SLV_GET_AW_TXN", $sformatf("Get AW ID: 0x%h", aw_txn.id), UVM_LOW)
    endfunction

    virtual function void write_w ( axi_seq_item w_txn );
        // AXI-4 Slave handles W transaction without handling WID
        w_pending_q.push_back(w_txn);
        `uvm_info ("SLV_GET_W_TXN", $sformatf("Get W ID: 0x%h", w_txn.id), UVM_LOW)
    endfunction
    
endclass

`endif