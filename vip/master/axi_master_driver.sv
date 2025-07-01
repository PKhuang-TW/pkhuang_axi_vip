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

    virtual task drive_item ( axi_seq_item txn );
        @ ( posedge vif.ACLK);
        
        case ( txn.kind )
            AW_TXN: begin

                // AW
                vif.AWVALID <= 1;
                vif.AWID    <= txn.w_id;
                vif.AWADDR  <= txn.w_addr;
                vif.AWLEN   <= txn.w_len;
                vif.AWSIZE  <= txn.w_size;
                vif.AWBURST <= txn.w_burst;
                vif.AWPROT  <= txn.w_prot;

                @ ( posedge vif.ACLK );
                wait ( vif.AWREADY );

                // W
                vif.WVALID  <= 1;
                vif.WID     <= txn.w_id;

                for ( int i=0; i<=txn.w_len; i++ ) begin
                    vif.WDATA   <= txn.w_data[i];
                    vif.WSTRB   <= txn.w_strb[i];

                    if ( i == txn.wlen )
                        vif.WLAST <= 1;
                    @ ( posedge vif.ACLK );
                end
                wait ( vif.WREADY );

                // B
                vif.BREADY  <= 1;
                @ ( posedge vif.ACLK );
                wait ( vif.BVALID );
                vif.BREADY  <= 0;

                reset_axi_signal();
            end

            // AR_TXN: begin
            //     vif.ARVALID <= 1;
            //     vif.ARID    <= txn.id;
            //     vif.ARADDR  <= txn.addr;
            //     vif.ARLEN   <= txn.len;
            //     vif.ARSIZE  <= txn.size;
            //     vif.ARBURST <= txn.burst;
            //     vif.ARPROT  <= txn.prot;
            //     do @(posedge vif.ACLK); while ( vif.ARREADY === 1'b0 );
            //     reset_ar_signal();
            // end

            default: begin
                `uvm_error("DRV", $sformatf("Unsupported txn.kind: %s", txn.kind.name()));
            end
        endcase
    endtask : drive_item

endclass : axi_master_driver

`endif