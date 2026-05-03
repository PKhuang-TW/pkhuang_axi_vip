`ifndef AXI_SCOREBOARD_SV
`define AXI_SCOREBOARD_SV

`define COMPARE_TXN(mst_txn, slv_txn, ch) \
    mst_``ch``_fifo.get(mst_txn); \
    slv_``ch``_fifo.get(slv_txn); \
    if ( !mst_txn.compare(slv_txn) ) begin \
        `uvm_error("SCB", $sformatf("Channel %s mismatch!\nSlave receives TXN:\n%s\nwhile expected:\n%s", `"ch`", slv_txn.sprint(), mst_txn.sprint())) \
    // end else begin \
    //     `uvm_info("SCB", $sformatf("Channel %s matches!\nSlave receives TXN:\n%s\nwhile expected:\n%s", `"ch`", slv_txn.sprint(), mst_txn.sprint()), UVM_MEDIUM) \
    end

class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)

    axi_mem_model                                       mem_model;
    uvm_tlm_analysis_fifo #(axi_seq_item)               mst_aw_fifo, mst_w_fifo, mst_b_fifo, mst_ar_fifo, mst_r_fifo;
    uvm_tlm_analysis_fifo #(axi_seq_item)               slv_aw_fifo, slv_w_fifo, slv_b_fifo, slv_ar_fifo, slv_r_fifo;

    function new ( string name = "axi_scoreboard", uvm_component parent );
        super.new(name, parent);
        mst_aw_fifo = new("mst_aw_fifo", this);
        mst_w_fifo = new("mst_w_fifo", this);
        mst_b_fifo = new("mst_b_fifo", this);
        mst_ar_fifo = new("mst_ar_fifo", this);
        mst_r_fifo = new("mst_r_fifo", this);
        slv_aw_fifo = new("slv_aw_fifo", this);
        slv_w_fifo = new("slv_w_fifo", this);
        slv_b_fifo = new("slv_b_fifo", this);
        slv_ar_fifo = new("slv_ar_fifo", this);
        slv_r_fifo = new("slv_r_fifo", this);
    endfunction

    function void build_phase ( uvm_phase phase );
        super.build_phase(phase);
        mem_model = axi_mem_model :: type_id :: create ("mem_model");
    endfunction

    virtual task run_phase ( uvm_phase phase );
        axi_seq_item    mst_aw_txn, mst_w_txn, mst_b_txn, mst_ar_txn, mst_r_txn;
        axi_seq_item    slv_aw_txn, slv_w_txn, slv_b_txn, slv_ar_txn, slv_r_txn;
        
        `uvm_info ( "SCB", "Starts comparing Master & Slave Signals...", UVM_MEDIUM )

        forever begin
            begin
                `COMPARE_TXN(mst_aw_txn, slv_aw_txn, aw)
            end
            begin
                `COMPARE_TXN(mst_w_txn, slv_w_txn, w)
            end
            begin
                `COMPARE_TXN(mst_b_txn, slv_b_txn, b)
            end
            begin
                `COMPARE_TXN(mst_ar_txn, slv_ar_txn, ar)
            end
            begin
                `COMPARE_TXN(mst_r_txn, slv_r_txn, r)
            end
        end
    endtask
endclass

`endif