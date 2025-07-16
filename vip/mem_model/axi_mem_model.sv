`ifndef AXI_SLAVE_MEM_MODEL_SV
`define AXI_SLAVE_MEM_MODEL_SV

class axi_mem_model extends uvm_object;
    `uvm_object_utils(axi_mem_model)
    
    bit [`D_MEM_SIZE-1:0][7:0]      mem;
    axi_id_info_map                 r_id_info_map, w_id_info_map;

    function new ( string name = "axi_mem_model" );
        super.new(name);
        r_id_info_map = new();
        w_id_info_map = new();
    endfunction

    virtual function void process_w_op (
        bit [`D_ID_WIDTH-1:0]           id,
        bit [`D_DATA_WIDTH-1:0]         data,
        bit [(`D_DATA_WIDTH>>3)-1:0]    strb,
        bit                             last
    );
        bit [2:0]                       size;
        bit [`D_ADDR_WIDTH-1:0]         addr;

        size = w_id_info_map.size[id];
        addr = w_id_info_map.addr_q[id].pop_front();

        for ( [`D_ADDR_WIDTH-1:0] i=0; i<(1 << size); i++ ) begin
            if ( (strb >> i) & 1'b1 ) begin
                mem[addr + i] = data[7+8*i -: 8];

                `uvm_info(
                    "process_w_op",
                    $sformatf("Write TXN ID=0x%h, write mem[0x%h] = 0x%h done!", id, (addr+i), data[7+8*i -: 8]),
                    UVM_HIGH
                )
            end else begin
                `uvm_info(
                    "process_w_op",
                    $sformatf("Write TXN ID=0x%h, write mem[0x%h] = 0x00 done!", id, (addr+i)),
                    UVM_HIGH
                )
            end
        end

        if ( last )
            w_id_info_map.complete[id] = 1;
    endfunction

    virtual function void  process_b_op (
        output bit                      found_complete_id,
        output bit [`D_ID_WIDTH-1:0]    complete_id
    );
        found_complete_id = w_id_info_map.scan_complete_id ( complete_id );

        if ( found_complete_id ) begin
            `uvm_info(
                "process_b_op",
                $sformatf("Write TXN ID=0x%h completes", complete_id),
                UVM_HIGH
            )
        end
    endfunction

    virtual function void process_r_op (
        input  bit [`D_ID_WIDTH-1:0]    id,
        output bit [`D_DATA_WIDTH-1:0]  data
    );
        bit [2:0]                   size;
        bit[`D_ADDR_WIDTH-1:0]      addr;

        size = r_id_info_map.size[id];
        addr = r_id_info_map.addr_q[id].pop_front();

        for ( int i=0; i<(1 << size); i++ ) begin
            data[7+8*i -: 8] = mem[addr + i];

            `uvm_info(
                "process_r_op",
                $sformatf("Read TXN ID=0x%h, read mem[0x%h] = 0x%h done!", id, (addr+i), data[7+8*i -: 8]),
                UVM_HIGH
            )
        end
    endfunction

    virtual function void clr_id_info (
        operation_e                 op,
        bit [`D_ID_WIDTH-1:0]       id
    );
        bit [`D_ADDR_WIDTH-1:0]     start_addr;
        axi_id_info_map             id_info_map;

        if ( op == WRITE ) begin
            id_info_map = w_id_info_map;
        end else if ( op == READ ) begin
            id_info_map = r_id_info_map;
        end

        id_info_map.clr_id_info(id);

        `uvm_info(
            "clr_id_info",
            $sformatf("Clear %s TXN info_map for ID = 0x%h", op.name(), id),
            UVM_HIGH
        )
    endfunction

endclass

`endif