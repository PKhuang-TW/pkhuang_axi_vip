`ifndef AXI_MASTER_DRIVER_SV
`define AXI_MASTER_DRIVER_SV

class axi_master_driver #(
    type TXN = axi_transfer
) extends uvm_driver;
    `uvm_component_param_utils(axi_master_driver#(TXN))

    axi_config #(TXN)       cfg;
    virtual axi_interface   vif;

    bit[7:0]                w_len, r_len;  // 0-based

    function new (string name = "axi_master_driver");
        super.new(name);
    endfunction

    function build_phase (uvm_phase phase);
        super.build_phase(phase);

        if ( !uvm_config_db #(axi_config#(TXN)) :: get (this, "", "mst_cfg", cfg) )
            `uvm_error("NOCFG", "No master config is set for ", get_full_name(), ".cfg")
        vif = cfg.vif;
    endfunction

    virtual task run_phase ( uvm_phase phase );
        forever begin
            seq_item_port.get_next_item(req);
            $cast(rsp, req.clone());
            drive_item(rsp);
            seq_item_port.item_done();

            // Put response to avoid if the req has some problem
            seq_item_port.put_response(rsp);
        end        
    endtask

    extern virtual task drive_item(TXN txn);

endclass : axi_master_driver

virtual task axi_master_driver::drive_item ( TXN txn );
    case ( txn.kind )
        AW_TXN: begin
            vif.AWVALID <= 1;
            @(posedge vif.AWREADY);

            vif.AWID    <= txn.id;
            vif.AWADDR  <= txn.addr;
            vif.AWLEN   <= txn.len;
            vif.AWSIZE  <= txn.size;
            vif.AWBURST <= txn.burst;
            vif.AWPROT  <= txn.prot;

            while ( vif.AWREADY !== 0 )
                @(posedge vif.ACLK);
            w_len = txn.len;
            reset_aw_signal();  // TODO
        end

        W_TXN: begin
            vif.WVALID <= 1;
            @(posedge vif.WREADY);

            for ( int i=0; i<=w_len; i+=1 ) begin
                vif.WVALID  <= 1;
                vif.WID     <= txn.id;
                vif.WDATA   <= txn.w_data[i];
                vif.WSTRB   <= txn.w_strb[i];

                if ( i == w_len )
                    vif.WLAST   <= 1;
                @(posedge vif.ACLK);
            end

            while ( vif.WREADY !== 0 )
                @(posedge vif.ACLK);
            reset_w_signal();  // TODO
        end

        B_TXN: begin
            vif.BREADY  <= 1;
            @(posedge vif.BVALID);

            txn.id      <= vif.BID;
            txn.w_rsp   <= vif.BRESP;

            while ( vif.BREADY !== 0 )
                @(posedge vif.ACLK);
            reset_b_signal();  // TODO
        end

        AR_TXN: begin
            @(posedge vif.ARREADY);
            vif.ARVALID <= 1;
            vif.ARID    <= txn.id;
            vif.ARADDR  <= txn.addr;
            vif.ARLEN   <= txn.len;
            vif.ARSIZE  <= txn.size;
            vif.ARBURST <= txn.burst;
            vif.ARPROT  <= txn.prot;

            while ( vif.ARREADY !== 0 )
                @(posedge vif.ACLK);
            r_len = txn.len;
            reset_ar_signal();  // TODO
        end

        R_TXN: begin
            vif.RREADY  <= 1;
            @(posedge vif.RVALID);

            for ( int i=0; i<= r_len; i+=1 ) begin
                txn.id          <= vif.RID;
                txn.r_data[i]   <= vif.RDATA;
                txn.r_rsp[i]    <= vif.RRESP;
                txn.r_strb[i]   <= vif.RSTRB;
                @(posedge vif.ACLK);
            end

            while ( vif.RREADY !== 0 )
                @(posedge vif.ACLK);
            reset_w_signal();  // TODO
        end
    endcase
endtask : drive_item

`endif