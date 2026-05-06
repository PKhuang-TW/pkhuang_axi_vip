`ifndef AXI_B_SEQ_SV
`define AXI_B_SEQ_SV

class axi_b_seq extends uvm_sequence #(axi_seq_item);;
    `uvm_object_utils(axi_b_seq)

    axi_seq_item            txn, rsp;
    bit[`D_ID_WIDTH-1:0]    rcv_id;

    function new(string name = "axi_b_seq");
        super.new(name);
    endfunction: new

    task body();
        txn = axi_seq_item :: type_id :: create("txn");
        start_item(txn);
        if ( !txn.randomize() with{ txn.kind == B_TXN; })
            `uvm_fatal("RANDFAIL", "txn can't be randomized.");
        finish_item(txn);

        get_response(rsp);

        rcv_id = rsp.b_id;

        `uvm_info ( "Get B Response", $sformatf("Response from ID(0x%h) is %s", rcv_id, rsp.b_resp.name()), UVM_MEDIUM )
    endtask
    
endclass: axi_b_seq

`endif