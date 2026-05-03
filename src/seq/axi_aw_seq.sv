`ifndef AXI_AW_SEQ_SV
`define AXI_AW_SEQ_SV

class axi_aw_seq extends uvm_sequence #(axi_seq_item);;
    `uvm_object_utils(axi_aw_seq)

    rand axi_seq_item   txn;

    function new(string name = "axi_aw_seq");
        super.new(name);
    endfunction: new

    task body();
        txn = axi_seq_item :: type_id :: create("txn");
        start_item(txn);
        if ( !txn.randomize() with{ txn.kind == AW_TXN; })
            `uvm_fatal("RANDFAIL", "txn can't be randomized.");
        finish_item(txn);
    endtask
    
endclass: axi_aw_seq

`endif