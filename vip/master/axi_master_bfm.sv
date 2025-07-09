`ifndef AXI_MASTER_BFM_SV
`define AXI_MASTER_BFM_SV

class axi_master_bfm;

    virtual axi_if.mst_if   vif;

    function new ( virtual axi_if.mst_if vif );
        this.vif = vif;
    endfunction

    extern virtual task drive_aw_txn ( input axi_seq_item txn );
    extern virtual task drive_w_txn ( input axi_seq_item txn );
    extern virtual task drive_b_txn ( input axi_seq_item txn );
    extern virtual task drive_ar_txn ( input axi_seq_item txn );
    extern virtual task drive_r_txn ( input axi_seq_item txn );

    extern virtual task reset_aw_signal();
    extern virtual task reset_w_signal();
    extern virtual task reset_b_signal();
    extern virtual task reset_ar_signal();
    extern virtual task reset_r_signal();

    extern virtual task reset_axi_signal();
endclass

task axi_master_bfm::drive_aw_txn ( input axi_seq_item txn );
    vif.mst_cb.AWVALID <= 1;
    vif.mst_cb.AWID    <= txn.aw_id;
    vif.mst_cb.AWADDR  <= txn.aw_addr;
    vif.mst_cb.AWLEN   <= txn.aw_len;
    vif.mst_cb.AWSIZE  <= txn.aw_size;
    vif.mst_cb.AWBURST <= txn.aw_burst;
    vif.mst_cb.AWPROT  <= txn.aw_prot;

    wait ( vif.mst_cb.AWREADY );
    @ ( posedge vif.mst_cb.ACLK );
    reset_aw_signal();
endtask : drive_aw_txn

task axi_master_bfm::drive_w_txn ( input axi_seq_item txn );
    for ( int i=0; i<=txn.aw_len; i++ ) begin
        vif.mst_cb.WVALID <= 1;
        vif.mst_cb.WID    <= txn.w_id;
        vif.mst_cb.WDATA  <= txn.w_data[i];
        vif.mst_cb.WSTRB  <= txn.w_strb[i];

        if ( i==txn.aw_len ) begin
            vif.mst_cb.WLAST <= 1;
        end else begin
            vif.mst_cb.WLAST <= 0;
        end

        wait ( vif.mst_cb.WREADY );
        @ ( posedge vif.mst_cb.ACLK );
        reset_w_signal();
    end
endtask : drive_w_txn

task axi_master_bfm::drive_b_txn ( input axi_seq_item txn );
    // @ ( posedge vif.mst_cb.ACLK );
    wait ( vif.mst_cb.BVALID );
    @ ( posedge vif.mst_cb.ACLK );
    vif.mst_cb.BREADY <= 0;
    #1;  // Simulate Delay
    reset_b_signal();
endtask : drive_b_txn

task axi_master_bfm::drive_ar_txn ( input axi_seq_item txn );
    vif.mst_cb.ARVALID <= 1;
    vif.mst_cb.ARID    <= txn.ar_id;
    vif.mst_cb.ARADDR  <= txn.ar_addr;
    vif.mst_cb.ARLEN   <= txn.ar_len;
    vif.mst_cb.ARSIZE  <= txn.ar_size;
    vif.mst_cb.ARBURST <= txn.ar_burst;
    vif.mst_cb.ARPROT  <= txn.ar_prot;

    @ ( posedge vif.mst_cb.ACLK );
    wait ( vif.mst_cb.ARREADY );

    @ ( posedge vif.mst_cb.ACLK );
    reset_ar_signal();
endtask : drive_ar_txn

task axi_master_bfm::drive_r_txn ( input axi_seq_item txn );
    vif.mst_cb.RREADY <= 1;
    @ ( posedge vif.mst_cb.ACLK );
    wait ( vif.mst_cb.RVALID );

    @ ( posedge vif.mst_cb.ACLK );
    reset_r_signal();
endtask : drive_r_txn

task axi_master_bfm::reset_aw_signal();
    vif.mst_cb.AWID    <= 0;
    vif.mst_cb.AWADDR  <= 0;
    vif.mst_cb.AWLEN   <= 0;
    vif.mst_cb.AWSIZE  <= 0;
    vif.mst_cb.AWBURST <= 0;
    vif.mst_cb.AWPROT  <= 0;
    vif.mst_cb.AWVALID <= 0;
endtask : reset_aw_signal

task axi_master_bfm::reset_w_signal();
    vif.mst_cb.WID     <= 0;
    vif.mst_cb.WDATA   <= 0;
    vif.mst_cb.WSTRB   <= 0;
    vif.mst_cb.WLAST   <= 0;
    vif.mst_cb.WVALID  <= 0;
endtask : reset_w_signal

task axi_master_bfm::reset_b_signal();
    vif.mst_cb.BREADY  <= 1;
endtask : reset_b_signal

task axi_master_bfm::reset_ar_signal();
    vif.mst_cb.ARID    <= 0;
    vif.mst_cb.ARADDR  <= 0;
    vif.mst_cb.ARLEN   <= 0;
    vif.mst_cb.ARSIZE  <= 0;
    vif.mst_cb.ARBURST <= 0;
    vif.mst_cb.ARPROT  <= 0;
    vif.mst_cb.ARVALID <= 0;
endtask : reset_ar_signal

task axi_master_bfm::reset_r_signal();
    vif.mst_cb.RREADY  <= 1;
endtask : reset_r_signal

task axi_master_bfm::reset_axi_signal();
    reset_aw_signal();
    reset_w_signal();
    reset_b_signal();
    reset_ar_signal();
    reset_r_signal();
endtask : reset_axi_signal

`endif