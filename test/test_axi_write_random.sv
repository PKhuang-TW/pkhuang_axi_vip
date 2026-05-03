`ifndef TEST_AXI_WRITE_RANDOM_SV
`define TEST_AXI_WRITE_RANDOM_SV

class test_axi_write_random extends axi_test_base;
    `uvm_component_utils(test_axi_write_random)
    
    axi_write_virtual_sequence  w_vseq;

    function new ( string name = "test_axi_write_random", uvm_component parent );
        super.new(name, parent);
    endfunction

    virtual task run_phase ( uvm_phase phase );
        phase.raise_objection(this);
        w_vseq = axi_write_virtual_sequence :: type_id :: create ("w_vseq");
        w_vseq.seq_num = 5;
        w_vseq.start ( env.vseqr );
        phase.drop_objection(this);
    endtask

endclass

`endif