`ifndef AXI_BASIC_TEST_SV
`define AXI_BASIC_TEST_SV

class axi_test_base extends uvm_test;
    `uvm_component_utils(axi_test_base)

    axi_env         env;

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

endclass

`endif