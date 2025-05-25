`ifndef AXI_MASTER_DRIVER_SV
`define AXI_MASTER_DRIVER_SV

class axi_master_driver #(
    type TXN = axi_transfer
) extends uvm_driver;
    `uvm_component_utils(axi_master_driver)

    function new (string name = "axi_master_driver");
        super.new(name);
    endfunction

    virtual task run_phase ( uvm_phase phase );
        super.run_phase(phase);
        
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
    // TODO
virtual task axi_master_driver::drive_item ( TXN txn );

endtask : drive_item

`endif