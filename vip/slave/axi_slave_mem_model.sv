`ifndef AXI_SLAVE_MEM_MODEL_SV
`define AXI_SLAVE_MEM_MODEL_SV

`include "axi_define.svh"

task axi_slave_mem_model::calc_addr_q (
    input bit[`D_ID_WIDTH-1:0]          id,
    input burst_type_e                  burst_type,
    input bit[`D_ADDR_WIDTH-1:0]        addr,
    input bit[7:0]                      len,
    input bit[2:0]                      size,
    output bit [`D_MEM_ADDR_WIDTH-1:0]  id_2_addr_q[bit [`D_ID_WIDTH-1:0]][]
);
    // bit [`D_ID_WIDTH-1:0]           id_q[$]
    // bit [`D_MEM_ADDR_WIDTH-1:0]     addr_q[$]
    bit [`D_MEM_ADDR_WIDTH-1:0]     total_size;
    bit [`D_MEM_ADDR_WIDTH-1:0]     wrap_boundary;

    case ( burst_type )
        BURST_TYPE_FIXED: begin
            for ( int i=0; i<=len; i++) begin
                id_2_addr_q[id].push_back(addr);
                // addr_q.push_back(addr);
                // id_q.push_back(id);
            end
        end

        BURST_TYPE_INCR: begin
            for ( int i=0; i<=len; i++) begin
                id_2_addr_q[id].push_back( addr + (i * (1 << size)) );
                // w_addr_q.push_back(addr + (i * (1 << size)) );
            end
        end

        BURST_TYPE_WRAP: begin
            total_w_size    = ( len + 1 ) * ( 1 << size );
            wrap_boundary   = ( addr / total_w_size ) * total_w_size;
            for ( int i=0; i<=len; i++) begin
                id_2_addr_q[id].push_back( wrap_boundary + addr % wrap_boundary );
                // w_addr_q.push_back( wrap_boundary + addr % wrap_boundary );
            end
        end

        default: begin
            `uvm_error ("ERROR", $sformatf("Unexpected TXN burst type! (%0d)", burst_type) )
        end
    endcase
endtask

task axi_slave_mem_model::write_burst();

    bit[`D_ADDR_WIDTH-1:0]        addr;

    addr = w_id_2_addr_q[vif.WID].pop_front();

    for ( int i=0; i<(1 << vif.AWSIZE); i++ ) begin
        mem[addr + i] = vif.WDATA[7+8*i -: 8];
    end
endtask

task axi_slave_mem_model::read_burst (
    output bit[`D_DATA_WIDTH-1:0] data
);
    bit[`D_ADDR_WIDTH-1:0]        addr;

    addr = r_id_2_addr_q[vif.RID].pop_front();

    for ( int i=0; i<(1 << vif.ARSIZE); i++ ) begin
        vif.RDATA[7+8*i -: 8] = mem[addr + i];
    end
endtask

`endif