`ifndef AXI_SLAVE_BFM_SV
`define AXI_SLAVE_BFM_SV

class axi_slave_bfm;

    axi_slave_mem_model     mem_model;
    virtual axi_if.slv_if   vif;

    function new ( virtual axi_if.slv_if vif );
        this.vif = vif;
        mem_model = new();
    endfunction

    extern virtual task aw_signal_handler();
    extern virtual task w_signal_handler();
    extern virtual task b_signal_handler();
    extern virtual task ar_signal_handler();
    extern virtual task r_signal_handler();

    extern virtual task reset_aw_signal();
    extern virtual task reset_w_signal();
    extern virtual task reset_b_signal();
    extern virtual task reset_ar_signal();
    extern virtual task reset_r_signal();

    extern virtual task reset_axi_signal();
endclass


task axi_slave_bfm::aw_signal_handler();
    forever begin
        @ ( posedge vif.ACLK );
        wait ( vif.AWVALID );

        vif.AWREADY <= 0;
        mem_model.process_id_info_map (
            .op(WRITE),
            .id(vif.AWID),
            .burst_type( burst_type_e'(vif.AWBURST) ),
            .addr(vif.AWADDR),
            .len(vif.AWLEN),
            .size(vif.AWSIZE)
        );
        vif.AWREADY <= 1;

        @ ( posedge vif.ACLK );
        reset_aw_signal();
    end
endtask : aw_signal_handler

task axi_slave_bfm::w_signal_handler();
    forever begin
        @ ( posedge vif.ACLK );
        wait ( vif.WVALID );

        vif.WREADY <= 0;
        mem_model.process_w_op (
            .id(vif.WID),
            .data(vif.WDATA),
            .last(vif.WLAST)
        );
        vif.WREADY <= 1;

        @ ( posedge vif.ACLK );
        reset_w_signal();
    end
endtask : w_signal_handler

task axi_slave_bfm::b_signal_handler();
    bit                     found_complete_id;
    bit [`D_ID_WIDTH-1:0]   complete_id;
    forever begin
        @ ( posedge vif.ACLK );
        wait ( vif.BREADY );

        mem_model.process_b_op ( found_complete_id, complete_id );
        if ( found_complete_id ) begin
            vif.BVALID  <= 0;
            vif.BRESP   <= RSP_OKAY;  // default okay
            vif.BID     <= complete_id;
            #1;  // simulate delay
            mem_model.clr_id_info (
                .op(WRITE),
                .id(complete_id)
            );
            vif.BVALID  <= 1;
        end

        @ ( posedge vif.ACLK );
        reset_b_signal();
    end
endtask : b_signal_handler

task axi_slave_bfm::ar_signal_handler();
    forever begin
        @ ( posedge vif.ACLK );
        wait ( vif.ARVALID );

        vif.ARREADY <= 0;
        mem_model.process_id_info_map (
            .op(READ),
            .id(vif.ARID),
            .burst_type( burst_type_e'(vif.ARBURST) ),
            .addr(vif.ARADDR),
            .len(vif.ARLEN),
            .size(vif.ARSIZE)
        );
        vif.ARREADY <= 1;

        @ ( posedge vif.ACLK );
        reset_ar_signal();
    end
endtask : ar_signal_handler

task axi_slave_bfm::r_signal_handler();
    bit [`D_ID_WIDTH-1:0]    id;
    bit[7:0]                 len;
    bit [`D_DATA_WIDTH-1:0]  data;

    forever begin
        @ ( posedge vif.ACLK );
        if ( mem_model.r_id_info_map.id.size() > 0 ) begin
            id = mem_model.r_id_info_map.id[0];
            len = mem_model.r_id_info_map.len[id];

            for ( int i=0; i<=len; i++) begin
                mem_model.process_r_op (
                    .id(id),
                    .data(data)
                );
                vif.RVALID  <= 1;
                vif.RID     <= id;
                vif.RDATA   <= data;
                vif.RRESP   <= RSP_OKAY;  // default ok

                if ( i==len ) begin
                    vif.RLAST <= 1;
                    mem_model.clr_id_info (
                        .op(READ),
                        .id(id)
                    );
                end else begin
                    vif.RLAST <= 0;
                end

                @ ( posedge vif.ACLK );
                wait ( vif.RREADY );

                @ ( posedge vif.ACLK );
                reset_r_signal();
            end
        end
    end
endtask : r_signal_handler

task axi_slave_bfm::reset_aw_signal();
    vif.AWREADY <= 1;
endtask : reset_aw_signal

task axi_slave_bfm::reset_w_signal();
    vif.WREADY  <= 1;
endtask : reset_w_signal

task axi_slave_bfm::reset_b_signal();
    vif.BID     <= 0;
    vif.BRESP   <= 0;
    vif.BVALID  <= 0;
endtask : reset_b_signal

task axi_slave_bfm::reset_ar_signal();
    vif.ARREADY <= 1;
endtask : reset_ar_signal

task axi_slave_bfm::reset_r_signal();
    vif.RID     <= 0;
    vif.RDATA   <= 0;
    vif.RRESP   <= 0;
    vif.RLAST   <= 0;
    vif.BVALID  <= 0;
endtask : reset_r_signal

task axi_slave_bfm::reset_axi_signal();
    reset_aw_signal();
    reset_w_signal();
    reset_b_signal();
    reset_ar_signal();
    reset_r_signal();
endtask : reset_axi_signal

`endif