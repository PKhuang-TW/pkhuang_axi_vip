`ifndef AXI_ID_INFO_MAP_SV
`define AXI_ID_INFO_MAP_SV

class axi_id_info_map;

    // Record all info (len, size, addr of each transfer) for each ID
    bit [`D_ID_WIDTH-1:0]           id[$];
    bit [7:0]                       len[bit [`D_ID_WIDTH-1:0]];
    bit [2:0]                       size[bit [`D_ID_WIDTH-1:0]];
    bit [`D_MEM_ADDR_WIDTH-1:0]     addr_q[bit [`D_ID_WIDTH-1:0]][$];
    bit                             complete[bit [`D_ID_WIDTH-1:0]];
    
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
endclass

`endif
