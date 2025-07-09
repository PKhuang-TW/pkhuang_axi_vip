`ifndef AXI_MASTER_DRIVER_SV
`define AXI_MASTER_DRIVER_SV

class axi_master_driver extends axi_driver_base;
    `uvm_component_utils(axi_master_driver)

    // axi_master_driver      mst_bfm;
    virtual axi_if.mst_if       vif;

    function new ( string name = "axi_master_driver", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        // mst_bfm = new( .vif(vif.mst_if) );

        if ( !uvm_config_db #(virtual axi_if.mst_if) :: get (this, "", "vif.mst_if", vif) )
            `uvm_error("NOCFG", $sformatf("No vif is set for %s.vif", get_full_name()) )
    endfunction

    virtual task run_phase ( uvm_phase phase );
        @ ( vif.mst_cb );
        forever begin
            if ( !vif.mst_cb.ARESETn ) begin
                reset_axi_signal();
            end else begin
                txn = axi_seq_item :: type_id :: create ("txn");
                seq_item_port.get_next_item(txn);
                // $cast ( rsp, txn.clone());
                // rsp.set_id_info(txn);
                case ( txn.kind )
                    AW_TXN: begin
                        fork
                            drive_aw_txn(txn);
                            drive_w_txn(txn);
                            drive_b_txn(txn);
                        join_any
                    end

                    AR_TXN: begin
                        fork
                            drive_ar_txn(txn);
                            drive_r_txn(txn);
                        join_any
                    end
                    
                    default: begin
                        `uvm_error("DRV", $sformatf("Unsupported txn.kind: %s", txn.kind.name()));
                    end
                endcase
                seq_item_port.item_done();
                // txn.print();
                seq_item_port.put_response(txn);
            end
        end
        @ ( vif.mst_cb );
    endtask

    extern virtual task drive_aw_txn ( input axi_seq_item txn );
    extern virtual task drive_w_txn ( input axi_seq_item txn );
    extern virtual task drive_b_txn ( axi_seq_item txn );
    extern virtual task drive_ar_txn ( input axi_seq_item txn );
    extern virtual task drive_r_txn ( axi_seq_item txn );

    extern virtual task reset_aw_signal();
    extern virtual task reset_w_signal();
    extern virtual task reset_b_signal();
    extern virtual task reset_ar_signal();
    extern virtual task reset_r_signal();
    extern virtual task reset_signal_handler();

    extern virtual task reset_axi_signal();

    extern virtual task get_txn ( input axi_seq_item txn );

endclass : axi_master_driver

task axi_master_driver::get_txn();
    txn = axi_seq_item :: type_id :: create ("txn");
    seq_item_port.get_next_item(txn);
    
    seq_item_port.item_done();
endtask

task axi_master_driver::drive_aw_txn ( input axi_seq_item txn );
    begin
        txn.kind = AW_TXN;
        vif.mst_cb.AWVALID <= 1;
        vif.mst_cb.AWID    <= txn.aw_id;
        vif.mst_cb.AWADDR  <= txn.aw_addr;
        vif.mst_cb.AWLEN   <= txn.aw_len;
        vif.mst_cb.AWSIZE  <= txn.aw_size;
        vif.mst_cb.AWBURST <= txn.aw_burst;
        vif.mst_cb.AWPROT  <= txn.aw_prot;

        @ ( vif.mst_cb );
        wait ( vif.mst_cb.AWREADY );
        reset_aw_signal();
    end
endtask : drive_aw_txn

task axi_master_driver::drive_w_txn ( input axi_seq_item txn );
    begin
        txn.kind = W_TXN;
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

            @ ( vif.mst_cb );
            wait ( vif.mst_cb.WREADY );
            reset_w_signal();
        end
    end
endtask : drive_w_txn

task axi_master_driver::drive_b_txn ( axi_seq_item txn );
    begin
        wait ( vif.mst_cb.BVALID );
        txn.kind = B_TXN;
        txn.b_id = vif.mst_cb.BID;
        vif.mst_cb.BREADY <= 0;

        #1;  // Simulate Delay
        reset_b_signal();
    end
endtask : drive_b_txn

task axi_master_driver::drive_ar_txn ( input axi_seq_item txn );
    begin
        vif.mst_cb.ARVALID <= 1;
        vif.mst_cb.ARID    <= txn.ar_id;
        vif.mst_cb.ARADDR  <= txn.ar_addr;
        vif.mst_cb.ARLEN   <= txn.ar_len;
        vif.mst_cb.ARSIZE  <= txn.ar_size;
        vif.mst_cb.ARBURST <= txn.ar_burst;
        vif.mst_cb.ARPROT  <= txn.ar_prot;

        @ ( vif.mst_cb );
        wait ( vif.mst_cb.ARREADY );
        reset_ar_signal();
    end
endtask : drive_ar_txn

task axi_master_driver::drive_r_txn ( axi_seq_item txn );
    begin
        wait ( vif.mst_cb.RVALID );
        txn.kind = R_TXN;
        txn.b_id = vif.mst_cb.RID;
        vif.mst_cb.RREADY  <= 0;

        @ ( vif.mst_cb );
        // #1;  // Simulate Delay
        reset_r_signal();
    end
endtask : drive_r_txn

task axi_master_driver::reset_signal_handler();
    @ ( vif.mst_cb );
    if ( !vif.mst_cb.ARESETn )
        reset_axi_signal();
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
        // @ ( vif.mst_cb );
    end
endtask : reset_aw_signal

task axi_master_driver::reset_w_signal();
    begin
        vif.mst_cb.WID     <= 0;
        vif.mst_cb.WDATA   <= 0;
        vif.mst_cb.WSTRB   <= 0;
        vif.mst_cb.WLAST   <= 0;
        vif.mst_cb.WVALID  <= 0;
        // @ ( vif.mst_cb );
    end
endtask : reset_w_signal

task axi_master_driver::reset_b_signal();
    begin
        vif.mst_cb.BREADY  <= 1;
        @ ( vif.mst_cb );
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
        // @ ( vif.mst_cb );
    end
endtask : reset_ar_signal

task axi_master_driver::reset_r_signal();
    begin
        vif.mst_cb.RREADY  <= 1;
        @ ( vif.mst_cb );
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