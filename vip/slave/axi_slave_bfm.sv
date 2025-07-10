`ifndef AXI_SLAVE_BFM_SV
`define AXI_SLAVE_BFM_SV

class axi_slave_bfm;

    axi_mem_model           mem_model;
    virtual axi_if.slv_if   vif;

    bit[`D_ID_WIDTH-1:0]    w_q[$], b_q[$], r_q[$];

    function new ( virtual axi_if.slv_if vif );
        this.vif = vif;
        mem_model = new("mem_model");
    endfunction

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
endclass


task axi_slave_bfm::aw_signal_handler();
    forever begin
        wait ( vif.slv_cb.AWVALID );

        `uvm_info("SLV_BFM", "Handle AW Signal", UVM_HIGH)
        vif.slv_cb.AWREADY <= 0;
        mem_model.process_id_info_map (
            .op(WRITE),
            .addr(vif.slv_cb.AWADDR),
            .id(vif.slv_cb.AWID),
            .len(vif.slv_cb.AWLEN),
            .size(vif.slv_cb.AWSIZE),
            .burst( burst_type_e'(vif.slv_cb.AWBURST) ),
            .prot(vif.slv_cb.AWPROT)
        );

        #1;  // Simulate Delay
        // @ ( vif.slv_cb );
        reset_aw_signal();
    end
endtask : aw_signal_handler

task axi_slave_bfm::w_signal_handler();
    forever begin
        wait ( vif.slv_cb.WVALID );

        `uvm_info("SLV_BFM", "Handle W Signal", UVM_HIGH)
        vif.slv_cb.WREADY <= 0;
        mem_model.process_w_op (
            .id(vif.slv_cb.WID),
            .data(vif.slv_cb.WDATA),
            .strb(vif.slv_cb.WSTRB),
            .last(vif.slv_cb.WLAST)
        );

        #1;  // Simulate Delay
        @ ( vif.slv_cb );
        reset_w_signal();
    end
endtask : w_signal_handler

task axi_slave_bfm::b_signal_handler();
    bit                     found_complete_id;
    bit [`D_ID_WIDTH-1:0]   complete_id;

    forever begin
        wait ( vif.slv_cb.BREADY );

        mem_model.process_b_op ( found_complete_id, complete_id );
        if ( found_complete_id ) begin
            `uvm_info("SLV_BFM", $sformatf("B Signal Completes! (ID = 0x%h)", complete_id), UVM_HIGH)
            vif.slv_cb.BRESP   <= RSP_OKAY;  // default okay
            vif.slv_cb.BID     <= complete_id;
            vif.slv_cb.BVALID  <= 1;
            mem_model.clr_id_info (
                .op(WRITE),
                .id(complete_id)
            );
        end
        
        #1;  // Simulate Delay
        reset_b_signal();
    end
endtask : b_signal_handler

task axi_slave_bfm::ar_signal_handler();
    forever begin
        wait ( vif.slv_cb.ARVALID );
        `uvm_info("SLV_BFM", "Handle AR Signal", UVM_HIGH)

        mem_model.process_id_info_map (
            .op(READ),
            .id(vif.slv_cb.ARID),
            .addr(vif.slv_cb.ARADDR),
            .len(vif.slv_cb.ARLEN),
            .size(vif.slv_cb.ARSIZE),
            .burst( burst_type_e'(vif.slv_cb.ARBURST) ),
            .prot(vif.slv_cb.ARPROT)
        );

        r_q.push_back(vif.slv_cb.ARID);

        vif.slv_cb.ARREADY <= 0;
        @ ( vif.slv_cb );
        reset_ar_signal();
    end
endtask : ar_signal_handler

task axi_slave_bfm::r_signal_handler();
    bit [`D_ID_WIDTH-1:0]    id;
    bit[7:0]                 len;
    bit [`D_DATA_WIDTH-1:0]  data;

    forever begin
        // @ ( vif.slv_cb );

        while ( !r_q.size() ) @ ( vif.slv_cb );
        
        id = r_q.pop_front();
        len = mem_model.r_id_info_map.len[id];

        `uvm_info(
            "r_signal_handler",
            $sformatf("Handle R Signal: ID=0x%h, len=0x%h", id, len),
            UVM_HIGH
        )
        for ( int i=0; i<=len; i++) begin
            mem_model.process_r_op (
                .id(id),
                .data(data)
            );
            vif.slv_cb.RID     <= id;
            vif.slv_cb.RDATA   <= data;
            vif.slv_cb.RRESP   <= RSP_OKAY;  // default ok

            if ( i==len ) begin
                vif.slv_cb.RLAST <= 1;
                mem_model.clr_id_info (
                    .op(READ),
                    .id(id)
                );
            end else begin
                vif.slv_cb.RLAST <= 0;
            end
            vif.slv_cb.RVALID  <= 1;

            @ ( vif.slv_cb );
            wait ( vif.slv_cb.RREADY );
            reset_r_signal();
        end
    end
endtask : r_signal_handler

task axi_slave_bfm::reset_signal_handler();
    forever begin
        @ ( vif.slv_cb );
        if ( !vif.slv_cb.ARESETn )
            reset_axi_signal();
    end
endtask

task axi_slave_bfm::reset_aw_signal();
    begin
        vif.slv_cb.AWREADY <= 1;
        @ ( vif.slv_cb );
    end
endtask : reset_aw_signal

task axi_slave_bfm::reset_w_signal();
    begin
        vif.slv_cb.WREADY  <= 1;
        @ ( vif.slv_cb );
    end
endtask : reset_w_signal

task axi_slave_bfm::reset_b_signal();
    begin
        vif.slv_cb.BID     <= 0;
        vif.slv_cb.BRESP   <= 0;
        vif.slv_cb.BVALID  <= 0;
        // @ ( vif.slv_cb );
    end
endtask : reset_b_signal

task axi_slave_bfm::reset_ar_signal();
    begin
        vif.slv_cb.ARREADY <= 1;
        @ ( vif.slv_cb );
    end
endtask : reset_ar_signal

task axi_slave_bfm::reset_r_signal();
    begin
        vif.slv_cb.RID     <= 0;
        vif.slv_cb.RDATA   <= 0;
        vif.slv_cb.RRESP   <= 0;
        vif.slv_cb.RLAST   <= 0;
        vif.slv_cb.RVALID  <= 0;
        @ ( vif.slv_cb );
    end
endtask : reset_r_signal

task axi_slave_bfm::reset_axi_signal();
    fork
        reset_aw_signal();
        reset_w_signal();
        reset_b_signal();
        reset_ar_signal();
        reset_r_signal();
    join
endtask : reset_axi_signal

`endif