`ifndef AXI_MST_OUTSTANDING_WR_VSEQ_SV
`define AXI_MST_OUTSTANDING_WR_VSEQ_SV

class axi_mst_outstanding_wr_vseq extends axi_vseq_base;
    `uvm_object_utils(axi_mst_outstanding_wr_vseq)

    `uvm_declare_p_sequencer(axi_virtual_sequencer)

    axi_aw_seq      aw_seq;
    axi_w_seq       w_seq;
    axi_b_seq       b_seq;

    axi_seq_item    aw_txn, w_txn, b_txn;
    axi_seq_item    aw_txn_q[$], w_txn_q[$], b_rsp_q[$];

    function new(string name = "axi_mst_outstanding_wr_vseq");
        super.new(name);
        `uvm_info ( "outstanding_wr_vseq", $sformatf("seq_num = %0d", seq_num), UVM_MEDIUM )
    endfunction

    virtual task body();

        int aw_idx, w_idx;
        bit[`D_ID_WIDTH-1:0] exp_id_q[$], rcv_id_q[$], aw_order_q[$];

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

        fork
            repeat(seq_num) begin
                aw_idx = $urandom_range(0, aw_txn_q.size()-1);
                aw_txn = aw_txn_q[aw_idx];
                aw_idx_q.push_back(aw_idx);
                exp_id_q.push_back(aw_txn.aw_id);
                aw_txn_q.delete(aw_idx);

                aw_seq = axi_aw_seq :: type_id :: create ("aw_seq");
                aw_seq.txn = aw_txn;
                aw_seq.start ( p_sequencer.seqr_mst );
                `uvm_info("outstanding_wr_vseq", $sformatf("AW TXN sent: ID = 0x%h", aw_seq.txn.aw_id), UVM_LOW)
            
                @(p_sequencer.vif.ACLK);
            end

            while (w_txn_q.size() > 0) begin
                // AXI-4 removed WID, so master has to follow the order of AW to send W
                if ( aw_idx_q.size() ) begin
                    w_idx = aw_idx_q.pop_front();
                    w_txn = w_txn_q[w_idx];
                    w_txn_q.delete(w_idx);

                    w_seq = axi_w_seq :: type_id :: create ("w_seq");
                    w_seq.txn = w_txn;
                    w_seq.start ( p_sequencer.seqr_mst );
                    `uvm_info("outstanding_wr_vseq", $sformatf("W TXN sent: ID = 0x%h", w_seq.txn.w_id), UVM_LOW)
                end
                @(p_sequencer.vif.ACLK);
            end

            repeat(seq_num) begin
                `uvm_do_on ( b_seq, p_sequencer.seqr_mst )
                rcv_id_q.push_back(b_seq.rcv_id);
            
                @(p_sequencer.vif.ACLK);
            end
        join

        compare_id_queues ( exp_id_q, rcv_id_q );
        
        `uvm_info("outstanding_wr_vseq", $sformatf("Write TXN completed: ID = 0x%h", b_seq.rsp.b_id), UVM_LOW)
    endtask

    function void compare_id_queues(
        const ref bit [`D_ID_WIDTH-1:0] exp_q[$],
        const ref bit [`D_ID_WIDTH-1:0] rcv_q[$]
    );
        bit [`D_ID_WIDTH-1:0] sort_exp_q[$] = exp_q;
        bit [`D_ID_WIDTH-1:0] sort_rcv_q[$] = rcv_q;

        sort_exp_q.sort();
        sort_rcv_q.sort();

        if (sort_exp_q == sort_rcv_q) begin
            return;
        end

        `uvm_error("COMPARE_ID", "ID Queues contents are different!")

        if (sort_exp_q.size() != sort_rcv_q.size()) begin
            `uvm_error("COMPARE_ID", $sformatf("Size mismatch: Exp = %0d, Rcv = %0d", 
                                            sort_exp_q.size(), sort_rcv_q.size()))
        end

        begin
            int max_len = (sort_exp_q.size() > sort_rcv_q.size()) ? sort_exp_q.size() : sort_rcv_q.size();
            for (int i = 0; i < max_len; i++) begin
                if (i >= sort_exp_q.size()) begin
                    `uvm_error("COMPARE_ID", $sformatf("Extra in Rcv: 'h%0x", sort_rcv_q[i]))
                end else if (i >= sort_rcv_q.size()) begin
                    `uvm_error("COMPARE_ID", $sformatf("Missing in Rcv: 'h%0x", sort_exp_q[i]))
                end else if (sort_exp_q[i] !== sort_rcv_q[i]) begin
                    `uvm_error("COMPARE_ID", $sformatf("Mismatch at sorted index %0d: Exp = 'h%0x, Rcv = 'h%0x", i, sort_exp_q[i], sort_rcv_q[i]))
                end
            end
        end
    endfunction

endclass

`endif