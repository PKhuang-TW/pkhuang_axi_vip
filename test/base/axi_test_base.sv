`ifndef AXI_BASIC_TEST_SV
`define AXI_BASIC_TEST_SV

class axi_test_base extends uvm_test;
    `uvm_component_utils(axi_test_base)

    axi_env             env;

    axi_slv_wr_seq      slv_wr_seq;

    function new ( string name = "axi_test_base", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        env = axi_env :: type_id :: create ("env", this);
    endfunction

    function void end_of_elaboration_phase (uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
        uvm_factory::get().print();
    endfunction

    virtual task run_phase ( uvm_phase phase );
        phase.raise_objection(this);
        slv_wr_seq = axi_slv_wr_seq :: type_id :: create ("slv_wr_seq");
        slv_wr_seq.start ( env.vseqr.seqr_slv );
        phase.drop_objection(this);
    endtask

endclass

`endif