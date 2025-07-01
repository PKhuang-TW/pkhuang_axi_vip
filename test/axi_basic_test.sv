`ifndef AXI_BASIC_TEST_SV
`define AXI_BASIC_TEST_SV

class axi_basic_test extends uvm_test;
    `uvm_component_utils(axi_basic_test)

    axi_env     env;

    function new (string name = "axi_basic_test");
        super.new(name);
    endfunction

    function build_phase (uvm_phase phase);
        super.build_phase(phase);
        env = axi_env :: type_id :: create ("env", this);
    endfunction

    virtual task run_phase ( uvm_phase phase );
        phase.raise_objection(this);
        // TODO
        phase.drop_objection(this);
    endtask

endclass

`endif