`ifndef AXI_ENV_SV
`define AXI_ENV_SV

class axi_env extends uvm_env;
    `uvm_component_utils(axi_env)

    axi_master_agent    agt_mst;
    axi_slave_agent     agt_slv;

    axi_scoreboard      scb;

    function new (string name = "axi_env", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        agt_mst = axi_master_agent :: type_id :: create ("agt_mst", this);
        agt_slv = axi_slave_agent :: type_id :: create ("agt_slv", this);

        scb = axi_scoreboard :: type_id :: create ("scb", this);
    endfunction

    function void connect_phase ( uvm_phase phase );
        super.connect_phase(phase);
        agt_mst.mon.ap.connect ( scb.ap_imp );
    endfunction
endclass

`endif
