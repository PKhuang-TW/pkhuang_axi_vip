`ifndef AXI_VSEQ_BASE_SV
`define AXI_VSEQ_BASE_SV

class axi_vseq_base extends uvm_sequence;
    `uvm_object_utils(axi_vseq_base)

    `uvm_declare_p_sequencer(axi_virtual_sequencer)

    rand int            seq_num;

    constraint num_cns {
        soft seq_num inside {[1:10]};
    }
    
    function new(string name = "axi_vseq_base");
        super.new(name);
    endfunction

endclass

`endif