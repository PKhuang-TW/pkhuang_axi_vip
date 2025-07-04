`ifndef AXI_DRIVER_BASE_SV
`define AXI_DRIVER_BASE_SV

class axi_driver_base extends uvm_driver #(axi_seq_item);
    `uvm_component_utils(axi_driver_base)

    axi_seq_item            txn;
    virtual axi_if          vif;

    function new ( string name = "axi_driver_base", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        if ( !uvm_config_db #(virtual axi_if) :: get (this, "", "vif", vif) )
            `uvm_error("NOCFG", $sformatf("No vif is set for %s.vif", get_full_name()) )

        reset_axi_signal();
    endfunction

    extern virtual task reset_aw_signal();
    extern virtual task reset_w_signal();
    extern virtual task reset_b_signal();
    extern virtual task reset_ar_signal();
    extern virtual task reset_r_signal();

    extern virtual task reset_axi_signal();

endclass : axi_driver_base

virtual task axi_driver_base::reset_aw_signal();
    vif.AWID    <= 0;
    vif.AWADDR  <= 0;
    vif.AWLEN   <= 0;
    vif.AWSIZE  <= 0;
    vif.AWBURST <= 0;
    vif.AWPROT  <= 0;
    vif.AWVALID <= 0;
endtask : reset_aw_signal

virtual task axi_driver_base::reset_w_signal();
    vif.WID     <= 0;
    vif.WDATA   <= 0;
    vif.WSTRB   <= 0;
    vif.WLAST   <= 0;
    vif.WVALID  <= 0;
endtask : reset_w_signal

virtual task axi_driver_base::reset_b_signal();
    vif.BID     <= 0;
    vif.BREADY  <= 0;
endtask : reset_b_signal

virtual task axi_driver_base::reset_ar_signal();
    vif.ARID    <= 0;
    vif.ARADDR  <= 0;
    vif.ARLEN   <= 0;
    vif.ARSIZE  <= 0;
    vif.ARBURST <= 0;
    vif.ARPROT  <= 0;
    vif.ARVALID <= 0;
endtask : reset_ar_signal

virtual task axi_driver_base::reset_r_signal();
    vif.RID     <= 0;
    vif.RREADY  <= 0;
endtask : reset_r_signal

virtual task axi_driver_base::reset_axi_signal();
    reset_aw_signal();
    reset_w_signal();
    reset_b_signal();
    reset_ar_signal();
    reset_r_signal();
endtask : reset_axi_signal

`endif