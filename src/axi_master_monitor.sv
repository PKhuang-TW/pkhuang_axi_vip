`ifndef AXI_MASTER_MONITOR_SV
`define AXI_MASTER_MONITOR_SV

class axi_master_monitor #(
    type TXN = axi_transfer  
) extends uvm_monitor;
    `uvm_component_param_utils(axi_master_monitor#(TXN))

    virtual axi_interface       vif;
    axi_config #(TXN)           cfg;

    TXN                         pending_writes[int], pending_reads[int];

    uvm_analysis_port #(TXN)    ap_axi_write, ap_axi_read;

    function new (string name="axi_master_monitor");
        super.new();
        ap_axi_write    = new("ap_axi_write", this);
        ap_axi_read     = new("ap_axi_read", this);
    endfunction

    function build_phase (uvm_phase phase);
        super.build_phase(phase);

        if ( !uvm_config_db #(axi_config #(TXN)) :: get (this, "", "mst_cfg", cfg) )
            `uvm_error("NOCFG", "No master config is set for: ", get_full_name(), ".cfg")

        vif = cfg.vif;
    endfunction

    function run_phase (uvm_phase phase);
        super.run_phase(phase);
        fork
            monitor_aw_channel();
            monitor_w_channel();
            monitor_b_channel();
            monitor_ar_channel();
            monitor_r_channel();
        join
    endfunction

    extern virtual task monitor_aw_channel();
    extern virtual task monitor_w_channel();
    extern virtual task monitor_b_channel();
    extern virtual task monitor_ar_channel();
    extern virtual task monitor_r_channel();
    
endclass

task axi_master_monitor::monitor_aw_channel();
    TXN txn;

    forever begin
        @(posedge vif.ACLK iff (vif.AWVALID == 1 && vif.AWREADY == 1) );
        `uvm_info ( get_full_name(), "Write Address Transaction Detected!", UVM_LOW )
        txn = TXN::type_id::create("txn");
        txn.kind    = AW_TXN;
        txn.id      = vif.AWID;
        txn.addr    = vif.AWADDR;
        txn.len     = vif.AWLEN;
        txn.size    = vif.AWSIZE;
        txn.burst   = vif.AWBURST;
        txn.prot    = vif.AWPROT;

        if ( pending_writes.exists(txn.id) )
            `uvm_warning ( get_full_name(), "AW: Overwriting pending writes ID = %0d.", vif.AWID )
        
        pending_writes[txn.id] = txn;
        pending_writes[txn.id].print();
    end
endtask : monitor_aw_channel

task axi_master_monitor::monitor_w_channel();
    TXN txn;

    forever begin
        @(posedge vif.ACLK iff (vif.WVALID == 1 && vif.WREADY == 1) );
        `uvm_info ( get_full_name(), "Write Data Transaction Detected!", UVM_LOW )

        if ( pending_writes.exists(vif.WID) ) begin
            txn         = pending_writes[vif.WID];
            txn.kind    = W_TXN;
            txn.id      = vif.WID;
            txn.print();
        end else begin
            `uvm_warning ( get_full_name(), "W: Unknown ID = %0d", vif.WID, "received, data ignored." )
        end
    end
endtask : monitor_w_channel

task axi_master_monitor::monitor_b_channel();
    TXN txn;

    forever begin
        @(posedge vif.ACLK iff (vif.BVALID == 1 && vif.BREADY == 1) );
        `uvm_info ( get_full_name(), "Write Response Transaction Detected!", UVM_LOW )

        if ( pending_writes.exists(vif.BID) ) begin
            txn         = pending_writes[vif.BID];
            txn.kind    = B_TXN;
            txn.id      = vif.BID;
            txn.BRESP   = vif.BRESP;
            txn.print();
            ap_axi_write.write(txn);
            pending_writes.delete ( txn.id );
        end else begin
            `uvm_warning ( get_full_name(), "B: Unknown ID = %0d", vif.BID, "received, response ignored." )
        end
    end
endtask : monitor_b_channel

task axi_master_monitor::monitor_ar_channel();
    TXN txn;

    forever begin
        @(posedge vif.ACLK iff (vif.ARVALID == 1 && vif.ARREADY == 1) );
        `uvm_info ( get_full_name(), "Read Address Transaction Detected!", UVM_LOW )
        txn = TXN::type_id::create("txn");
        txn.kind    = AR_TXN;
        txn.id      = vif.ARID;
        txn.addr    = vif.ARADDR;
        txn.len     = vif.ARLEN;
        txn.size    = vif.ARSIZE;
        txn.burst   = vif.ARBURST;
        txn.prot    = vif.ARPROT;

        if ( pending_reads.exists(txn.id) )
            `uvm_warning ( get_full_name(), "AR: Overwriting pending reads ID = %0d.", vif.ARID )
        
        pending_reads[txn.id] = txn;
        pending_reads[txn.id].print();
    end
endtask : monitor_ar_channel

task axi_master_monitor::monitor_r_channel();
    TXN txn;

    forever begin
        @(posedge vif.ACLK iff (vif.RVALID == 1 && vif.RREADY == 1) );
        `uvm_info ( get_full_name(), "Read Data Transaction Detected!", UVM_LOW )

        if ( pending_reads.exists(vif.RID) ) begin
            txn         = pending_reads[vif.RID];
            txn.kind    = R_TXN;
            txn.id      = vif.RID;
            txn.RRESP   = vif.RRESP;
            txn.RLAST   = vif.RLAST;
            txn.r_data.push_back(vif.RDATA);
            txn.print();

            if ( vif.RLAST ) begin
                ap_axi_read.write(txn);
                pending_reads.delete ( txn.id );
            end
        end else begin
            `uvm_warning ( get_full_name(), "R: Unknown ID = %0d", vif.RID, "received, response ignored." )
        end
    end
endtask : monitor_r_channel

`endif