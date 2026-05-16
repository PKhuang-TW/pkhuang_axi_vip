`ifndef AXI_SLV_WR_SEQ_SV
`define AXI_SLV_WR_SEQ_SV

class axi_slv_wr_seq extends uvm_sequence;
    `uvm_object_utils(axi_slv_wr_seq)

    `uvm_declare_p_sequencer(axi_slave_sequencer)
    
    axi_seq_item    aw_req, w_req, b_rsp;

    function new(string name = "axi_slv_wr_seq");
        super.new(name);
    endfunction

    virtual task body();
        fork
            forever begin
                p_sequencer.aw_pending_q.get(aw_req);
                p_sequencer.w_pending_q.get(w_req);

                if ( aw_req.aw_id != w_req.w_id ) begin
                    `uvm_error (
                        "TXN_ORDER_ERROR",
                        $sformatf("Slave gets txn with AWID = 0x%h while WID = 0x%h", aw_req.aw_id, w_req.w_id)
                    )
                end else begin
                    b_rsp = axi_seq_item :: type_id :: create("b_rsp");

                    start_item(b_rsp);
                    b_rsp.kind      = B_TXN;
                    b_rsp.b_id      = aw_req.aw_id;
                    b_rsp.b_resp    = RSP_OKAY;  // default OKAY
                    finish_item(b_rsp);
                    `uvm_info ("SLV_SEND_B_TXN", $sformatf("Send B ID: 0x%h", aw_req.id), UVM_LOW)
                end
            end
        join_none
    endtask

endclass

`endif