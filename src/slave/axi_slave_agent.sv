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

        axi_monitor_base::type_id::set_inst_override(
            axi_slave_monitor::get_type(),
            "*agt_slv.*"
        );

        uvm_sequencer#(axi_seq_item)::type_id::set_inst_override(
            axi_slave_sequencer::get_type(),
            "*agt_slv.*"
        );

        super.build_phase(phase);
    endfunction
endclass

`endif