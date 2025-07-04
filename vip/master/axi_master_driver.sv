`ifndef AXI_MASTER_DRIVER_SV
`define AXI_MASTER_DRIVER_SV

class axi_master_driver extends axi_driver_base;
    `uvm_component_utils(axi_master_driver)

    axi_master_bfm      mst_bfm;

    function new ( string name = "axi_master_driver", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        // if ( !uvm_config_db #(virtual axi_if.mst_if) :: get (this, "", "vif.mst_if", vif) )
        //     `uvm_error("NOCFG", $sformatf("No vif is set for %s.vif", get_full_name()) )

        mst_bfm = new( .vif(vif.mst_if) );
    endfunction

    virtual task run_phase ( uvm_phase phase );
        forever begin
            @ ( posedge vif.ACLK );
            if ( !vif.ARESETn ) begin
                mst_bfm.reset_axi_signal();
            end else begin
                txn = axi_seq_item :: type_id :: create ("txn");
                seq_item_port.get_next_item(txn);
                case ( txn.kind )
                    AW_TXN: begin
                        mst_bfm.drive_aw_txn(txn);
                        mst_bfm.drive_w_txn(txn);
                        mst_bfm.drive_b_txn(txn);
                    end

                    AR_TXN: begin
                        mst_bfm.drive_ar_txn(txn);
                        mst_bfm.drive_r_txn(txn);
                    end
                    
                    default: begin
                        `uvm_error("DRV", $sformatf("Unsupported txn.kind: %s", txn.kind.name()));
                    end
                endcase                
                seq_item_port.item_done();
            end
        end
    endtask

endclass : axi_master_driver

`endif