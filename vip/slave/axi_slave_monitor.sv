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
            @ ( posedge vif.AWVALID );
            txn = axi_seq_item :: type_id :: create("txn");
            txn.kind        = AW_TXN;
            txn.aw_id       = vif.AWID;
            txn.aw_addr     = vif.AWADDR;
            txn.aw_len      = vif.AWLEN;
            txn.aw_size     = vif.AWSIZE;
            $cast ( txn.aw_burst, vif.AWBURST );
            txn.aw_prot     = vif.AWPROT;
            // ap.write(txn);
        end
    endtask : monitor_aw_channel

    virtual task monitor_w_channel();
        forever begin
            @ ( posedge vif.WVALID );
            txn = axi_seq_item :: type_id :: create("txn");
            txn.kind    = W_TXN;
            txn.w_id    = vif.WID;
            do begin
                txn.w_data.push_back ( vif.WDATA );
                txn.w_strb.push_back ( vif.WSTRB );
                txn.w_last = vif.WLAST;
                @ ( posedge vif.ACLK );
            end while ( !vif.WLAST );
            // ap.write(txn);
        end
    endtask : monitor_w_channel

    virtual task monitor_b_channel();
        forever begin
            @ ( posedge vif.BVALID );
            txn = axi_seq_item :: type_id :: create("txn");
            txn.kind    = B_TXN;
            txn.b_id    = vif.BID;
            $cast  ( txn.b_resp, vif.BRESP );
            // ap.write(txn);
        end
    endtask : monitor_b_channel

    virtual task monitor_ar_channel();
        forever begin
            @ ( posedge vif.ARVALID );
            txn = axi_seq_item :: type_id :: create("txn");
            txn.kind        = AR_TXN;
            txn.ar_id       = vif.ARID;
            txn.ar_addr     = vif.ARADDR;
            txn.ar_len      = vif.ARLEN;
            txn.ar_size     = vif.ARSIZE;
            $cast  ( txn.ar_burst, vif.ARBURST );
            txn.ar_prot     = vif.ARPROT;
            // ap.write(txn);
        end
    endtask : monitor_ar_channel

    virtual task monitor_r_channel();
        forever begin
            @ ( posedge vif.RVALID );
            txn = axi_seq_item :: type_id :: create("txn");
            txn.kind    = R_TXN;
            txn.r_id    = vif.RID;
            do begin
                txn.r_data.push_back ( vif.RDATA );
                txn.r_resp.push_back ( rsp_e'(vif.RRESP) );
                txn.r_last = vif.RLAST;
                @ ( posedge vif.ACLK );
            end while ( !vif.RLAST );
            // ap.write(txn);
        end
    endtask : monitor_r_channel

endclass

`endif
