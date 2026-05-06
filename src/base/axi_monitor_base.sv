`ifndef AXI_MONITOR_BASE_SV
`define AXI_MONITOR_BASE_SV

class axi_monitor_base extends uvm_monitor;
    `uvm_component_utils(axi_monitor_base)

    axi_seq_item                        txn;
    virtual axi_if                      vif;
    axi_seq_item                        txn_q[$];

    uvm_analysis_port #(axi_seq_item)   aw_ap, w_ap, b_ap, ar_ap, r_ap;

    function new ( string name="axi_monitor_base", uvm_component parent );
        super.new(name, parent);
        aw_ap = new("aw_ap", this);
        w_ap = new("w_ap", this);
        b_ap = new("b_ap", this);
        ar_ap = new("ar_ap", this);
        r_ap = new("r_ap", this);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction
    
    task wait_clk ( int cycle );
        repeat ( cycle ) @ ( vif.mon_cb );
    endtask

    virtual task run_phase (uvm_phase phase);
        fork
            forever begin monitor_aw_channel()  ;end
            forever begin monitor_w_channel()   ;end
            forever begin monitor_b_channel()   ;end
            forever begin monitor_ar_channel()  ;end
            forever begin monitor_r_channel()   ;end
        join
    endtask

    virtual task monitor_aw_channel();
        axi_seq_item    aw_txn;

        begin
            @ ( vif.mon_cb iff ( vif.mon_cb.AWVALID && vif.mon_cb.AWREADY ) );
            
            aw_txn = axi_seq_item :: type_id :: create("aw_txn");
            aw_txn.kind         = AW_TXN;
            aw_txn.aw_id        = vif.mon_cb.AWID;
            aw_txn.aw_addr      = vif.mon_cb.AWADDR;
            aw_txn.aw_len       = vif.mon_cb.AWLEN;
            aw_txn.aw_size      = vif.mon_cb.AWSIZE;
            $cast ( aw_txn.aw_burst, vif.mon_cb.AWBURST );
            aw_txn.aw_prot      = vif.mon_cb.AWPROT;

            aw_ap.write(aw_txn);

            `uvm_info (
                "monitor_mst_aw",
                $sformatf("Monitor AW Signal: ID = 0x%h", vif.mon_cb.AWID),
                UVM_MEDIUM
            )
        end
    endtask : monitor_aw_channel

    virtual task monitor_w_channel();
        axi_seq_item            w_txn;

        begin
            @ ( vif.mon_cb iff ( vif.mon_cb.WVALID && vif.mon_cb.WREADY ) );
            w_txn = axi_seq_item :: type_id :: create("w_txn");
            
            w_txn.kind = W_TXN;
            w_txn.w_id = vif.mon_cb.WID;

            forever begin
                @ ( vif.mon_cb iff vif.mon_cb.WVALID === 1'b1 );

                w_txn.w_data.push_back ( vif.mon_cb.WDATA );
                w_txn.w_strb.push_back ( vif.mon_cb.WSTRB );

                if ( vif.mon_cb.WLAST === 1'b1 ) break;
            end
            w_txn.w_last  = 1;
            w_ap.write(w_txn);
        end
    endtask : monitor_w_channel

    virtual task monitor_b_channel();
        axi_seq_item            b_txn;

        begin
            @ ( vif.mon_cb iff vif.mon_cb.BVALID === 1'b1 );
            
            b_txn = axi_seq_item :: type_id :: create("b_txn");
            b_txn.kind    = B_TXN;
            b_txn.b_id    = vif.mon_cb.BID;
            $cast ( b_txn.b_resp, vif.mon_cb.BRESP );

            b_ap.write(b_txn);
        end
    endtask : monitor_b_channel

    virtual task monitor_ar_channel();
        axi_seq_item            ar_txn;

        begin
            @ ( vif.mon_cb iff vif.mon_cb.ARVALID === 1'b1 );
            
            ar_txn = axi_seq_item :: type_id :: create("ar_txn");
            ar_txn.kind        = AR_TXN;
            ar_txn.ar_id       = vif.mon_cb.ARID;
            ar_txn.ar_addr     = vif.mon_cb.ARADDR;
            ar_txn.ar_len      = vif.mon_cb.ARLEN;
            ar_txn.ar_size     = vif.mon_cb.ARSIZE;
            $cast ( ar_txn.ar_burst, vif.mon_cb.ARBURST );
            ar_txn.ar_prot     = vif.mon_cb.ARPROT;

            ar_ap.write(ar_txn);
        end
    endtask : monitor_ar_channel

    virtual task monitor_r_channel();
        axi_seq_item            r_txn;

        begin
            @ ( vif.mon_cb iff vif.mon_cb.RVALID === 1'b1 );
            
            r_txn = axi_seq_item :: type_id :: create("r_txn");
            
            r_txn.kind    = R_TXN;
            r_txn.r_id    = vif.mon_cb.RID;
            r_txn.r_data.push_back ( vif.mon_cb.RDATA );
            r_txn.r_resp.push_back ( rsp_e'(vif.mon_cb.RRESP) );
            r_txn.r_last = vif.mon_cb.RLAST;

            `uvm_info(
                "monitor_r_channel",
                $sformatf("ID=0x%h, Data=0x%h, Last=%0d", r_txn.r_id, vif.mon_cb.RDATA, r_txn.r_last),
                UVM_MEDIUM
            )

            r_ap.write(r_txn);
        end
    endtask : monitor_r_channel
    
endclass

`endif