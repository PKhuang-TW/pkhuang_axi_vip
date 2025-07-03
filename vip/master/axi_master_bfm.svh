`ifndef AXI_MASTER_BFM_SVH
`define AXI_MASTER_BFM_SVH

class axi_master_bfm;

    virtual axi_if.master   vif;

    extern function new ( virtual axi_if.master vif );

    extern task drive_aw_txn ( input axi_seq_item txn );
    extern task drive_w_txn ( input axi_seq_item txn );
    extern task drive_b_txn ( input axi_seq_item txn );
    extern task drive_ar_txn ( input axi_seq_item txn );
    extern task drive_r_txn ( input axi_seq_item txn );
endclass

`endif