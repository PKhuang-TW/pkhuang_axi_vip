`ifndef AXI_RAND_RW_SEQ_SV
`define AXI_RAND_RW_SEQ_SV

class axi_rand_rw_seq extends uvm_sequence;
    `uvm_object_utils(axi_rand_rw_seq)

    axi_seq_item    txn;

    function new(string name = "axi_rand_rw_seq");
        super.new(name);
    endfunction: new

    task body();
        for ( int i=0; i<100; i++ ) begin
            txn = axi_seq_item :: type_id :: create("txn");
            if ( !txn.randomize() )
                `uvm_fatal("RANDFAIL", "txn can't be randomized.");
            start_item(txn);
            finish_item(txn);
        end
    endtask
    
endclass: axi_rand_rw_seq

`endif
