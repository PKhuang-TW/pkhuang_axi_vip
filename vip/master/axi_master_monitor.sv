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
            monitor_aw_channel();
            monitor_w_channel();
            monitor_b_channel();
            monitor_ar_channel();
            monitor_r_channel();
        join
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
            txn.aw_burst    = vif.AWBURST;
            txn.aw_prot     = vif.AWPROT;
            ap.write(txn);
        end
    endtask : monitor_aw_channel

    virtual task monitor_w_channel();
        forever begin
            @ ( posedge vif.WVALID );
            txn = axi_seq_item :: type_id :: create("txn");
            txn.kind    = W_TXN;
            txn.w_id    = vif.WID;
            txn.w_data  = vif.WDATA;
            txn.w_strb  = vif.WSTRB;
            txn.w_last  = vif.WLAST;
            ap.write(txn);
        end
    endtask : monitor_w_channel

    virtual task monitor_b_channel();
        forever begin
            @ ( posedge vif.BVALID );
            txn = axi_seq_item :: type_id :: create("txn");
            txn.kind    = B_TXN;
            txn.b_id    = vif.BID;
            txn.b_resp  = vif.BRESP;
            ap.write(txn);
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
            txn.ar_burst    = vif.ARBURST;
            txn.ar_prot     = vif.ARPROT;
            ap.write(txn);
        end
    endtask : monitor_ar_channel

    virtual task monitor_r_channel();
        forever begin
            @ ( posedge vif.RVALID );
            txn = axi_seq_item :: type_id :: create("txn");
            txn.kind    = R_TXN;
            txn.r_id    = vif.RID;
            txn.r_data  = vif.RDATA;
            txn.r_resp  = vif.RRESP;
            txn.r_last  = vif.RLAST;
            ap.write(txn);
        end
    endtask : monitor_r_channel

endclass

`endif