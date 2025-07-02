`ifndef AXI_MASTER_DRIVER_SV
`define AXI_MASTER_DRIVER_SV

class axi_master_driver extends axi_driver_base;
    `uvm_component_utils(axi_master_driver)

    function new (string name = "axi_master_driver");
        super.new(name);
    endfunction

    function build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual task run_phase ( uvm_phase phase );
        forever begin
            @ ( posedge vif.ACLK );
            if ( !vif.ARESETn ) begin
                reset_axi_signal();
            end else begin
                txn = axi_seq_item :: type_id :: create ("txn");
                seq_item_port.start_item(txn);
                drive_item(txn);
                seq_item_port.item_done();
            end
        end
    endtask

    virtual task drive_item ( axi_seq_item txn );
        @ ( posedge vif.ACLK);
        
        case ( txn.kind )
            AW_TXN: begin

                // AW Channel
                vif.AWVALID <= 1;
                vif.AWID    <= txn.w_id;
                vif.AWADDR  <= txn.w_addr;
                vif.AWLEN   <= txn.w_len;
                vif.AWSIZE  <= txn.w_size;
                vif.AWBURST <= txn.w_burst;
                vif.AWPROT  <= txn.w_prot;

                @ ( posedge vif.ACLK );
                wait ( vif.AWREADY );
                reset_aw_signal();

                // W Channel
                for ( int i=0; i<=txn.w_len; i++ ) begin
                    vif.WVALID  <= 1;
                    vif.WID     <= txn.w_id;
                    vif.WDATA   <= txn.w_data[i];
                    vif.WSTRB   <= txn.w_strb[i];

                    if ( i == txn.wlen )
                        vif.WLAST <= 1;
                    @ ( posedge vif.ACLK );
                    wait ( vif.WREADY );
                end
                reset_w_signal();

                // B Channel
                vif.BREADY  <= 1;
                @ ( posedge vif.ACLK );
                wait ( vif.BVALID );
                vif.BREADY  <= 0;
                reset_b_signal();
            end

            AR_TXN: begin

                // AR Channel
                vif.ARVALID <= 1;
                vif.ARID    <= txn.r_id;
                vif.ARADDR  <= txn.r_addr;
                vif.ARLEN   <= txn.r_len;
                vif.ARSIZE  <= txn.r_size;
                vif.ARBURST <= txn.r_burst;
                vif.ARPROT  <= txn.r_prot;
                @  (posedge vif.ACLK );
                wait ( vif.ARREADY );
                reset_ar_signal();

                // R Channel
                vif.RREADY  <= 1;
                @ ( posedge vif.ACLK );
                wait ( vif.RREADY );
                vif.RREADY  <= 0;
                reset_r_signal();
            end

            default: begin
                `uvm_error("DRV", $sformatf("Unsupported txn.kind: %s", txn.kind.name()));
            end
        endcase
    endtask : drive_item

endclass : axi_master_driver

`endif