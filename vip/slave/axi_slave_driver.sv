`ifndef AXI_SLAVE_DRIVER_SV
`define AXI_SLAVE_DRIVER_SV

class axi_slave_driver extends axi_driver_base;
    `uvm_component_utils(axi_slave_driver)

    axi_mem_model               mem_model;

    virtual axi_if.slv_if       vif;

    function new ( string name = "axi_slave_driver", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        if ( !uvm_config_db #(virtual axi_if.slv_if) :: get (this, "", "vif.slv_if", vif) )
            `uvm_error("NOCFG", $sformatf("No vif is set for %s.vif", get_full_name()) )

        mem_model = new("mem_model");
    endfunction

    virtual task run_phase ( uvm_phase phase );
        fork
            forever begin aw_signal_handler()       ;end
            forever begin w_signal_handler()        ;end
            forever begin b_signal_handler()        ;end
            forever begin ar_signal_handler()       ;end
            forever begin r_signal_handler()        ;end
            forever begin reset_signal_handler()    ;end
        join
    endtask

    extern virtual task aw_signal_handler();
    extern virtual task w_signal_handler();
    extern virtual task b_signal_handler();
    extern virtual task ar_signal_handler();
    extern virtual task r_signal_handler();
    extern virtual task reset_signal_handler();

    extern virtual task reset_aw_signal();
    extern virtual task reset_w_signal();
    extern virtual task reset_b_signal();
    extern virtual task reset_ar_signal();
    extern virtual task reset_r_signal();

    extern virtual task reset_axi_signal();

    extern virtual task wait_clk ( int cycle );

endclass : axi_slave_driver

task axi_slave_driver::wait_clk ( int cycle );
    #1;  // simulate delay to trigger mst_cb
    @ ( vif.slv_cb );
endtask

task axi_slave_driver::aw_signal_handler();
    begin
        wait ( vif.slv_cb.AWVALID );

        `uvm_info (
            "aw_signal_handler",
            $sformatf("Handle AW Signal: ID = 0x%h", vif.slv_cb.AWID),
            UVM_HIGH
        )
        mem_model.w_id_info_map.set_id_info (
            .id(vif.slv_cb.AWID),
            .addr(vif.slv_cb.AWADDR),
            .len(vif.slv_cb.AWLEN),
            .size(vif.slv_cb.AWSIZE),
            .burst( burst_type_e'(vif.slv_cb.AWBURST) ),
            .prot(vif.slv_cb.AWPROT)
        );

        vif.slv_cb.AWREADY <= 0;
        wait_clk(1);
        reset_aw_signal();
    end
endtask : aw_signal_handler

task axi_slave_driver::w_signal_handler();
    begin
        wait ( vif.slv_cb.WVALID );

        `uvm_info(
            "w_signal_handler",
            $sformatf("Handle W Signal: ID = 0x%h", vif.slv_cb.WID),
            UVM_HIGH
        )

        fork
            begin
                mem_model.process_w_op (
                    .id(vif.slv_cb.WID),
                    .data(vif.slv_cb.WDATA),
                    .strb(vif.slv_cb.WSTRB),
                    .last(vif.slv_cb.WLAST)
                );
            end
            begin
                vif.slv_cb.WREADY <= 0;
                wait_clk(1);
            end
        join

        reset_w_signal();
    end
endtask : w_signal_handler
 
