`ifndef AXI_MASTER_SEQUENCER_SV
`define AXI_MASTER_SEQUENCER_SV

class axi_master_sequencer extends axi_seqr_base;
    `uvm_component_utils(axi_master_sequencer)

    // bit [`D_MEM_SIZE-1:0]                                       addr_tracker;
    // uvm_analysis_imp #(axi_seq_item, axi_master_sequencer)      ap_imp;

    function new ( string name = "axi_master_sequencer", uvm_component parent );
        super.new(name, parent);
        // ap_imp = new("ap_imp", this);
    endfunction

    function void build_phase ( uvm_phase phase );
        super.build_phase(phase);
    endfunction

    // function void write ( axi_seq_item txn );
    //     bit[`D_ADDR_WIDTH_BIT-1:0]      addr;
    //     bit[7:0]                    len;
    //     bit[2:0]                    size;
    //     burst_type_e                burst;

    //     bit [`D_ADDR_WIDTH_BIT-1:0]     addr_q[$];

    //     case ( txn.kind )
    //         AW_TXN: begin
    //             addr    = txn.aw_addr;
    //             len     = txn.aw_len;
    //             size    = txn.aw_size;
    //             burst   = txn.aw_burst;
    //         end

    //         AR_TXN: begin
    //             addr    = txn.ar_addr;
    //             len     = txn.ar_len;
    //             size    = txn.ar_size;
    //             burst   = txn.ar_burst;
    //         end

    //         B_TXN: begin
    //             addr    = txn.aw_addr;
    //             len     = txn.aw_len;
    //             size    = txn.aw_size;
    //         end

    //         R_TXN: begin
    //             addr    = txn.aw_addr;
    //             len     = txn.aw_len;
    //             size    = txn.aw_size;
    //         end
    //     endcase

    //     addr_q = get_addr_q ( addr, len, size, burst );
    // endfunction

    // virtual task pre_do ( uvm_sequence_item item, bit is_item );
    //     axi_seq_item txn;

    //     if ( !is_item ) return;


    // endtask


    
endclass

`endif