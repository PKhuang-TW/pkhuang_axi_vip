`ifndef AXI_MASTER_VIRTUAL_SEQUENCER_SV
`define AXI_MASTER_VIRTUAL_SEQUENCER_SV

class axi_master_virtual_sequencer #(
    type TXN = axi_transfer
) extends uvm_sequencer;
    `uvm_component_utils(axi_master_virtual_sequencer)
    
    // TODO
    // The number of seqr depends on the number of seq
    // uvm_sequencer #(TXN)     seqr1;
    // uvm_sequencer #(TXN)     seqr2;
    // uvm_sequencer #(TXN)     seqr3;

    function new (string name = "axi_master_virtual_sequencer");
        super.new(name);
    endfunction

endclass : axi_master_virtual_sequencer

`endif