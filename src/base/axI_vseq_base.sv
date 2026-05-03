`ifndef AXI_VSEQ_BASE_SV
`define AXI_VSEQ_BASE_SV

class axi_vseq_base extends uvm_sequence;
    `uvm_object_utils(axi_vseq_base)

    `uvm_declare_p_sequencer(axi_virtual_sequencer)

    axi_slv_wr_seq      slv_wr_seq;
    
    function new(string name = "axi_vseq_base");
        super.new(name);
    endfunction

    virtual task body();
        fork
            // Let Slave always waiting for AW/W req, and then response with B channel
            slv_wr_seq = axi_slv_wr_seq::type_id::create("slv_wr_seq");
            `uvm_do_on(slv_wr_seq, p_sequencer.seqr_slv);
        join_none
    endtask

endclass

`endif