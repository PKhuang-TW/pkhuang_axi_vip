`ifndef AXI_RAND_RW_TEST_SV
`define AXI_RAND_RW_TEST_SV

class axi_rand_rw_test extends uvm_test;
    `uvm_component_utils(axi_rand_rw_test)

    axi_env             env;
    axi_rand_rw_seq     rand_rw_seq;

    function new ( string name = "axi_rand_rw_test", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        env = axi_env :: type_id :: create ("env", this);
    endfunction

    virtual task run_phase ( uvm_phase phase );
        phase.raise_objection(this);
        rand_rw_seq = axi_rand_rw_seq :: type_id :: create ("rand_rw_seq");
        rand_rw_seq.start ( env.agt_mst.seqr );
        phase.drop_objection(this);
    endtask

    function void end_of_elaboration_phase (uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
        uvm_factory::get().print();
    endfunction

endclass

`endif