task axi_slave_driver::b_signal_handler();
    bit                     found_complete_id;
    bit [`D_ID_WIDTH-1:0]   complete_id;

    begin
        wait ( vif.slv_cb.BREADY && vif.slv_cb.ARESETn );

        mem_model.process_b_op ( found_complete_id, complete_id );
        if ( found_complete_id ) begin
            `uvm_info(
                "b_signal_handler",
                $sformatf("Handle B Signal: ID = 0x%h", complete_id),
                UVM_HIGH
            )
            vif.slv_cb.BRESP   <= RSP_OKAY;  // default okay
            vif.slv_cb.BID     <= complete_id;
            mem_model.clr_id_info (
                .op(WRITE),
                .id(complete_id)
            );
            vif.slv_cb.BVALID  <= 1;
            wait_clk(1);
            reset_b_signal();
        end else begin
            wait_clk(1);
        end
    end
endtask : b_signal_handler

task axi_slave_driver::ar_signal_handler();
    begin
        wait ( vif.slv_cb.ARVALID );

        `uvm_info(
            "ar_signal_handler",
            $sformatf("Handle AR Signal: ID = 0x%h", vif.slv_cb.ARID),
            UVM_HIGH
        )

        mem_model.r_id_info_map.set_id_info (
            .id(vif.slv_cb.ARID),
            .addr(vif.slv_cb.ARADDR),
            .len(vif.slv_cb.ARLEN),
            .size(vif.slv_cb.ARSIZE),
            .burst( burst_type_e'(vif.slv_cb.ARBURST) ),
            .prot(vif.slv_cb.ARPROT)
        );

        // r_q.push_back(vif.slv_cb.ARID);

        vif.slv_cb.ARREADY <= 0;
        wait_clk(1);
        reset_ar_signal();
    end
endtask : ar_signal_handler

task axi_slave_driver::r_signal_handler();
    bit [`D_ID_WIDTH-1:0]    id;
    bit [7:0]                len;
    bit [`D_DATA_WIDTH-1:0]  data;
    bit                      found_complete_id;

    begin
        // Support interleaving Read transfer
        wait ( mem_model.r_id_info_map.get_id_size() );

        id = mem_model.r_id_info_map.get_rand_id();

        `uvm_info (
            "r_signal_handler",
            $sformatf("Handle R Signal: ID = 0x%h", id),
            UVM_HIGH
        )

        mem_model.process_r_op ( id, data );
        vif.slv_cb.RID     <= id;
        vif.slv_cb.RDATA   <= data;
        vif.slv_cb.RRESP   <= RSP_OKAY;  // default okay

        if ( mem_model.r_id_info_map.get_addr_q_size_by_id(id) ) begin
            vif.slv_cb.RLAST <= 0;
        end else begin
            vif.slv_cb.RLAST <= 1;
            mem_model.clr_id_info (
                .op(READ),
                .id(id)
            );
        end
        vif.slv_cb.RVALID  <= 1;

        wait_clk(1);
        wait ( vif.slv_cb.RREADY );
        reset_r_signal();
    end
endtask : r_signal_handler

task axi_slave_driver::reset_signal_handler();
    begin
        wait ( !vif.slv_cb.ARESETn );
        reset_axi_signal();
    end
endtask

task axi_slave_driver::reset_aw_signal();
    begin
        vif.slv_cb.AWREADY <= 1;
        wait_clk(1);
    end
endtask : reset_aw_signal

task axi_slave_driver::reset_w_signal();
    begin
        vif.slv_cb.WREADY  <= 1;
        wait_clk(1);
    end
endtask : reset_w_signal

task axi_slave_driver::reset_b_signal();
    begin
        vif.slv_cb.BID     <= 0;
        vif.slv_cb.BRESP   <= 0;
        vif.slv_cb.BVALID  <= 0;
        wait_clk(1);
    end
endtask : reset_b_signal

task axi_slave_driver::reset_ar_signal();
    begin
        vif.slv_cb.ARREADY <= 1;
        wait_clk(1);
    end
endtask : reset_ar_signal

task axi_slave_driver::reset_r_signal();
    begin
        vif.slv_cb.RID     <= 0;
        vif.slv_cb.RDATA   <= 0;
        vif.slv_cb.RRESP   <= 0;
        vif.slv_cb.RLAST   <= 0;
        vif.slv_cb.RVALID  <= 0;
        wait_clk(1);
    end
endtask : reset_r_signal

task axi_slave_driver::reset_axi_signal();
    fork
        reset_aw_signal();
        reset_w_signal();
        reset_b_signal();
        reset_ar_signal();
        reset_r_signal();
    join
endtask : reset_axi_signal

`endif