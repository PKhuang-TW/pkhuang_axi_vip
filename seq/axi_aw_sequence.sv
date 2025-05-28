`ifndef AXI_AW_SEQUENCE_SV
`define AXI_AW_SEQUENCE_SV

class axi_aw_sequence #(
    type TXN    = axi_transfer
) extends uvm_sequence;
    `uvm_object_utils(axi_aw_sequence)

    function new(string name = "axi_aw_sequence");
        super.new(name);
    endfunction: new

    task body();
        TXN     aw_txn;

        aw_txn = TXN :: type_id :: create("aw_txn");
        if ( !aw_txn.randomize() with{
            aw_txn.kind     == AW_TXN;
        })
            `uvm_fatal("RANDFAIL", "aw_txn can't be randomized.");
        start_item(aw_txn);
        finish_item(aw_txn);
    endtask
    
endclass: axi_aw_sequence

`endif