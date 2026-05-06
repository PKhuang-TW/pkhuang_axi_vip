`ifndef AXI_SLAVE_SEQUENCER_SV
`define AXI_SLAVE_SEQUENCER_SV

class axi_slave_sequencer extends axi_seqr_base;
    `uvm_component_utils(axi_slave_sequencer)

    uvm_tlm_analysis_fifo #(axi_seq_item)   aw_fifo, w_fifo;

    function new ( string name = "axi_slave_sequencer", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase ( uvm_phase phase );
        super.build_phase(phase);
        aw_fifo = new("aw_fifo", this);
        w_fifo = new("w_fifo", this);
    endfunction
    
endclass

`endif