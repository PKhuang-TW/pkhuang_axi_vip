`ifndef AXI_SLAVE_MEM_MODEL_SVH
`define AXI_SLAVE_MEM_MODEL_SVH

`include "axi_define.svh"

class axi_slave_mem_model extends uvm_object;
    
    bit [`D_MEM_ADDR_WIDTH-1:0]     w_id_2_addr_q[bit [`D_ID_WIDTH-1:0]][];
    bit [`D_MEM_ADDR_WIDTH-1:0]     r_id_2_addr_q[bit [`D_ID_WIDTH-1:0]][];

    bit [`D_MEM_SIZE-1:0][7:0]      mem;

    extern function new ( string name );

    extern task calc_addr_q (
        input bit[`D_ID_WIDTH-1:0]          id,
        input burst_type_e                  burst_type,
        input bit[`D_ADDR_WIDTH-1:0]        addr,
        input bit[7:0]                      len,
        input bit[2:0]                      size,
        output bit [`D_MEM_ADDR_WIDTH-1:0]  id_2_addr_q[bit [`D_ID_WIDTH-1:0]][]
    );

    extern task write_burst ( input axi_seq_item txn );
    extern task read_burst ( input axi_seq_item txn );

endclass

`endif