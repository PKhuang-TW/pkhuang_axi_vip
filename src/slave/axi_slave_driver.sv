`ifndef AXI_SLAVE_DRIVER_SV
`define AXI_SLAVE_DRIVER_SV

class axi_slave_driver extends axi_driver_base;
    `uvm_component_utils(axi_slave_driver)

    axi_mem_model                       mem_model;

    uvm_analysis_port #(axi_seq_item)   aw_ap, w_ap;

    axi_seq_item                        b_q[$];

    virtual axi_if                      vif;

    function new ( string name = "axi_slave_driver", uvm_component parent );
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        if ( !uvm_config_db #(virtual axi_if) :: get (this, "", "vif", vif) )
            `uvm_error("NOCFG", $sformatf("No vif is set for %s.vif", get_full_name()) )

        mem_model = new("mem_model");
        aw_ap = new("aw_ap", this);
        w_ap = new("w_ap", this);
    endfunction

    virtual task run_phase ( uvm_phase phase );
        fork
            forever begin get_txn()                 ;end
            forever begin listen_aw_channel()       ;end
            forever begin listen_w_channel()        ;end
            forever begin drive_b_channel()         ;end
            forever begin listen_ar_channel()       ;end
            forever begin drive_r_channel()        ;end
            forever begin reset_signal_handler()    ;end
        join
    endtask

    extern virtual task get_txn();
    extern virtual task listen_aw_channel();
    extern virtual task listen_w_channel();
    extern virtual task drive_b_channel();
    extern virtual task listen_ar_channel();
    extern virtual task drive_r_channel();
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
    repeat ( cycle ) @ ( vif.slv_cb );
endtask

