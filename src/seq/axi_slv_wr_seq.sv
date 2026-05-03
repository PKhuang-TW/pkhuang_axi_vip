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
        forever begin
            fork
                p_sequencer.aw_fifo.get(aw_req);
                p_sequencer.w_fifo.get(w_req);
            join

            // ========================================
            // TODO: handle memory model operation here
            // ========================================

            b_rsp = axi_seq_item :: type_id :: create("b_rsp");

            start_item(b_rsp);
            b_rsp.kind      = B_TXN;
            b_rsp.b_id      = aw_req.aw_id;
            b_rsp.b_resp    = RSP_OKAY;
            finish_item(b_rsp);
        end
    endtask

endclass

`endif