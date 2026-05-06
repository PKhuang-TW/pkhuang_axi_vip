`ifndef TEST_AXI_INORDER_WRITE_RANDOM_SV
`define TEST_AXI_INORDER_WRITE_RANDOM_SV

class test_axi_inorder_write_random extends axi_test_base;
    `uvm_component_utils(test_axi_inorder_write_random)
    
    axi_mst_inorder_wr_vseq  w_vseq;

    function new ( string name = "test_axi_inorder_write_random", uvm_component parent );
        super.new(name, parent);
    endfunction

    virtual task run_phase ( uvm_phase phase );
        super.run_phase(phase);
        phase.raise_objection(this);
        w_vseq = axi_mst_inorder_wr_vseq :: type_id :: create ("w_vseq");

        if (!w_vseq.randomize() with { seq_num == 5; }) begin
            `uvm_error("TEST", "vseq randomization failed!")
        end
        w_vseq.start ( env.vseqr );

        phase.drop_objection(this);
    endtask

endclass

`endif