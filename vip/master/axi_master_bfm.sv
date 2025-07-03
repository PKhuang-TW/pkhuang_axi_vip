`ifndef AXI_MASTER_BFM_SV
`define AXI_MASTER_BFM_SV

function axi_master_bfm::new ( virtual axi_if.master vif );
    this.vif = vif;
endfunction

task axi_master_bfm::drive_aw_txn ( input axi_seq_item txn );
    vif.AWVALID <= 1;
    vif.AWID    <= txn.aw_id;
    vif.AWADDR  <= txn.aw_addr;
    vif.AWLEN   <= txn.aw_len;
    vif.AWSIZE  <= txn.aw_size;
    vif.AWBURST <= txn.aw_burst;
    vif.AWPROT  <= txn.aw_prot;

    @ ( posedge vif.ACLK );
    wait ( vif.AWREADY );
endtask : drive_aw_txn

task axi_master_bfm::drive_w_txn ( input axi_seq_item txn );
    for ( int i=0; i<=txn.aw_len; i++ ) begin
        vif.WVALID <= 1;
        vif.WID    <= txn.w_id;
        vif.WDATA  <= txn.w_data[i];
        vif.WSTRB  <= txn.w_strb[i];

        if ( i==txn.aw_size )
            vif.WLAST <= 1;

        @ ( posedge vif.ACLK );
        wait ( vif.WREADY );
    end
endtask : drive_w_txn

task axi_master_bfm::drive_b_txn ( input axi_seq_item txn );
    vif.BREADY <= 1;
    @ ( posedge vif.ACLK );
    wait ( vif.BVALID );
    vif.BREADY <= 0;
endtask : drive_b_txn

task axi_master_bfm::drive_ar_txn ( input axi_seq_item txn );
    vif.ARVALID <= 1;
    vif.ARID    <= txn.ar_id;
    vif.ARADDR  <= txn.ar_addr;
    vif.ARLEN   <= txn.ar_len;
    vif.ARSIZE  <= txn.ar_size;
    vif.ARBURST <= txn.ar_burst;
    vif.ARPROT  <= txn.ar_prot;

    @ ( posedge vif.ACLK );
    wait ( vif.ARREADY );
endtask : drive_ar_txn

task axi_master_bfm::drive_r_txn ( input axi_seq_item txn );
    vif.RREADY <= 1;
    @ ( posedge vif.ACLK );
    wait ( vif.RVALID );
    vif.RREADY <= 0;
endtask : drive_r_txn

`endif