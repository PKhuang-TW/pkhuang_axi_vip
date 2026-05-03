`ifndef AXI_SLAVE_SEQUENCER_SV
`define AXI_SLAVE_SEQUENCER_SV

class axi_slave_sequencer extends uvm_sequencer #(axi_seq_item);
    `uvm_component_utils(axi_slave_sequencer)

    function new ( string name = "axi_slave_sequencer", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase ( uvm_phase phase );
        super.build_phase(phase);
    endfunction
    
endclass

`endif