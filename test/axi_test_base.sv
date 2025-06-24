`ifndef AXI_TEST_BASE_SV
`define AXI_TEST_BASE_SV

class axi_test_base #(
    type TXN    = axi_transfer
) extends uvm_test;
    `uvm_component_utils(axi_test_base)

    axi_env_base #(TXN)     mst_env, slv_env;
    // axi_scoreboard          scb;  // TODO

    function new (string name = "axi_test_base");
        super.new(name);
    endfunction

    function build_phase (uvm_phase phase);
        super.build_phase(phase);

        axi_driver_base#(TXN)::type_id::set_inst_override_by_type(
            .original_type(axi_driver_base#(TXN)::get_type()),
            .override_type(axi_master_driver#(TXN)::get_type()),
            .inst_path("mst_env.agt.drv")
        );

        axi_monitor_base#(TXN)::type_id::set_inst_override_by_type(
            .original_type(axi_monitor_base#(TXN)::get_type()),
            .override_type(axi_master_monitor#(TXN)::get_type()),
            .inst_path("mst_env.agt.mon")
        );

        // TODO
        // axi_driver_base#(TXN)::type_id::set_inst_override_by_type(
        //     .original_type(axi_driver_base#(TXN)::get_type()),
        //     .override_type(axi_slave_driver#(TXN)::get_type()),
        //     .inst_path("slv_env.agt.drv")
        // );

        // TODO
        // axi_monitor_base#(TXN)::type_id::set_inst_override_by_type(
        //     .original_type(axi_monitor_base#(TXN)::get_type()),
        //     .override_type(axi_slave_monitor#(TXN)::get_type()),
        //     .inst_path("slv_env.agt.mon")
        // );

        mst_env =   axi_env_base #(TXN) :: type_id :: create ("mst_env", this);
        slv_env =   axi_env_base #(TXN) :: type_id :: create ("slv_env", this);
        // scb =   // TODO

        // uvm_config_db #(axi_config#(TXN)) :: set ()  // TODO
    endfunction

    function connect_phase (uvm_phase phase);
        super.connect_phase(phase);

        // TODO
        // connect mst_env.agt.mon.ap_axi_write.connect ( scb. );
        // connect mst_env.agt.mon.ap_axi_read.connect ( scb. );
        // connect slv_env.agt.mon.ap_axi_write.connect ( scb. );
        // connect slv_env.agt.mon.ap_axi_read.connect ( scb. );
    endfunction

endclass

`endif