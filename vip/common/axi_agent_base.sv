`ifndef AXI_AGENT_BASE_SV
`define AXI_AGENT_BASE_SV

class axi_agent_base #(
    type TXN    = axi_transfer
) extends uvm_agent;
    `uvm_component_param_utils(axi_agent_base#(TXN))

    axi_driver_base     #(TXN)  drv;
    axi_monitor_base    #(TXN)  mon;
    // axi_sequencer       #(TXN)  seqr;  // TODO

    function new (string name = "axi_agent_base");
        super.new(name);
    endfunction

    function build_phase (uvm_phase phase);
        super.build_phase(phase);

        drv =   axi_driver_base #(TXN)  :: type_id :: create ("drv", this);
        mon =   axi_monitor_base #(TXN) :: type_id :: create ("mon", this);
        // seqr =  axi_sequencer #(TXN)    :: type_id :: create ("seqr", this);  // TODO
    endfunction

    function connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect ( seqr.seq_item_export );
    endfunction

endclass

`endif