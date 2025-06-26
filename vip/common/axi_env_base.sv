`ifndef AXI_ENV_BASE_SV
`define AXI_ENV_BASE_SV

class axi_env_base extends uvm_env;
    `uvm_component_utils(axi_env_base)

    axi_agent_base      agt;

    function new (string name = "axi_env_base");
        super.new(name);
    endfunction

    function build_phase (uvm_phase phase);
        super.build_phase(phase);
        agt = axi_agent_base :: type_id :: create ("agt", this);
    endfunction
endclass

`endif