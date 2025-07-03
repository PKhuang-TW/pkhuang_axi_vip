`ifndef AXI_SLAVE_BFM_SV
`define AXI_SLAVE_BFM_SV

function axi_slave_bfm::new ( virtual axi_if.slave vif );
    this.vif = vif;
endfunction

task axi_slave_bfm::aw_signal_handler ( input axi_seq_item txn );
    forever begin
        @ ( posedge vif.ACLK );
        wait ( vif.AWVALID );
        vif.AWREADY <= 0;
        mem_model.calc_addr_q (
            .id(txn.aw_id),
            .burst_type(txn.aw_burst),
            .addr(txn.aw_addr),
            .len(txn.aw_len),
            .size(txn.aw_size),
            .id_2_addr_q(w_id_2_addr_q)
        );
        vif.AWREADY <= 1;
    end
endtask : aw_signal_handler

task axi_slave_bfm::w_signal_handler ( input axi_seq_item txn );
    forever begin
        @ ( posedge vif.ACLK );
        wait ( vif.WVALID );
        vif.WREADY <= 0;
        mem_model.write_burst(txn);
        vif.WREADY <= 1;
    end
endtask : w_signal_handler

task axi_slave_bfm::b_signal_handler ( input axi_seq_item txn );
    vif.BREADY <= 1;
    @ ( posedge vif.ACLK );
    wait ( vif.BVALID );
    vif.BREADY <= 0;
endtask : b_signal_handler

task axi_slave_bfm::ar_signal_handler ( input axi_seq_item txn );
    vif.ARVALID <= 1;
    vif.ARID    <= txn.ar_id;
    vif.ARADDR  <= txn.ar_addr;
    vif.ARLEN   <= txn.ar_len;
    vif.ARSIZE  <= txn.ar_size;
    vif.ARBURST <= txn.ar_burst;
    vif.ARPROT  <= txn.ar_prot;

    @ ( posedge vif.ACLK );
    wait ( vif.ARREADY );
endtask : ar_signal_handler

task axi_slave_bfm::r_signal_handler ( input axi_seq_item txn );
    vif.RREADY <= 1;
    @ ( posedge vif.ACLK );
    wait ( vif.RVALID );
    vif.RREADY <= 0;
endtask : r_signal_handler

`endif