`ifndef AXI_MASTER_DRIVER_SV
`define AXI_MASTER_DRIVER_SV

class axi_master_driver extends axi_driver_base;
    `uvm_component_utils(axi_master_driver)

    virtual axi_if.mst_if       vif;
    axi_seq_item                aw_q[$], w_q[$], b_q[$], ar_q[$], r_q[$];

    function new ( string name = "axi_master_driver", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        if ( !uvm_config_db #(virtual axi_if.mst_if) :: get (this, "", "vif.mst_if", vif) )
            `uvm_error("NOCFG", $sformatf("No vif is set for %s.vif", get_full_name()) )
    endfunction

    virtual task run_phase ( uvm_phase phase );
        fork
            forever begin get_txn()                 ;end
            forever begin drive_aw_txn()            ;end
            forever begin drive_w_txn()             ;end
            forever begin drive_b_txn()             ;end
            forever begin drive_ar_txn()            ;end
            forever begin drive_r_txn()             ;end
            forever begin reset_signal_handler()    ;end
        join
    endtask

    extern virtual task drive_aw_txn ();
    extern virtual task drive_w_txn ();
    extern virtual task drive_b_txn ();
    extern virtual task drive_ar_txn ();
    extern virtual task drive_r_txn ();

    extern virtual task reset_aw_signal();
    extern virtual task reset_w_signal();
    extern virtual task reset_b_signal();
    extern virtual task reset_ar_signal();
    extern virtual task reset_r_signal();
    extern virtual task reset_signal_handler();

    extern virtual task reset_axi_signal();

    extern virtual task get_txn();

    extern virtual task wait_clk ( int cycle );

    extern virtual task send_rsp_2_seq ( axi_seq_item txn );

endclass : axi_master_driver

task axi_master_driver::wait_clk ( int cycle );
    #1;  // simulate delay to trigger mst_cb
    @ ( vif.mst_cb );
endtask

task axi_master_driver::send_rsp_2_seq ( axi_seq_item txn );
    axi_seq_item    rsp;
    $cast ( rsp, txn.clone() );
    rsp.set_id_info(txn);
    seq_item_port.put_response(rsp);
    `uvm_info ( "send_rsp_2_seq", "Response Sent!", UVM_LOW )
endtask

task axi_master_driver::get_txn();
    axi_seq_item    txn;

    if ( vif.mst_cb.ARESETn ) begin        
        txn = axi_seq_item :: type_id :: create ("txn");
        seq_item_port.get_next_item(txn);

        if ( txn.kind == AW_TXN ) begin
            `uvm_info("GET_TXN", $sformatf("Kind = %s, AWID = 0x%h", txn.kind.name(), txn.aw_id), UVM_HIGH )
        end else if ( txn.kind == AR_TXN ) begin
            `uvm_info("GET_TXN", $sformatf("Kind = %s, ARID = 0x%h", txn.kind.name(), txn.ar_id), UVM_HIGH )
        end

        case ( txn.kind )
            AW_TXN:     aw_q.push_back(txn);
            AR_TXN:     ar_q.push_back(txn);            
            default:    `uvm_error("DRV", $sformatf("Unsupported txn.kind: %s", txn.kind.name()))
        endcase
        seq_item_port.item_done();
    end else begin
        wait_clk(1);
    end
endtask

task axi_master_driver::drive_aw_txn();
    axi_seq_item    txn;

    begin
        while ( !aw_q.size() || !vif.mst_cb.ARESETn ) wait_clk(1);

        txn = aw_q.pop_front();
        w_q.push_back(txn);

        vif.mst_cb.AWID    <= txn.aw_id;
        vif.mst_cb.AWADDR  <= txn.aw_addr;
        vif.mst_cb.AWLEN   <= txn.aw_len;
        vif.mst_cb.AWSIZE  <= txn.aw_size;
        vif.mst_cb.AWBURST <= txn.aw_burst;
        vif.mst_cb.AWPROT  <= txn.aw_prot;
        vif.mst_cb.AWVALID <= 1;
        
        wait_clk(1);
        wait ( vif.mst_cb.AWREADY );
        reset_aw_signal();

        `uvm_info (
            "drive_aw_txn",
            $sformatf("ID=0x%h, ARADDR=0x%h, ARLEN=%0d, ARSIZE=%0d, ARBURST=%s", txn.aw_id, txn.aw_addr[0], txn.aw_len, txn.aw_size, txn.aw_burst.name()),
            UVM_DEBUG
        )
    end
endtask : drive_aw_txn

task axi_master_driver::drive_w_txn();
    int             q_idx;
    axi_seq_item    txn;
    
    begin
        while ( !w_q.size() || !vif.mst_cb.ARESETn ) wait_clk(1);

        // Support outstanding write transfer
        q_idx = $urandom_range ( 0, w_q.size()-1 );
        txn = w_q[q_idx];
        w_q.delete(q_idx);

        `uvm_info (
            "drive_w_txn",
            $sformatf("ID=0x%h", txn.w_id),
            UVM_DEBUG
        )

        for ( int i=0; i<=txn.aw_len; i++ ) begin
            vif.mst_cb.WID    <= txn.w_id;
            vif.mst_cb.WDATA  <= txn.w_data.pop_front();
            vif.mst_cb.WSTRB  <= txn.w_strb.pop_front();

            if ( i == txn.aw_len ) begin
                vif.mst_cb.WLAST <= 1;
                b_q.push_back(txn);
            end else begin
                vif.mst_cb.WLAST <= 0;
            end
            vif.mst_cb.WVALID <= 1;

            wait_clk(1);
            wait ( vif.mst_cb.WREADY );
            reset_w_signal();
        end
    end