task axi_slave_driver::get_txn();
    axi_seq_item    txn;

    if ( vif.slv_cb.ARESETn === 1'b1 ) begin
        txn = axi_seq_item :: type_id :: create ("txn");
        seq_item_port.get_next_item(txn);

        if ( txn.kind == B_TXN ) begin
            `uvm_info("GET_TXN", $sformatf("Kind = %s, BID = 0x%h", txn.kind.name(), txn.b_id), UVM_MEDIUM )
        end

        case ( txn.kind )
            B_TXN:      b_q.push_back(txn);        
            // default:    `uvm_error("DRV", $sformatf("Unsupported txn.kind: %s", txn.kind.name()))
        endcase
        seq_item_port.item_done();
    end else begin
        wait_clk(1);
    end
endtask

task axi_slave_driver::listen_aw_channel();
    axi_seq_item    txn;

    begin
        @ (vif.slv_cb iff vif.slv_cb.AWVALID === 1'b1);

        `uvm_info (
            "listen_aw_channel",
            $sformatf("Handle AW Signal: ID = 0x%h", vif.slv_cb.AWID),
            UVM_MEDIUM
        )
        // mem_model.w_id_info_map.set_id_info (
        //     .id(vif.slv_cb.AWID),
        //     .addr(vif.slv_cb.AWADDR),
        //     .len(vif.slv_cb.AWLEN),
        //     .size(vif.slv_cb.AWSIZE),
        //     .burst( burst_type_e'(vif.slv_cb.AWBURST) ),
        //     .prot(vif.slv_cb.AWPROT)
        // );

        txn = axi_seq_item::type_id::create("txn");
        txn.kind        = AW_TXN;
        txn.aw_id       = vif.slv_cb.AWID;
        txn.aw_id       = vif.slv_cb.AWID;
        txn.aw_addr     = vif.slv_cb.AWADDR;
        txn.aw_len      = vif.slv_cb.AWLEN;
        txn.aw_size     = vif.slv_cb.AWSIZE;
        txn.aw_burst    = burst_type_e'(vif.slv_cb.AWBURST);
        txn.aw_prot     = vif.slv_cb.AWPROT;
        
        vif.slv_cb.AWREADY <= 0;
        wait_clk(1);
        reset_aw_signal();

        aw_ap.write(txn);
    end
endtask : listen_aw_channel

task axi_slave_driver::listen_w_channel();
    axi_seq_item    txn;

    begin
        @ (vif.slv_cb iff vif.slv_cb.WVALID === 1'b1);

        `uvm_info(
            "listen_w_channel",
            $sformatf("Handle W Signal: ID = 0x%h", vif.slv_cb.WID),
            UVM_MEDIUM
        )

        // fork
        //     begin
        //         mem_model.process_w_op (
        //             .id(vif.slv_cb.WID),
        //             .data(vif.slv_cb.WDATA),
        //             .strb(vif.slv_cb.WSTRB),
        //             .last(vif.slv_cb.WLAST)
        //         );
        //     end
        //     begin
        //         vif.slv_cb.WREADY <= 0;
        //         wait_clk(1);
        //     end
        // join

        txn = axi_seq_item::type_id::create("txn");
        txn.kind        = W_TXN;
        txn.w_id       = vif.slv_cb.WID;

        forever begin
            if ( vif.slv_cb.WVALID === 1'b1 ) begin
                vif.slv_cb.WREADY <= 0;
                txn.w_data.push_back(vif.slv_cb.WDATA);
                txn.w_strb.push_back(vif.slv_cb.WSTRB);
            end
            wait_clk(1);
            reset_w_signal();
            if ( vif.slv_cb.WLAST === 1'b1 ) break;
        end

        w_ap.write(txn);
    end
endtask : listen_w_channel
 
task axi_slave_driver::drive_b_channel();
    // bit                     found_complete_id;
    // bit [`D_ID_WIDTH-1:0]   complete_id;
    axi_seq_item    txn;

    begin
        @ ( vif.slv_cb iff (vif.slv_cb.BREADY && vif.slv_cb.ARESETn) );

        wait ( b_q.size() );
        txn = b_q.pop_front();

        vif.slv_cb.BID      <= txn.b_id;
        vif.slv_cb.BRESP    <= txn.b_resp;  // default okay
        vif.slv_cb.BVALID   <= 1;

        wait_clk(1);
        reset_b_signal();

        // mem_model.process_b_op ( found_complete_id, complete_id );
        // if ( found_complete_id ) begin
        //     `uvm_info(
        //         "drive_b_channel",
        //         $sformatf("Handle B Signal: ID = 0x%h", complete_id),
        //         UVM_MEDIUM
        //     )
        //     vif.slv_cb.BRESP   <= RSP_OKAY;  // default okay
        //     vif.slv_cb.BID     <= complete_id;
        //     mem_model.clr_id_info (
        //         .op(WRITE),
        //         .id(complete_id)
        //     );
        //     vif.slv_cb.BVALID  <= 1;
        //     wait_clk(1);
        //     reset_b_signal();
        // end else begin
        //     wait_clk(1);
        // end
    end
endtask : drive_b_channel

task axi_slave_driver::listen_ar_channel();
    begin
        wait ( vif.slv_cb.ARVALID );

        `uvm_info(
            "listen_ar_channel",
            $sformatf("Handle AR Signal: ID = 0x%h", vif.slv_cb.ARID),
            UVM_MEDIUM
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
endtask : listen_ar_channel

task axi_slave_driver::drive_r_channel();
    bit [`D_ID_WIDTH-1:0]    id;
    bit [7:0]                len;
    bit [`D_DATA_WIDTH-1:0]  data;
    bit                      found_complete_id;

    begin
        // Support interleaving Read transfer
        wait ( mem_model.r_id_info_map.get_id_size() );

        id = mem_model.r_id_info_map.get_rand_id();

        `uvm_info (
            "drive_r_channel",
            $sformatf("Handle R Signal: ID = 0x%h", id),
            UVM_MEDIUM
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
endtask : drive_r_channel

task axi_slave_driver::reset_signal_handler();
    begin
        while ( vif.slv_cb.ARESETn === 1'b1 ) wait_clk(1);
        `uvm_info(
            "reset_signal_handler",
            "Reset AXI slave signal!",
            UVM_MEDIUM
        )
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