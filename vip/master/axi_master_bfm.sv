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
    vif.AWVALID <= 1;
    vif.AWID    <= txn.aw_id;
    vif.AWADDR  <= txn.aw_addr;
    vif.AWLEN   <= txn.aw_len;
    vif.AWSIZE  <= txn.aw_size;
    vif.AWBURST <= txn.aw_burst;
    vif.AWPROT  <= txn.aw_prot;

    wait ( vif.AWREADY );
    @ ( posedge vif.ACLK );
    reset_aw_signal();
endtask : drive_aw_txn

task axi_master_bfm::drive_w_txn ( input axi_seq_item txn );
    for ( int i=0; i<=txn.aw_len; i++ ) begin
        vif.WVALID <= 1;
        vif.WID    <= txn.w_id;
        vif.WDATA  <= txn.w_data[i];
        vif.WSTRB  <= txn.w_strb[i];

        if ( i==txn.aw_len ) begin
            vif.WLAST <= 1;
        end else begin
            vif.WLAST <= 0;
        end

        wait ( vif.WREADY );
        @ ( posedge vif.ACLK );
        reset_w_signal();
    end
endtask : drive_w_txn

task axi_master_bfm::drive_b_txn ( input axi_seq_item txn );
    // @ ( posedge vif.ACLK );
    wait ( vif.BVALID );
    @ ( posedge vif.ACLK );
    vif.BREADY <= 0;
    #1;  // Simulate Delay
    reset_b_signal();
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

    @ ( posedge vif.ACLK );
    reset_ar_signal();
endtask : drive_ar_txn

task axi_master_bfm::drive_r_txn ( input axi_seq_item txn );
    vif.RREADY <= 1;
    @ ( posedge vif.ACLK );
    wait ( vif.RVALID );

    @ ( posedge vif.ACLK );
    reset_r_signal();
endtask : drive_r_txn

task axi_master_bfm::reset_aw_signal();
    vif.AWID    <= 0;
    vif.AWADDR  <= 0;
    vif.AWLEN   <= 0;
    vif.AWSIZE  <= 0;
    vif.AWBURST <= 0;
    vif.AWPROT  <= 0;
    vif.AWVALID <= 0;
endtask : reset_aw_signal

task axi_master_bfm::reset_w_signal();
    vif.WID     <= 0;
    vif.WDATA   <= 0;
    vif.WSTRB   <= 0;
    vif.WLAST   <= 0;
    vif.WVALID  <= 0;
endtask : reset_w_signal

task axi_master_bfm::reset_b_signal();
    vif.BREADY  <= 1;
endtask : reset_b_signal

task axi_master_bfm::reset_ar_signal();
    vif.ARID    <= 0;
    vif.ARADDR  <= 0;
    vif.ARLEN   <= 0;
    vif.ARSIZE  <= 0;
    vif.ARBURST <= 0;
    vif.ARPROT  <= 0;
    vif.ARVALID <= 0;
endtask : reset_ar_signal

task axi_master_bfm::reset_r_signal();
    vif.RREADY  <= 1;
endtask : reset_r_signal

task axi_master_bfm::reset_axi_signal();
    reset_aw_signal();
    reset_w_signal();
    reset_b_signal();
    reset_ar_signal();
    reset_r_signal();
endtask : reset_axi_signal

`endif