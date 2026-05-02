`ifndef AXI_ID_INFO_MAP_SV
`define AXI_ID_INFO_MAP_SV

class axi_id_info_map;

    // Typedefs for cleaner associative array & queue declarations
    typedef bit [`D_ID_WIDTH-1:0]           axi_id_t;
    typedef bit [`D_ADDR_WIDTH-1:0]         addr_q_t [$];
    typedef bit [`D_DATA_WIDTH-1:0]         data_q_t [$];
    typedef bit [(`D_DATA_WIDTH>>3)-1:0]    strb_q_t [$];

    axi_id_t                        id [$];
    bit [7:0]                       len      [axi_id_t];
    bit [2:0]                       size     [axi_id_t];
    burst_type_e                    burst    [axi_id_t];
    prot_s                          prot     [axi_id_t];
    addr_q_t                        addr_q   [axi_id_t];
    data_q_t                        data_q   [axi_id_t];
    strb_q_t                        strb_q   [axi_id_t];
    bit                             complete [axi_id_t];

    function void set_id_info (
        bit [`D_ID_WIDTH-1:0]           id,
        bit [`D_ADDR_WIDTH-1:0]         addr,
        bit [7:0]                       len,
        bit [2:0]                       size,
        burst_type_e                    burst,
        prot_s                          prot = 0,

        // ====== For Write ======
        bit [`D_DATA_WIDTH-1:0]         data_q [$] = '{},
        bit [(`D_DATA_WIDTH>>3)-1:0]    strb_q [$] = '{},
        bit                             complete = 0
    );
        // bit [`D_MEM_ADDR_WIDTH-1:0]     total_size;
        // bit [`D_MEM_ADDR_WIDTH-1:0]     wrap_boundary;

        this.id.push_back(id);
        this.len[id]    = len;
        this.size[id]   = size;
        this.burst[id]  = burst;

        // case ( burst )
        //     BURST_TYPE_FIXED: begin
        //         for ( [`D_ADDR_WIDTH-1:0] i=0; i<=len; i++) begin
        //             this.addr_q[id].push_back(addr);
        //         end
        //     end

        //     BURST_TYPE_INCR: begin
        //         for ( [`D_ADDR_WIDTH-1:0] i=0; i<=len; i++) begin
        //             this.addr_q[id].push_back( addr + (i * (1 << size)) );
        //         end
        //     end

        //     BURST_TYPE_WRAP: begin
        //         total_size      = ( len + 1 ) * ( 1 << size );
        //         wrap_boundary   = ( addr / total_size ) * total_size;
        //         for ( [`D_ADDR_WIDTH-1:0] i=0; i<=len; i++) begin
        //             this.addr_q[id].push_back(
        //                 ( addr - wrap_boundary + i * (1<<size) ) % total_size
        //             );
        //         end
        //     end

        //     default: begin
        //         `uvm_error ("ERROR", $sformatf("Unexpected TXN burst type! (%0d)", burst) )
        //     end
        // endcase
        this.addr_q[id] = get_addr_q ( addr, len, size, burst );

        for ( int i=0; i<=len; i++ ) begin
            this.data_q[id].push_back(data_q[i]);
            this.strb_q[id].push_back(strb_q[i]);
        end

        this.complete[id]   = complete;
    endfunction

    function void clr_id_info (
        bit [`D_ID_WIDTH-1:0]   id
    );
        this.id = this.id.find with (item != id);
        if ( this.len.exists(id) )
            this.len.delete(id);
        if ( this.size.exists(id) )
            this.size.delete(id);
        if ( this.burst.exists(id) )
            this.burst.delete(id);
        if ( this.prot.exists(id) )
            this.prot.delete(id);
        if ( this.addr_q.exists(id) )
            this.addr_q.delete(id);
        if ( this.data_q.exists(id) )
            this.data_q.delete(id);
        if ( this.strb_q.exists(id) )
            this.strb_q.delete(id);
        if ( this.complete.exists(id) )
            this.complete.delete(id);
    endfunction
    
    function bit scan_complete_id( output logic [`D_ID_WIDTH-1:0] complete_id );
        complete_id = 'x;
        foreach ( complete[id] ) begin
            if (complete[id]) begin
                complete_id = id;
                return 1;
            end
        end
        return 0;
    endfunction

    function int get_id_size();
        return id.size();
    endfunction

    function bit [`D_ID_WIDTH-1:0] get_rand_id();
        return id[$urandom_range(0, get_id_size()-1)];
    endfunction

    function int get_addr_q_size_by_id ( bit [`D_ID_WIDTH-1:0] id );
        return addr_q[id].size();
    endfunction

    function bit [`D_ADDR_WIDTH-1:0] get_addr_by_id_idx ( bit [`D_ID_WIDTH-1:0] id, int idx );
        return addr_q[id][idx];
    endfunction
endclass

`endif