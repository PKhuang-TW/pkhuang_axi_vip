`ifndef AXI_SEQ_ITEM_SV
`define AXI_SEQ_ITEM_SV

`include "axi_define.svh"

class axi_seq_item extends uvm_sequence_item;

    //  Group: Variables
    rand txn_kind_e                     kind;

    //-----------------------------------------------------------
    // Write 
    //-----------------------------------------------------------
    rand bit[`D_ID_WIDTH-1:0]           w_id;
    rand bit[`D_ADDR_WIDTH-1:0]         w_addr;
    rand bit[7:0]                       w_len;
    rand bit[2:0]                       w_size;
    rand burst_type_e                   w_burst;
    rand prot_s                         w_prot;
    rand bit[`D_DATA_WIDTH-1:0]         w_data[$];
    rand bit[(`D_DATA_WIDTH>>3)-1:0]    w_strb[$];

    rsp_e                               w_rsp;

    //-----------------------------------------------------------
    // Read 
    //-----------------------------------------------------------
    rand bit[`D_ID_WIDTH-1:0]           r_id;
    rand bit[`D_ADDR_WIDTH-1:0]         r_addr;
    rand bit[7:0]                       r_len;
    rand bit[2:0]                       r_size;
    rand burst_type_e                   r_burst;
    rand prot_s                         r_prot;

    bit[`D_DATA_WIDTH-1:0]              r_data[$];
    rsp_e                               r_rsp[$];

    `uvm_object_param_utils_begin(axi_seq_item)
        `uvm_field_enum(txn_kind_e, kind)
        `uvm_field_int(w_id)
        `uvm_field_int(w_addr)
        `uvm_field_int(w_len)
        `uvm_field_int(w_size)
        `uvm_field_enum(burst_type_e, w_burst)
        `uvm_field_int(w_prot.instruction)
        `uvm_field_int(w_prot.non_secure)
        `uvm_field_int(w_prot.privileged)
        `uvm_field_queue_int(w_data)
        `uvm_field_queue_int(w_strb)
        `uvm_field_enum(rsp_e, w_rsp)
        `uvm_field_int(r_id)
        `uvm_field_int(r_addr)
        `uvm_field_int(r_len)
        `uvm_field_int(r_size)
        `uvm_field_enum(burst_type_e, r_burst)
        `uvm_field_int(r_prot.instruction)
        `uvm_field_int(r_prot.non_secure)
        `uvm_field_int(r_prot.privileged)
        `uvm_field_queue_int(r_data)
        `uvm_field_queue_enum(rsp_e, r_rsp)
    `uvm_object_param_utils_end

    constraint c_kind {
        soft kind == ( AW_TXN || AR_TXN );
    }

    //  Group: Constraints
    constraint c_write_data_size {
        if ( kind == AW_TXN ) {
            // drv will keep these data during AW
            w_data.size() == len+1;
            w_strb.size() == len+1;
        }
    }

    constraint c_mem_overflow {
        w_addr <= `D_MEM_SIZE;
        r_addr <= `D_MEM_SIZE;
    }

    function new(string name = "axi_seq_item");
        super.new(name);
    endfunction: new
    
endclass: axi_seq_item

`endif