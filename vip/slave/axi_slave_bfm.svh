`ifndef AXI_SLAVE_BFM_SVH
`define AXI_SLAVE_BFM_SVH

class axi_slave_bfm;

    axi_slave_mem_model             mem_model;

    virtual axi_if.slave            vif;

    extern function new ( virtual axi_if.slave vif );

    extern task drive_aw_txn ( input axi_seq_item txn );
    extern task drive_w_txn ( input axi_seq_item txn );
    extern task drive_b_txn ( input axi_seq_item txn );
    extern task drive_ar_txn ( input axi_seq_item txn );
    extern task drive_r_txn ( input axi_seq_item txn );
endclass

`endif