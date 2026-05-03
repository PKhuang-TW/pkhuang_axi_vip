`ifndef AXI_SLAVE_AGENT_SV
`define AXI_SLAVE_AGENT_SV

class axi_slave_agent extends axi_agent_base;
    `uvm_component_utils(axi_slave_agent)

    function new ( string name = "axi_slave_agent", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase ( uvm_phase phase );

        axi_driver_base::type_id::set_inst_override(
            axi_slave_driver::get_type(),
            "*agt_slv.*"
        );

        // axi_monitor_base::type_id::set_inst_override(
        //     axi_slave_monitor::get_type(),
        //     "*agt_slv.*"
        // );

        uvm_sequencer#(axi_seq_item)::type_id::set_inst_override(
            axi_slave_sequencer::get_type(),
            "seqr",
            this
        );

        super.build_phase(phase);
    endfunction

    virtual function void connect_phase ( uvm_phase phase );
        axi_slave_driver    slv_drv;
        axi_slave_sequencer slv_seqr;

        super.connect_phase(phase);

        $cast(slv_drv, drv);
        $cast(slv_seqr, seqr);

        slv_drv.aw_ap.connect ( slv_seqr.aw_fifo.analysis_export );
        slv_drv.w_ap.connect ( slv_seqr.w_fifo.analysis_export );
    endfunction
endclass

`endif