`ifndef AXI_ENV_SV
`define AXI_ENV_SV

class axi_env extends uvm_env;
    `uvm_component_utils(axi_env)

    axi_master_agent        agt_mst;
    axi_slave_agent         agt_slv;
    axi_virtual_sequencer   vseqr;

    axi_scoreboard          scb;

    axi_mem_model           mem;

    function new (string name = "axi_env", uvm_component parent );
        super.new(name, parent);
        mem = new("mem");
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        agt_mst = axi_master_agent :: type_id :: create ("agt_mst", this);
        agt_slv = axi_slave_agent :: type_id :: create ("agt_slv", this);
        vseqr = axi_virtual_sequencer :: type_id :: create("vseqr", this);

        scb = axi_scoreboard :: type_id :: create ("scb", this);

        mem = axi_mem_model :: type_id :: create ("mem");

        uvm_config_db #(axi_mem_model) :: set (this, "*", "mem", mem);
    endfunction

    function void connect_phase ( uvm_phase phase );
        super.connect_phase(phase);

        agt_mst.mon.aw_ap.connect ( scb.mst_aw_fifo.analysis_export );
        agt_mst.mon.w_ap.connect ( scb.mst_w_fifo.analysis_export );
        agt_mst.mon.b_ap.connect ( scb.mst_b_fifo.analysis_export );
        agt_mst.mon.ar_ap.connect ( scb.mst_ar_fifo.analysis_export );
        agt_mst.mon.r_ap.connect ( scb.mst_r_fifo.analysis_export );

        agt_slv.mon.aw_ap.connect ( scb.slv_aw_fifo.analysis_export );
        agt_slv.mon.w_ap.connect ( scb.slv_w_fifo.analysis_export );
        agt_slv.mon.b_ap.connect ( scb.slv_b_fifo.analysis_export );
        agt_slv.mon.ar_ap.connect ( scb.slv_ar_fifo.analysis_export );
        agt_slv.mon.r_ap.connect ( scb.slv_r_fifo.analysis_export );

        if ( !$cast(vseqr.seqr_mst, agt_mst.seqr) ) begin
            `uvm_error("CAST_FAIL", "agt_mst.seqr is not an axi_master_sequencer")
        end
        
        if ( !$cast(vseqr.seqr_slv, agt_slv.seqr) ) begin
            `uvm_error("CAST_FAIL", "agt_slv.seqr is not an axi_slave_sequencer")
        end
    endfunction
endclass

`endif