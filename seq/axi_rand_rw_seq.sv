`ifndef AXI_RAND_RW_SEQ_SV
`define AXI_RAND_RW_SEQ_SV

class axi_rand_rw_seq extends uvm_sequence #(axi_seq_item);
    `uvm_object_utils(axi_rand_rw_seq)
    
    bit [`D_ID_WIDTH-1:0]   ongoing_w_id[$], ongoing_r_id[$];

    function new(string name = "axi_rand_rw_seq");
        super.new(name);
    endfunction: new

    task body();
        bit [`D_ID_WIDTH-1:0] match_list[$];

        for ( int i=0; i<100; i++ ) begin
            req = axi_seq_item :: type_id :: create("req");

            start_item(req);
            rand_txn();
            if ( req.kind == AW_TXN ) begin
                match_list = ongoing_w_id.find with (item == req.aw_id);
                while ( match_list.size() ) begin
                    `uvm_info(
                        "RAND",
                        "Randomize AW TXN again...",
                        UVM_HIGH
                    )
                    rand_txn();
                end
            end else if ( req.kind == AR_TXN ) begin
                match_list = ongoing_r_id.find with (item == req.ar_id);
                while ( match_list.size() ) begin
                    `uvm_info(
                        "RAND",
                        "Randomize AR TXN again...",
                        UVM_HIGH
                    )
                    rand_txn();
                end
            end
            finish_item(req);
            
            get_response(rsp);

            // rsp.print();

            if ( rsp.kind == B_TXN ) begin
                ongoing_w_id = ongoing_w_id.find with (item != rsp.b_id);

                `uvm_info(
                    "SEQ",
                    $sformatf("Write TXN ID 0x%h completes", rsp.b_id ),
                    UVM_HIGH
                )
            end else if ( rsp.kind == R_TXN ) begin
                ongoing_r_id = ongoing_r_id.find with (item != rsp.r_id);

                `uvm_info(
                    "SEQ",
                    $sformatf("Read TXN ID 0x%h completes", rsp.r_id ),
                    UVM_HIGH
                )
            end
        end
    endtask

    virtual function void rand_txn();
        if ( !req.randomize() with{
            aw_len <= 3;
            ar_len <= 3;
        } )
            `uvm_fatal("RANDFAIL", "txn can't be randomized.");
    endfunction
    
endclass: axi_rand_rw_seq

`endif