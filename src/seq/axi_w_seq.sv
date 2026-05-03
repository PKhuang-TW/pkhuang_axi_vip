`ifndef AXI_W_SEQ_SV
`define AXI_W_SEQ_SV

class axi_w_seq extends uvm_sequence #(axi_seq_item);;
    `uvm_object_utils(axi_w_seq)

    rand axi_seq_item               txn;
    
    rand bit[`D_ID_WIDTH-1:0]       aw_id;
    rand bit[`D_ADDR_WIDTH-1:0]     aw_addr;
    rand bit[7:0]                   aw_len;
    rand bit[2:0]                   aw_size;
    rand burst_type_e               aw_burst;
    rand prot_s                     aw_prot;

    function new(string name = "axi_w_seq");
        super.new(name);
    endfunction: new

    task body();
        txn = axi_seq_item :: type_id :: create("txn");
        start_item(txn);
        if ( !txn.randomize() with {
            txn.kind        == W_TXN;
            txn.aw_id       == local::aw_id;
            txn.aw_addr     == local::aw_addr;
            txn.aw_len      == local::aw_len;
            txn.aw_size     == local::aw_size;
            txn.aw_burst    == local::aw_burst;
            txn.aw_prot     == local::aw_prot;
        })
            `uvm_fatal("RANDFAIL", "txn can't be randomized.");
        finish_item(txn);
    endtask
    
endclass: axi_w_seq

`endif