`ifndef AXI_AW_SEQ_SV
`define AXI_AW_SEQ_SV

class axi_write_seq extends uvm_sequence #(axi_seq_item);;
    `uvm_object_utils(axi_write_seq)

    axi_seq_item    txn, rsp;

    function new(string name = "axi_write_seq");
        super.new(name);
    endfunction: new

    task body();
        txn = axi_seq_item :: type_id :: create("txn");
        if ( !txn.randomize() with{ txn.kind == AW_TXN; })
            `uvm_fatal("RANDFAIL", "txn can't be randomized.");
        start_item(txn);
        finish_item(txn);

        get_response(rsp);

        `uvm_info("SEQ", $sformatf("Txn ID 0x%h completely finished!", rsp.b_id), UVM_LOW)
    endtask
    
endclass: axi_write_seq

`endif