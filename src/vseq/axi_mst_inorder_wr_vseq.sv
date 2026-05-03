`ifndef AXI_MST_INORDER_WR_VSEQ_SV
`define AXI_MST_INORDER_WR_VSEQ_SV

class axi_mst_inorder_wr_vseq extends axi_vseq_base;
    `uvm_object_utils(axi_mst_inorder_wr_vseq)

    `uvm_declare_p_sequencer(axi_virtual_sequencer)

    rand int        seq_num;

    axi_aw_seq      aw_seq;
    axi_w_seq       w_seq;
    axi_b_seq       b_seq;

    constraint num_cns {
        soft seq_num inside {[1:10]};
    }

    function new(string name = "axi_mst_inorder_wr_vseq");
        super.new(name);
        `uvm_info ( get_full_name(), $sformatf("seq_num = %0d", seq_num), UVM_MEDIUM )
    endfunction

    virtual task body();
        super.body();
        
        for ( int i=0; i<seq_num; i++ ) begin
            aw_seq = axi_aw_seq :: type_id :: create ("aw_seq");
            w_seq = axi_w_seq :: type_id :: create ("w_seq");
            b_seq = axi_b_seq :: type_id :: create ("b_seq");

            `uvm_do_on( aw_seq, p_sequencer.seqr_mst )
            `uvm_info(get_full_name(), $sformatf("TXN %0d sent: ID = 0x%h", i, aw_seq.txn.aw_id), UVM_LOW)

            `uvm_do_on_with (
                w_seq,
                p_sequencer.seqr_mst,
                {
                    aw_id       == aw_seq.txn.aw_id;
                    aw_addr     == aw_seq.txn.aw_addr;
                    aw_len      == aw_seq.txn.aw_len;
                    aw_size     == aw_seq.txn.aw_size;
                    aw_burst    == aw_seq.txn.aw_burst;
                    aw_prot     == aw_seq.txn.aw_prot;
                }
            )

            `uvm_do_on ( b_seq, p_sequencer.seqr_mst )
            
            `uvm_info(get_full_name(), $sformatf("Txn %0d completed: ID = 0x%h", i, b_seq.rsp.b_id), UVM_LOW)
        end
    endtask

endclass

`endif