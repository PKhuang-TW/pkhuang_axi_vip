`ifndef AXI_SLAVE_MEM_MODEL_SV
`define AXI_SLAVE_MEM_MODEL_SV

`include "axi_define.svh"

class id_info_map;
    // Record all info (len, size, addr of each transfer) for each ID
    bit [`D_ID_WIDTH-1:0]           id[$];
    bit [7:0]                       len[bit [`D_ID_WIDTH-1:0]];
    bit [2:0]                       size[bit [`D_ID_WIDTH-1:0]];
    bit [`D_MEM_ADDR_WIDTH-1:0]     addr_q[bit [`D_ID_WIDTH-1:0]][$];
    bit                             complete[bit [`D_ID_WIDTH-1:0]];

    function bit scan_complete_id( logic [`D_ID_WIDTH-1:0] complete_id );
        complete_id = 'x;
        foreach ( complete[id] ) begin
            if (complete[id]) begin
                complete_id = id;
                return 1;
            end
        end
        return 0;
    endfunction
endclass

class axi_slave_mem_model extends uvm_object;
    
    bit [`D_MEM_SIZE-1:0][7:0]      mem;
    id_info_map                     r_id_info_map, w_id_info_map;

    function new ( string name = "axi_slave_mem_model" );
        super.new(name);
        r_id_info_map = new();
        w_id_info_map = new();
    endfunction

    virtual task process_id_info_map (
        operation_e                 op,
        bit[`D_ID_WIDTH-1:0]        id,
        burst_type_e                burst_type,
        bit[`D_ADDR_WIDTH-1:0]      addr,
        bit[7:0]                    len,
        bit[2:0]                    size
    );
        id_info_map                     id_info;
        bit [`D_MEM_ADDR_WIDTH-1:0]     total_size;
        bit [`D_MEM_ADDR_WIDTH-1:0]     wrap_boundary;

        if ( op == WRITE ) begin
            id_info = r_id_info_map;
        end else if ( op == READ ) begin
            id_info = w_id_info_map;
        end

        id_info.id.push_back(id);
        id_info.len[id]         = len;
        id_info.size[id]        = size;
        id_info.complete[id]    = 0;

        case ( burst_type )
            BURST_TYPE_FIXED: begin
                for ( int i=0; i<=len; i++) begin
                    id_info.addr_q[id].push_back(addr);
                end
            end

            BURST_TYPE_INCR: begin
                for ( int i=0; i<=len; i++) begin
                    id_info.addr_q[id].push_back( addr + (i * (1 << size)) );
                end
            end

            BURST_TYPE_WRAP: begin
                total_size      = ( len + 1 ) * ( 1 << size );
                wrap_boundary   = ( addr / total_size ) * total_size;
                for ( int i=0; i<=len; i++) begin
                    id_info.addr_q[id].push_back(
                        ( addr - wrap_boundary + i * (1<<size) ) % total_size
                    );
                end
            end

            default: begin
                `uvm_error ("ERROR", $sformatf("Unexpected TXN burst type! (%0d)", burst_type) )
            end
        endcase
    endtask

    virtual task process_w_op (
        bit [`D_ID_WIDTH-1:0]       id,
        bit [`D_DATA_WIDTH-1:0]     data,
        bit                         last
    );
        bit [2:0]                   size;
        bit[`D_ADDR_WIDTH-1:0]      addr;

        size = w_id_info_map.size[id];
        addr = w_id_info_map.addr_q[id].pop_front();

        for ( int i=0; i<(1 << size); i++ ) begin
            mem[addr + i] = data[7+8*i -: 8];
        end

        if ( last )
            w_id_info_map.complete[id] = 1;
    endtask

    virtual task process_b_op (
        output bit                      found_complete_id,
        output bit [`D_ID_WIDTH-1:0]    complete_id
    );
        found_complete_id = w_id_info_map.scan_complete_id ( complete_id );
    endtask

    virtual task process_r_op (
        input  bit [`D_ID_WIDTH-1:0]    id,
        output bit [`D_DATA_WIDTH-1:0]  data
    );
        bit [2:0]                   size;
        bit[`D_ADDR_WIDTH-1:0]      addr;
        bit[7:0]                    len;

        size    = r_id_info_map.size[id];
        addr    = r_id_info_map.addr_q[id].pop_front();

        for ( int i=0; i<(1 << size); i++ ) begin
            data[7+8*i -: 8] = mem[addr + i];
        end
    endtask

    virtual task clr_id_info (
        operation_e             op,
        bit [`D_ID_WIDTH-1:0]   id
    );
        id_info_map     id_info;

        if ( op == WRITE ) begin
            id_info = r_id_info_map;
        end else if ( op == READ ) begin
            id_info = w_id_info_map;
        end

        id_info.id = id_info.id.find with (item != id);
        if ( id_info.len.exists(id) )
            id_info.len.delete(id);
        if ( id_info.size.exists(id) )
            id_info.size.delete(id);
        if ( id_info.addr_q.exists(id) )
            id_info.addr_q.delete(id);
    endtask

endclass

`endif