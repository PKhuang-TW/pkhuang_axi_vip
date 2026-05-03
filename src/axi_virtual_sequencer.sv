`ifndef AXI_VIRTUAL_SEQUENCER_SV
`define AXI_VIRTUAL_SEQUENCER_SV

class axi_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(axi_virtual_sequencer)
    
    axi_master_sequencer    seqr_mst;
    axi_slave_sequencer     seqr_slv;

    function new ( string name = "axi_virtual_sequencer", uvm_component parent );
        super.new(name, parent);
    endfunction

    function build_phase ( uvm_phase phase );
        super.build_phase(phase);
        seqr_mst = axi_master_sequencer :: type_id :: create ("seqr_mst", this);
        seqr_slv = axi_slave_sequencer :: type_id :: create ("seqr_slv", this);
    endfunction
    
endclass

`endif