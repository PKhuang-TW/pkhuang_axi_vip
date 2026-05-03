`ifndef AXI_MST_OUTSTANDING_WR_VSEQ_SV
`define AXI_MST_OUTSTANDING_WR_VSEQ_SV

class axi_mst_outstanding_wr_vseq extends axi_vseq_base;
    `uvm_object_utils(axi_mst_outstanding_wr_vseq)

    `uvm_declare_p_sequencer(axi_virtual_sequencer)

    rand int        seq_num;

    axi_aw_seq      aw_seq;
    axi_w_seq       w_seq;
    axi_b_seq       b_seq;

    axi_seq_item    aw_txn, w_txn, b_txn;
    axi_seq_item    aw_txn_q[$], w_txn_q[$], b_rsp_q[$];

    constraint num_cns {
        soft seq_num inside {[1:10]};
    }

    function new(string name = "axi_mst_outstanding_wr_vseq");
        super.new(name);
        `uvm_info ( get_full_name(), $sformatf("seq_num = %0d", seq_num), UVM_MEDIUM )
    endfunction

    virtual task body();

        int aw_idx, w_idx;

        super.body();
        
        for ( int i=0; i<seq_num; i++ ) begin
            aw_txn = axi_seq_item :: type_id :: create ("aw_txn");
            w_txn = axi_seq_item :: type_id :: create ("w_txn");
            b_txn = axi_seq_item :: type_id :: create ("b_txn");

            aw_txn.randomize() with { kind == AW_TXN; };
            aw_txn_q.push_back(aw_txn);

            w_txn.copy(aw_txn);
            w_txn.kind = W_TXN;
            w_txn_q.push_back(w_txn);
        end

        for ( int i=0; i<seq_num; i++ ) begin

            fork
                repeat(seq_num) begin
                    aw_idx = $urandom_range(0, aw_txn_q.size()-1);
                    aw_txn = aw_txn_q[aw_idx];
                    aw_txn_q.delete(aw_idx);


                    aw_seq = axi_aw_seq :: type_id :: create ("aw_seq");
                    aw_seq.txn = aw_txn;
                    aw_seq.start ( p_sequencer.seqr_mst );
                    `uvm_info(get_full_name(), $sformatf("TXN %0d sent: ID = 0x%h", i, aw_seq.txn.aw_id), UVM_LOW)
                end

                repeat(seq_num) begin
                    w_idx = $urandom_range(0, w_txn_q.size()-1);
                    w_txn = w_txn_q[w_idx];
                    w_txn_q.delete(w_idx);

                    w_seq = axi_w_seq :: type_id :: create ("w_seq");
                    w_seq.txn = w_txn;
                    w_seq.start ( p_sequencer.seqr_mst );
                end

                repeat(seq_num) begin
                    `uvm_do_on ( b_seq, p_sequencer.seqr_mst )
                end
            join
            
            `uvm_info(get_full_name(), $sformatf("Txn %0d completed: ID = 0x%h", i, b_seq.rsp.b_id), UVM_LOW)
        end
    endtask

endclass

`endif