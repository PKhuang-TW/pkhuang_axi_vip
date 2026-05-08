`ifndef AXI_UTILS_PKG_SVH
`define AXI_UTILS_PKG_SVH

// typedef bit [`D_ADDR_WIDTH-1:0] addr_q_t[$];

// function addr_q_t get_addr_q (
//     bit [`D_ADDR_WIDTH-1:0]         addr,
//     bit [7:0]                       len,
//     bit [2:0]                       size,
//     burst_type_e                    burst
// );
//     addr_q_t                        addr_q;
//     bit [`D_MEM_ADDR_WIDTH-1:0]     total_size;
//     bit [`D_MEM_ADDR_WIDTH-1:0]     wrap_boundary;

//     case ( burst )
//         BURST_TYPE_FIXED: begin
//             for ( bit [`D_ADDR_WIDTH-1:0] i=0; i<=len; i++) begin
//                 addr_q.push_back(addr);
//             end
//         end

//         BURST_TYPE_INCR: begin
//             for ( bit [`D_ADDR_WIDTH-1:0] i=0; i<=len; i++) begin
//                 addr_q.push_back( addr + (i * (1 << size)) );
//             end
//         end

//         BURST_TYPE_WRAP: begin
//             total_size      = ( len + 1 ) * ( 1 << size );
//             wrap_boundary   = ( addr / total_size ) * total_size;
//             for ( bit [`D_ADDR_WIDTH-1:0] i=0; i<=len; i++) begin
//                 addr_q.push_back(
//                     ( addr - wrap_boundary + i * (1<<size) ) % total_size
//                 );
//             end
//         end

//         default: begin
//             `uvm_error ("ERROR", $sformatf("Unexpected TXN burst type! (%0d)", burst) )
//         end
//     endcase

//     return addr_q;
// endfunction

`endif