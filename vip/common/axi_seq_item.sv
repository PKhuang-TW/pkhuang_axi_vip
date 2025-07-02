`ifndef AXI_SEQ_ITEM_SV
`define AXI_SEQ_ITEM_SV

`include "axi_define.svh"

class axi_seq_item extends uvm_sequence_item;

    //  Group: Variables
    rand txn_kind_e                     kind;

    //-----------------------------------------------------------
    // Write 
    //-----------------------------------------------------------
    rand bit[`D_ID_WIDTH-1:0]           aw_id;
    rand bit[`D_ADDR_WIDTH-1:0]         aw_addr;
    rand bit[7:0]                       aw_len;
    rand bit[2:0]                       aw_size;
    rand burst_type_e                   aw_burst;
    rand prot_s                         aw_prot;

    rand bit[`D_ID_WIDTH-1:0]           w_id;
    rand bit[`D_DATA_WIDTH-1:0]         w_data[$];
    rand bit[(`D_DATA_WIDTH>>3)-1:0]    w_strb[$];

    rsp_e                               w_rsp;
    bit[`D_ID_WIDTH-1:0]                b_id;
    rsp_e                               b_rsp;
    rsp_e                               exp_b_rsp;


    //-----------------------------------------------------------
    // Read 
    //-----------------------------------------------------------
    rand bit[`D_ID_WIDTH-1:0]           ar_id;
    rand bit[`D_ADDR_WIDTH-1:0]         ar_addr;
    rand bit[7:0]                       ar_len;
    rand bit[2:0]                       ar_size;
    rand burst_type_e                   ar_burst;
    rand prot_s                         ar_prot;

    bit[`D_ID_WIDTH-1:0]                r_id;
    bit[`D_DATA_WIDTH-1:0]              r_data[$];
    rsp_e                               r_rsp[$];
    rsp_e                               exp_r_rsp[$];

    localparam int MAX_TXN_SIZE = $clog2(`D_DATA_WIDTH / 8);

    `uvm_object_param_utils_begin(axi_seq_item)
        `uvm_field_enum(txn_kind_e, kind)
        `uvm_field_int(aw_id)
        `uvm_field_int(aw_addr)
        `uvm_field_int(aw_len)
        `uvm_field_int(aw_size)
        `uvm_field_enum(burst_type_e, aw_burst)
        `uvm_field_int(aw_prot.instruction)
        `uvm_field_int(aw_prot.non_secure)
        `uvm_field_int(aw_prot.privileged)
        `uvm_field_int(w_id)
        `uvm_field_queue_int(w_data)
        `uvm_field_queue_int(w_strb)
        `uvm_field_enum(rsp_e, w_rsp)
        `uvm_field_int(b_id)
        `uvm_field_enum(rsp_e, b_rsp)
        `uvm_field_enum(rsp_e, exp_b_rsp)
        `uvm_field_int(ar_id)
        `uvm_field_int(ar_addr)
        `uvm_field_int(ar_len)
        `uvm_field_int(ar_size)
        `uvm_field_enum(burst_type_e, ar_burst)
        `uvm_field_int(ar_prot.instruction)
        `uvm_field_int(ar_prot.non_secure)
        `uvm_field_int(ar_prot.privileged)
        `uvm_field_int(r_id)
        `uvm_field_queue_int(r_data)
        `uvm_field_queue_enum(rsp_e, r_rsp)
        `uvm_field_queue_enum(rsp_e, exp_r_rsp)
    `uvm_object_param_utils_end

    constraint c_kind   { soft kind == ( AW_TXN || AR_TXN ); }
    constraint c_burst  { burst <= BURST_TYPE_WRAP; }
    constraint c_id     { aw_id == w_id; }

    constraint c_len {
        if ( aw_burst == BURST_TYPE_FIXED ) {
            aw_len inside { [0:15] };
        } else if ( aw_burst == BURST_TYPE_INCR ) {
            aw_len inside { [0:255] };
        } else if ( aw_burst == BURST_TYPE_WRAP ) {
            aw_len inside {1, 3, 7, 15};
        }
    }

    constraint c_size {
        aw_size <= MAX_TXN_SIZE;
        ar_size <= MAX_TXN_SIZE;
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
        aw_addr inside { [0:`D_MEM_SIZE] };
        ar_addr inside { [0:`D_MEM_SIZE] };
    }

    function new(string name = "axi_seq_item");
        super.new(name);
    endfunction: new
    
endclass: axi_seq_item

`endif