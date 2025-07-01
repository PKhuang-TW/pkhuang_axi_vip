`ifndef AXI_AGENT_BASE_SV
`define AXI_AGENT_BASE_SV

class axi_agent_base extends uvm_agent;
    `uvm_component_utils(axi_agent_base)

    axi_driver_base                 drv;
    axi_monitor_base                mon;
    uvm_sequencer #(axi_seq_item)   seqr;

    function new (string name = "axi_agent_base");
        super.new(name);
    endfunction

    function build_phase (uvm_phase phase);
        super.build_phase(phase);

        drv =   axi_driver_base :: type_id :: create ("drv", this);
        mon =   axi_monitor_base :: type_id :: create ("mon", this);
        seqr =  uvm_sequencer #(axi_seq_item) :: type_id :: create ("seqr", this);
    endfunction

    function connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect ( seqr.seq_item_export );
    endfunction

endclass

`endif