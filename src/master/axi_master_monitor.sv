`ifndef AXI_MASTER_MONITOR_SV
`define AXI_MASTER_MONITOR_SV

class axi_master_monitor extends axi_monitor_base;
    `uvm_component_utils(axi_master_monitor)

    function new ( string name="axi_master_monitor", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase (uvm_phase phase);
        fork
            forever begin monitor_aw_channel()  ;end
            forever begin monitor_w_channel()   ;end
            forever begin monitor_b_channel()   ;end
            forever begin monitor_ar_channel()  ;end
            forever begin monitor_r_channel()   ;end
            forever begin write_ap()            ;end
        join
    endtask

    virtual task write_ap();
        begin
            if ( txn_q.size() ) begin
                txn = txn_q.pop_front();
                ap.write(txn);
            end
            wait_clk(1);
        end
    endtask

    virtual task monitor_aw_channel();
        axi_seq_item    aw_txn;

        begin
            if ( vif.mon_cb.AWVALID && vif.mon_cb.AWREADY ) begin
                // @ ( posedge vif.mon_cb.ACLK iff ( vif.mon_cb.AWVALID && vif.mon_cb.AWREADY ) );
                aw_txn = axi_seq_item :: type_id :: create("aw_txn");
                aw_txn.kind         = AW_TXN;
                aw_txn.aw_id        = vif.mon_cb.AWID;
                aw_txn.aw_addr      = vif.mon_cb.AWADDR;
                aw_txn.aw_len       = vif.mon_cb.AWLEN;
                aw_txn.aw_size      = vif.mon_cb.AWSIZE;
                $cast ( aw_txn.aw_burst, vif.mon_cb.AWBURST );
                aw_txn.aw_prot      = vif.mon_cb.AWPROT;
                // ap.write(aw_txn);

                `uvm_info (
                    "monitor_aw_channel",
                    $sformatf("Monitor AW Signal: ID = 0x%h", vif.mon_cb.AWID),
                    UVM_HIGH
                )

                txn_q.push_back(aw_txn);
            end
            wait_clk(1);
        end
    endtask : monitor_aw_channel

    virtual task monitor_w_channel();
        axi_seq_item            w_txn;
        bit[`D_ID_WIDTH-1:0]    id;

        begin
            if ( vif.mon_cb.WVALID && vif.mon_cb.WREADY ) begin
                // @ ( posedge vif.mon_cb.ACLK iff ( vif.mon_cb.WVALID && vif.mon_cb.WREADY ) );
                w_txn = axi_seq_item :: type_id :: create("w_txn");
                
                w_txn.kind = W_TXN;
                w_txn.w_id = vif.mon_cb.WID;

                forever begin
                    if ( vif.mon_cb.WVALID ) begin
                        if ( vif.mon_cb.WID != w_txn.w_id ) begin
                            `uvm_error (
                                "monitor_w_channel",
                                $sformatf("Expected WID = 0x%h while actual WID = 0x%h", w_txn.w_id, vif.mon_cb.WID)
                            )
                        end else begin
                            `uvm_info(
                                "monitor_w_channel",
                                $sformatf("ID=0x%h, Data=0x%h, Strb='b%b, Last=%0d", w_txn.w_id, vif.mon_cb.WDATA, vif.mon_cb.WSTRB, vif.mon_cb.WLAST),
                                UVM_DEBUG
                            )
                            w_txn.w_data.push_back ( vif.mon_cb.WDATA );
                            w_txn.w_strb.push_back ( vif.mon_cb.WSTRB );
                            if ( vif.mon_cb.WLAST ) break;
                        end
                    end
                    wait_clk(1);
                end

                w_txn.w_last  = 1;
                // ap.write(w_txn);
                txn_q.push_back(w_txn);
            end
            wait_clk(1);
        end
    endtask : monitor_w_channel

    virtual task monitor_b_channel();
        axi_seq_item            b_txn;

        begin
            if ( vif.mon_cb.BVALID && vif.mon_cb.BREADY ) begin
                // @ ( posedge vif.mon_cb.ACLK iff ( vif.mon_cb.BVALID && vif.mon_cb.BREADY ) );
                b_txn = axi_seq_item :: type_id :: create("b_txn");
                b_txn.kind    = B_TXN;
                b_txn.b_id    = vif.mon_cb.BID;
                $cast ( b_txn.b_resp, vif.mon_cb.BRESP );
                // ap.write(b_txn);
                txn_q.push_back(b_txn);
            end
            wait_clk(1);
        end
    endtask : monitor_b_channel

    virtual task monitor_ar_channel();
        axi_seq_item            ar_txn;

        begin
            if ( vif.mon_cb.ARVALID && vif.mon_cb.ARREADY ) begin
                // @ ( posedge vif.mon_cb.ACLK iff ( vif.mon_cb.ARVALID && vif.mon_cb.ARREADY ) );
                ar_txn = axi_seq_item :: type_id :: create("ar_txn");
                ar_txn.kind        = AR_TXN;
                ar_txn.ar_id       = vif.mon_cb.ARID;
                ar_txn.ar_addr     = vif.mon_cb.ARADDR;
                ar_txn.ar_len      = vif.mon_cb.ARLEN;
                ar_txn.ar_size     = vif.mon_cb.ARSIZE;
                $cast ( ar_txn.ar_burst, vif.mon_cb.ARBURST );
                ar_txn.ar_prot     = vif.mon_cb.ARPROT;
                // ap.write(ar_txn);
                txn_q.push_back(ar_txn);
            end
            wait_clk(1);
        end
    endtask : monitor_ar_channel

    virtual task monitor_r_channel();
        axi_seq_item            r_txn;
        bit[`D_ID_WIDTH-1:0]    id;

        begin
            if ( vif.mon_cb.RVALID && vif.mon_cb.RREADY ) begin
                // @ ( posedge vif.mon_cb.ACLK iff ( vif.mon_cb.RVALID && vif.mon_cb.RREADY ) );
                r_txn = axi_seq_item :: type_id :: create("r_txn");
                
                r_txn.kind    = R_TXN;
                r_txn.r_id    = vif.mon_cb.RID;
                r_txn.r_data.push_back ( vif.mon_cb.RDATA );
                r_txn.r_resp.push_back ( rsp_e'(vif.mon_cb.RRESP) );
                r_txn.r_last = vif.mon_cb.RLAST;

                `uvm_info(
                    "monitor_r_channel",
                    $sformatf("ID=0x%h, Data=0x%h, Last=%0d", r_txn.r_id, vif.mon_cb.RDATA, r_txn.r_last),
                    UVM_DEBUG
                )

                // ap.write(r_txn);
                txn_q.push_back(r_txn);
            end
            wait_clk(1);
        end
    endtask : monitor_r_channel

endclass

`endif
