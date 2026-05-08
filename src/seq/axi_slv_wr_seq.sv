`ifndef AXI_SLV_WR_SEQ_SV
`define AXI_SLV_WR_SEQ_SV

class axi_slv_wr_seq extends uvm_sequence;
    `uvm_object_utils(axi_slv_wr_seq)

    `uvm_declare_p_sequencer(axi_slave_sequencer)
    
    axi_seq_item    aw_req, w_req, b_rsp;

    // Track if AW and W transaction with specific ID has been received
    axi_seq_item    aw_rcv[bit[`D_ID_WIDTH-1:0]], w_rcv[bit[`D_ID_WIDTH-1:0]];  

    function new(string name = "axi_slv_wr_seq");
        super.new(name);
    endfunction

    virtual task body();

        bit[`D_ID_WIDTH-1:0]    id;

        bit                     ready_for_b_rsp = 0;

        fork
            forever begin
                p_sequencer.aw_fifo.get(aw_req);
                aw_rcv[aw_req.aw_id] = aw_req; // Mark the transaction as received
                `uvm_info ("GET_AW_TXN", $sformatf("Get AW ID: 0x%h", aw_req.aw_id), UVM_MEDIUM)
                @(p_sequencer.vif.slv_cb);
            end

            forever begin
                p_sequencer.w_fifo.get(w_req);
                w_rcv[w_req.w_id] = w_req; // Mark the transaction as received
                `uvm_info ("GET_W_TXN", $sformatf("Get W ID: 0x%h", w_req.w_id), UVM_MEDIUM)
                @(p_sequencer.vif.slv_cb);
            end

            forever begin
                int rand_idx;
                bit[`D_ID_WIDTH-1:0] w_id_q[$];

                if ( aw_rcv.size() && w_rcv.size() ) begin
                    w_id_q = w_rcv.find_index with(1);
                    rand_idx = $urandom_range(0, w_id_q.size()-1);
                    // `uvm_info ("axi_slv_wr_seq", $sformatf("rand_idx = %0d, w_id_q = %p", rand_idx, w_id_q), UVM_MEDIUM)

                    id = w_id_q[rand_idx];
                    if ( aw_rcv.exists(id) ) begin
                        `uvm_info ("axi_slv_wr_seq", $sformatf("Write ID: 0x%h completes, ready to send B response", id), UVM_MEDIUM)

                        // ========================================
                        // TODO: handle memory model operation here

                        // p_sequencer.mem.handle_wr_txn(aw_rcv[id], w_rcv[id]);
                        // ========================================

                        aw_rcv.delete(id);
                        w_rcv.delete(id);
                        ready_for_b_rsp = 1;
                    end
                end
                @(p_sequencer.vif.slv_cb);
            end

            forever begin
                if ( ready_for_b_rsp ) begin
                    b_rsp = axi_seq_item :: type_id :: create("b_rsp");

                    start_item(b_rsp);
                    b_rsp.kind      = B_TXN;
                    b_rsp.b_id      = id;
                    b_rsp.b_resp    = RSP_OKAY;
                    finish_item(b_rsp);

                    ready_for_b_rsp = 0;
                end
                @(p_sequencer.vif.slv_cb);
            end
        join_none
    endtask

endclass

`endif