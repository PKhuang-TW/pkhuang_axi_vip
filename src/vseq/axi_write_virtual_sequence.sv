`ifndef AXI_WRITE_VIRTUAL_SEQUENCE_SV
`define AXI_WRITE_VIRTUAL_SEQUENCE_SV

class axi_write_virtual_sequence extends uvm_sequence;
    `uvm_object_utils(axi_write_virtual_sequence)

    `uvm_declare_p_sequencer(axi_virtual_sequencer)

    int             seq_num;
    axi_write_seq   w_seq;

    function new(string name = "axi_write_virtual_sequence");
        super.new(name);
        `uvm_info ( get_full_name(), $sformatf("seq_num = %d", seq_num), UVM_HIGH )
    endfunction

    virtual task body();
        for ( int i=0; i<seq_num; i++ ) begin
            w_seq = axi_write_seq :: type_id :: create ("w_seq");
            w_seq.start ( p_sequencer.seqr_mst );
        end
    endtask

endclass

`endif