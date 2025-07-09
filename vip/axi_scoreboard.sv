`ifndef AXI_SCOREBOARD_SV
`define AXI_SCOREBOARD_SV

class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)

    axi_mem_model                                       mem_model;
    uvm_analysis_imp #(axi_seq_item, axi_scoreboard)    ap_imp;

    function new ( name = "axi_scoreboard", uvm_component parent );
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
    endfunction

    function void build_phase ( uvm_phase phase );
        super.build_phase(phase);
        mem_model = axi_mem_model :: type_id :: create ("mem_model");
    endfunction

    virtual function void write ( axi_seq_item txn );

        // R Channel
        bit[7:0]                    len;
        bit [`D_DATA_WIDTH-1:0]     data;

        case (txn.kind)
            AW_TXN: begin
                `uvm_info("SCB", "Handle AW Signal", UVM_HIGH)
                mem_model.process_id_info_map (
                    .op(WRITE),
                    .id(txn.aw_id),
                    .burst_type(txn.aw_burst),
                    .addr(txn.aw_addr),
                    .len(txn.aw_len),
                    .size(txn.aw_size)
                );
            end

            W_TXN: begin
                for ( int i=0; i<txn.w_data.size(); i++ ) begin
                    `uvm_info("SCB", "Handle W Signal", UVM_HIGH)
                    mem_model.process_w_op (
                        .id(txn.w_id),
                        .data(txn.w_data[i]),
                        .strb(txn.w_strb[i]),
                        .last( i==txn.w_data.size()-1 ? 1 : 0 )
                    );
                end
            end

            B_TXN: begin
                if ( txn.b_resp != RSP_OKAY ) begin  // default okay
                    `uvm_error(
                        "SCB",
                        $sformatf("Write TXN Resp = %s while expected RSP_OKAY", txn.b_resp)
                    )
                end else if ( !mem_model.w_id_info_map.complete[txn.b_id] ) begin
                    `uvm_error(
                        "SCB",
                        $sformatf("Write TXN (ID=%0d) is not ready for Response yet!", txn.b_id)
                    )
                end else begin  // PASS
                    `uvm_info("SCB", "B Signal Completes!", UVM_HIGH)
                    mem_model.clr_id_info (
                        .op(WRITE),
                        .id(txn.b_id)
                    );
                end
            end

            AR_TXN: begin
                `uvm_info("SCB", "Handle AR Signal", UVM_HIGH)
                mem_model.process_id_info_map (
                    .op(READ),
                    .id(txn.ar_id),
                    .burst_type( burst_type_e'(txn.ar_burst) ),
                    .addr(txn.ar_addr),
                    .len(txn.ar_len),
                    .size(txn.ar_size)
                );
            end

            R_TXN: begin
                if ( !mem_model.r_id_info_map.complete[txn.r_id] ) begin
                    `uvm_error(
                        "SCB",
                        $sformatf("Read TXN (ID=%0d) is not ready for Response yet!", txn.r_id)
                    )
                end else begin
                    for ( int i=0; i<txn.r_data.size(); i++ ) begin

                        if ( txn.r_resp[i] != RSP_OKAY ) begin  // default okay
                            `uvm_error(
                                "SCB",
                                $sformatf("Read TXN Resp = %s while expected RSP_OKAY", txn.r_resp[i])
                            )
                        end else begin
                            `uvm_info("SCB", "Handle R Signal", UVM_HIGH)
                            mem_model.process_r_op (
                                .id(txn.r_id),
                                .data(data)
                            );

                            if ( data != txn.r_data[i] ) begin
                                `uvm_error(
                                    "SCB",
                                    $sformatf("Read Data = 0x%h when expected 0x%h", txn.r_data[i], data)
                                )
                            end else begin  // PASS
                                mem_model.clr_id_info (
                                    .op(READ),
                                    .id(txn.r_id)
                                );
                            end
                        end
                    end
                end
            end

            default: begin
                `uvm_error(
                    "SCB",
                    $sformatf("Non-supported TXN kind (%0d)", txn.kind)
                )
            end
        endcase
    endfunction


endclass

`endif