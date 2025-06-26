`ifndef AXI_MASTER_DRIVER_SV
`define AXI_MASTER_DRIVER_SV

class axi_master_driver extends axi_driver_base;
    `uvm_component_utils(axi_master_driver)

    bit[7:0]                w_len;  // 0-based

    function new (string name = "axi_master_driver");
        super.new(name);
    endfunction

    function build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task drive_item ( axi_seq_item txn );
        @ ( posedge vif.ACLK);
        case ( txn.kind )
            AW_TXN: begin
                vif.AWVALID <= 1;
                vif.AWID    <= txn.id;
                vif.AWADDR  <= txn.addr;
                vif.AWLEN   <= txn.len;
                vif.AWSIZE  <= txn.size;
                vif.AWBURST <= txn.burst;
                vif.AWPROT  <= txn.prot;
                w_len       <= txn.len;  // For W Channel
                do @(posedge vif.ACLK); while ( vif.AWREADY === 1'b0 );
                reset_aw_signal();
            end

            W_TXN: begin
                for ( int i=0; i<=w_len; i+=1 ) begin
                    vif.WVALID  <= 1;
                    vif.WID     <= txn.id;
                    vif.WDATA   <= txn.w_data[i];
                    vif.WSTRB   <= txn.w_strb[i];
                    vif.WLAST   <= (i == w_len);
                    do @(posedge vif.ACLK); while ( vif.WREADY === 1'b0 );
                end
                reset_w_signal();
            end

            B_TXN: begin
                vif.BREADY  <= 1;
                do @(posedge vif.ACLK); while ( vif.BVALID === 1'b0 );
                txn.id      <= vif.BID;
                txn.w_rsp   <= vif.BRESP;
                do @(posedge vif.ACLK); while ( vif.BVALID === 1'b1 );
                reset_b_signal();
            end

            AR_TXN: begin
                vif.ARVALID <= 1;
                vif.ARID    <= txn.id;
                vif.ARADDR  <= txn.addr;
                vif.ARLEN   <= txn.len;
                vif.ARSIZE  <= txn.size;
                vif.ARBURST <= txn.burst;
                vif.ARPROT  <= txn.prot;
                do @(posedge vif.ACLK); while ( vif.ARREADY === 1'b0 );
                reset_ar_signal();
            end

            R_TXN: begin
                vif.RREADY      <= 1;
                do @(posedge vif.ACLK); while ( vif.RVALID === 1'b0 );
                do begin
                    @(posedge vif.ACLK);
                    if ( vif.RVALID === 1'b1 ) begin
                        txn.id      <= vif.RID;
                        txn.r_data.push_back(vif.RDATA);
                        txn.r_rsp.push_back(vif.RRESP);
                    end
                end while ( vif.RLAST === 1'b0 );
                reset_r_signal();
            end

            default: begin
                `uvm_error("DRV", $sformatf("Unsupported txn.kind: %s", txn.kind.name()));
            end
        endcase
    endtask : drive_item

endclass : axi_master_driver

`endif