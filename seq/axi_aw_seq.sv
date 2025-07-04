`ifndef AXI_AW_SEQ_SV
`define AXI_AW_SEQ_SV

class axi_aw_seq extends uvm_sequence;
    `uvm_object_utils(axi_aw_seq)

    axi_seq_item    txn;

    function new(string name = "axi_aw_seq");
        super.new(name);
    endfunction: new

    task body();
        for ( int i=0; i<100; i++ ) begin
            txn = axi_seq_item :: type_id :: create("txn");
            if ( !txn.randomize() with{ txn.kind == AW_TXN; })
                `uvm_fatal("RANDFAIL", "txn can't be randomized.");
            start_item(txn);
            finish_item(txn);
        end
    endtask
    
endclass: axi_aw_seq

`endif