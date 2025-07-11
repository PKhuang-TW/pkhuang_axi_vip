`ifndef AXI_SLAVE_MONITOR_SV
`define AXI_SLAVE_MONITOR_SV

class axi_slave_monitor extends axi_monitor_base;
    `uvm_component_utils(axi_slave_monitor)

    function new ( string name="axi_slave_monitor", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase (uvm_phase phase);
        fork
            monitor_aw_channel();
            monitor_w_channel();
            monitor_b_channel();
            monitor_ar_channel();
            monitor_r_channel();
        join_none
    endtask

    virtual task monitor_aw_channel();
        forever begin
            @ ( posedge vif.mon_cb.AWVALID );
            txn = axi_seq_item :: type_id :: create("txn");
            txn.kind        = AW_TXN;
            txn.aw_id       = vif.mon_cb.AWID;
            txn.aw_addr     = vif.mon_cb.AWADDR;
            txn.aw_len      = vif.mon_cb.AWLEN;
            txn.aw_size     = vif.mon_cb.AWSIZE;
            $cast ( txn.aw_burst, vif.mon_cb.AWBURST );
            txn.aw_prot     = vif.mon_cb.AWPROT;
            // ap.write(txn);
        end
    endtask : monitor_aw_channel

    virtual task monitor_w_channel();
        forever begin
            @ ( posedge vif.mon_cb.WVALID );
            txn = axi_seq_item :: type_id :: create("txn");
            txn.kind    = W_TXN;
            txn.w_id    = vif.mon_cb.WID;
            do begin
                txn.w_data.push_back ( vif.mon_cb.WDATA );
                txn.w_strb.push_back ( vif.mon_cb.WSTRB );
                txn.w_last = vif.mon_cb.WLAST;
                @ ( posedge vif.mon_cb.ACLK );
            end while ( !vif.mon_cb.WLAST );
            // ap.write(txn);
        end
    endtask : monitor_w_channel

    virtual task monitor_b_channel();
        forever begin
            @ ( posedge vif.mon_cb.BVALID );
            txn = axi_seq_item :: type_id :: create("txn");
            txn.kind    = B_TXN;
            txn.b_id    = vif.mon_cb.BID;
            $cast  ( txn.b_resp, vif.mon_cb.BRESP );
            // ap.write(txn);
        end
    endtask : monitor_b_channel

    virtual task monitor_ar_channel();
        forever begin
            @ ( posedge vif.mon_cb.ARVALID );
            txn = axi_seq_item :: type_id :: create("txn");
            txn.kind        = AR_TXN;
            txn.ar_id       = vif.mon_cb.ARID;
            txn.ar_addr     = vif.mon_cb.ARADDR;
            txn.ar_len      = vif.mon_cb.ARLEN;
            txn.ar_size     = vif.mon_cb.ARSIZE;
            $cast  ( txn.ar_burst, vif.mon_cb.ARBURST );
            txn.ar_prot     = vif.mon_cb.ARPROT;
            // ap.write(txn);
        end
    endtask : monitor_ar_channel

    virtual task monitor_r_channel();
        forever begin
            @ ( posedge vif.mon_cb.RVALID );
            txn = axi_seq_item :: type_id :: create("txn");
            txn.kind    = R_TXN;
            txn.r_id    = vif.mon_cb.RID;
            do begin
                txn.r_data.push_back ( vif.mon_cb.RDATA );
                txn.r_resp.push_back ( rsp_e'(vif.mon_cb.RRESP) );
                txn.r_last = vif.mon_cb.RLAST;
                @ ( posedge vif.mon_cb.ACLK );
            end while ( !vif.mon_cb.RLAST );
            // ap.write(txn);
        end
    endtask : monitor_r_channel

endclass

`endif