endtask : drive_w_txn

task axi_master_driver::drive_b_txn();
    axi_seq_item    txn;
    
    begin
        wait ( vif.mst_cb.BVALID );

        txn = b_q.pop_front();
        txn.b_id <= vif.mst_cb.BID;
        vif.mst_cb.BREADY <= 0;

        wait_clk(1);
        reset_b_signal();

        txn.kind = B_TXN;
        send_rsp_2_seq(txn);
    end
endtask : drive_b_txn

task axi_master_driver::drive_ar_txn ();
    axi_seq_item    txn;
    
    begin
        while ( !ar_q.size() || !vif.mst_cb.ARESETn ) wait_clk(1);
                
        txn = ar_q.pop_front();
        r_q.push_back(txn);
        
        vif.mst_cb.ARID    <= txn.ar_id;
        vif.mst_cb.ARADDR  <= txn.ar_addr[0];
        vif.mst_cb.ARLEN   <= txn.ar_len;
        vif.mst_cb.ARSIZE  <= txn.ar_size;
        vif.mst_cb.ARBURST <= txn.ar_burst;
        vif.mst_cb.ARPROT  <= txn.ar_prot;
        vif.mst_cb.ARVALID <= 1;

        wait_clk(1);
        wait ( vif.mst_cb.ARREADY );
        reset_ar_signal();

        `uvm_info (
            "driver_ar_txn",
            $sformatf("ID=0x%h, ARADDR=0x%h, ARLEN=%0d, ARSIZE=%0d, ARBURST=%s", txn.ar_id, txn.ar_addr[0], txn.ar_len, txn.ar_size, txn.ar_burst.name()),
            UVM_DEBUG
        )
    end
endtask : drive_ar_txn

task axi_master_driver::drive_r_txn();
    axi_seq_item    txn;
    
    begin
        wait ( vif.mst_cb.RVALID );
        vif.mst_cb.RREADY  <= 0;

        if ( vif.mst_cb.RLAST ) begin
            txn = r_q.pop_front();
            txn.kind = R_TXN;
            txn.r_id = vif.mst_cb.RID;
            send_rsp_2_seq(txn);
        end

        wait_clk(1);
        reset_r_signal();
    end
endtask : drive_r_txn

task axi_master_driver::reset_signal_handler();
    begin
        wait ( !vif.mst_cb.ARESETn );
        `uvm_info(
            "reset_signal_handler",
            "Reset AXI signal!",
            UVM_DEBUG
        )
        reset_axi_signal();
    end
endtask

task axi_master_driver::reset_aw_signal();
    begin
        vif.mst_cb.AWID    <= 0;
        vif.mst_cb.AWADDR  <= 0;
        vif.mst_cb.AWLEN   <= 0;
        vif.mst_cb.AWSIZE  <= 0;
        vif.mst_cb.AWBURST <= 0;
        vif.mst_cb.AWPROT  <= 0;
        vif.mst_cb.AWVALID <= 0;
        wait_clk(1);
    end
endtask : reset_aw_signal

task axi_master_driver::reset_w_signal();
    begin
        vif.mst_cb.WID     <= 0;
        vif.mst_cb.WDATA   <= 0;
        vif.mst_cb.WSTRB   <= 0;
        vif.mst_cb.WLAST   <= 0;
        vif.mst_cb.WVALID  <= 0;
        wait_clk(1);
    end
endtask : reset_w_signal

task axi_master_driver::reset_b_signal();
    begin
        vif.mst_cb.BREADY  <= 1;
        wait_clk(1);
    end
endtask : reset_b_signal

task axi_master_driver::reset_ar_signal();
    begin
        vif.mst_cb.ARID    <= 0;
        vif.mst_cb.ARADDR  <= 0;
        vif.mst_cb.ARLEN   <= 0;
        vif.mst_cb.ARSIZE  <= 0;
        vif.mst_cb.ARBURST <= 0;
        vif.mst_cb.ARPROT  <= 0;
        vif.mst_cb.ARVALID <= 0;
        wait_clk(1);
    end
endtask : reset_ar_signal

task axi_master_driver::reset_r_signal();
    begin
        vif.mst_cb.RREADY  <= 1;
        wait_clk(1);
    end
endtask : reset_r_signal

task axi_master_driver::reset_axi_signal();
    fork
        reset_aw_signal();
        reset_w_signal();
        reset_b_signal();
        reset_ar_signal();
        reset_r_signal();
    join
endtask : reset_axi_signal

`endif