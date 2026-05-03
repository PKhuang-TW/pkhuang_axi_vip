`ifndef AXI_RAND_RW_SEQ_SV
`define AXI_RAND_RW_SEQ_SV

class axi_rand_rw_seq extends uvm_sequence #(axi_seq_item);
    `uvm_object_utils(axi_rand_rw_seq)
    
    int                     txn_num, rsp_cnt;
    bit [`D_ID_WIDTH-1:0]   ongoing_w_id[$], ongoing_r_id[$];

    function new(string name = "axi_rand_rw_seq");
        super.new(name);
        txn_num = 100;
        rsp_cnt = 0;
    endfunction: new

    task body();
        fork
            begin
                for ( int i=0; i<txn_num; i++ ) begin
                    req = axi_seq_item :: type_id :: create("req");

                    start_item(req);
                    rand_txn();
                    if ( req.kind == AW_TXN ) begin
                        ongoing_w_id.push_back(req.aw_id);
                    end else if ( req.kind == AR_TXN ) begin
                        ongoing_r_id.push_back(req.ar_id);
                    end
                    finish_item(req);
                end
            end
            begin
                while ( rsp_cnt < txn_num ) begin
                    get_response(rsp);

                    rsp_cnt++;
                    `uvm_info (
                        "SEQ",
                        $sformatf("Get No.%0d response", rsp_cnt),
                        UVM_HIGH
                    )

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
            end
        join
        `uvm_info ( "SEQ", "Sequence Done!", UVM_LOW )
    endtask

    virtual function void rand_txn();
        if ( !req.randomize() with {
            aw_len <= 3;
            ar_len <= 3;
            ! ( req.aw_id inside {ongoing_w_id});
            ! ( req.ar_id inside {ongoing_r_id});
        } )
            `uvm_fatal("RANDFAIL", "txn can't be randomized.");
    endfunction
    
endclass: axi_rand_rw_seq

`endif