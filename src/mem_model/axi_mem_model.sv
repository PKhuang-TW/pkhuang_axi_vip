`ifndef AXI_MEM_MODEL_SV
`define AXI_MEM_MODEL_SV

typedef bit [`D_ADDR_WIDTH_BIT-1:0] addr_q_t[$];

class axi_mem_model extends uvm_object;
    `uvm_object_utils(axi_mem_model)
    
    bit [`D_MEM_SIZE-1:0][7:0]      mem;
    bit [`D_MEM_SIZE-1:0]           rc_lock;

    function new ( string name = "axi_mem_model" );
        super.new(name);
    endfunction

    extern virtual function void display_mem();
    extern virtual function addr_q_t get_addr_q ( axi_seq_item aw_txn );
    extern virtual task handle_wr_txn ( axi_seq_item aw_txn, axi_seq_item w_txn );

endclass : axi_mem_model

function void axi_mem_model::display_mem();
    string row_str;
    int addr;
    
    `uvm_info("MEM_DUMP", "------------------ Memory Dump (16 bytes/row) ------------------", UVM_LOW)        
    for (int i = 0; i < `D_MEM_SIZE; i += 16) begin
        row_str = $sformatf("Addr 0x%05h: ", i);
        
        for (int j = 0; j < 16; j++) begin
            addr = i + j;
            if (addr < `D_MEM_SIZE) begin
                row_str = {row_str, $sformatf("%02h ", mem[addr])};
            end
        end
        
        `uvm_info("MEM_DUMP", row_str, UVM_LOW)
    end
    `uvm_info("MEM_DUMP", "----------------------------------------------------------------", UVM_LOW)
endfunction

function addr_q_t axi_mem_model::get_addr_q ( axi_seq_item aw_txn );

    bit [`D_ADDR_WIDTH_BIT-1:0]     addr;
    bit [7:0]                       len;
    bit [2:0]                       size;
    burst_type_e                    burst;
    addr_q_t                        addr_q;
    bit [`D_MEM_ADDR_WIDTH-1:0]     total_size;
    bit [`D_MEM_ADDR_WIDTH-1:0]     wrap_base;

    addr    = aw_txn.aw_addr;
    len     = aw_txn.aw_len;
    burst   = aw_txn.aw_burst;
    size    = 1 << aw_txn.aw_size;

    case ( burst )
        BURST_TYPE_FIXED: begin
            for ( bit [`D_ADDR_WIDTH_BIT-1:0] i=0; i<=len; i++) begin
                addr_q.push_back ( addr / size * size );
            end
        end

        BURST_TYPE_INCR: begin
            for ( bit [`D_ADDR_WIDTH_BIT-1:0] i=0; i<=len; i++) begin
                addr_q.push_back( (addr + (i * size)) % `D_MEM_SIZE / size * size );
            end
        end

        BURST_TYPE_WRAP: begin
            total_size  = ( len + 1 ) * ( 1 << size );
            wrap_base   = ( addr / total_size ) * total_size;
            for ( bit [`D_ADDR_WIDTH_BIT-1:0] i=0; i<=len; i++) begin
                addr_q.push_back ( ( addr + (i * size) - wrap_base ) % total_size / size * size + wrap_base );
            end
        end

        default: begin
            `uvm_error ("ERROR", $sformatf("Unexpected TXN burst type! (%0d)", burst) )
        end
    endcase

    return addr_q;
endfunction

task axi_mem_model::handle_wr_txn ( axi_seq_item aw_txn, axi_seq_item w_txn );

    addr_q_t                    addr_q;
    int                         size_per_beat;
    bit[`D_DATA_WIDTH_BIT-1:0]  tmp_data;
    bit[`D_ADDR_WIDTH_BIT-1:0]  tmp_addr;
    bit[`D_DATA_WIDTH_BYTE-1:0] tmp_strb;

    addr_q = get_addr_q(aw_txn);
    size_per_beat = 1 << aw_txn.aw_size;

    for ( int idx=0; idx<=aw_txn.aw_len; idx++ ) begin
        tmp_addr = addr_q.pop_front();
        tmp_data = w_txn.w_data.pop_front();
        tmp_strb = w_txn.w_strb.pop_front();

        for ( int i=0; i<size_per_beat; i++ ) begin
            if ( tmp_strb[i] ) begin
                mem[tmp_addr + i] = tmp_data[i*8 +: 8];
            end
        end
    end
    display_mem();
endtask

`endif