`ifndef AXI_SEQ_ITEM_SV
`define AXI_SEQ_ITEM_SV

`include "axi_define.svh"
import axi_typedef::*;

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
    bit                                 w_last;

    bit[`D_ID_WIDTH-1:0]                b_id;
    rsp_e                               b_resp;
    rsp_e                               exp_b_resp;


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
    bit                                 r_last;
    rsp_e                               r_resp[$];
    rsp_e                               exp_r_resp[$];

    localparam int MAX_TXN_SIZE = (`D_DATA_WIDTH / 8) < `D_MEM_SIZE ? $clog2(`D_DATA_WIDTH / 8) : `D_MEM_SIZE;

    `uvm_object_utils_begin(axi_seq_item)
        `uvm_field_enum(txn_kind_e, kind, UVM_ALL_ON)
        `uvm_field_int(aw_id, UVM_ALL_ON)
        `uvm_field_int(aw_addr, UVM_ALL_ON)
        `uvm_field_int(aw_len, UVM_ALL_ON)
        `uvm_field_int(aw_size, UVM_ALL_ON)
        `uvm_field_enum(burst_type_e, aw_burst, UVM_ALL_ON)
        `uvm_field_int(aw_prot.instruction, UVM_ALL_ON)
        `uvm_field_int(aw_prot.non_secure, UVM_ALL_ON)
        `uvm_field_int(aw_prot.privileged, UVM_ALL_ON)
        `uvm_field_int(w_id, UVM_ALL_ON)
        `uvm_field_queue_int(w_data, UVM_ALL_ON)
        `uvm_field_queue_int(w_strb, UVM_ALL_ON)
        `uvm_field_int(w_last, UVM_ALL_ON)
        `uvm_field_int(b_id, UVM_ALL_ON)
        `uvm_field_enum(rsp_e, b_resp, UVM_ALL_ON)
        `uvm_field_enum(rsp_e, exp_b_resp, UVM_ALL_ON)
        `uvm_field_int(ar_id, UVM_ALL_ON)
        `uvm_field_int(ar_addr, UVM_ALL_ON)
        `uvm_field_int(ar_len, UVM_ALL_ON)
        `uvm_field_int(ar_size, UVM_ALL_ON)
        `uvm_field_enum(burst_type_e, ar_burst, UVM_ALL_ON)
        `uvm_field_int(ar_prot.instruction, UVM_ALL_ON)
        `uvm_field_int(ar_prot.non_secure, UVM_ALL_ON)
        `uvm_field_int(ar_prot.privileged, UVM_ALL_ON)
        `uvm_field_int(r_id, UVM_ALL_ON)
        `uvm_field_queue_int(r_data, UVM_ALL_ON)
        `uvm_field_int(r_last, UVM_ALL_ON)
        `uvm_field_queue_enum(rsp_e, r_resp, UVM_ALL_ON)
        `uvm_field_queue_enum(rsp_e, exp_r_resp, UVM_ALL_ON)
    `uvm_object_utils_end

    constraint c_kind   { soft kind dist { 0:=1, 3:=1 }; }  // AW: 50%, AR: 50%
    constraint c_burst  { aw_burst <= BURST_TYPE_WRAP; ar_burst <= BURST_TYPE_WRAP; }
    constraint c_id     { aw_id == w_id; }

    constraint c_len {
        if ( aw_burst == BURST_TYPE_FIXED ) {
            aw_len inside { [0:15] };
        } else if ( aw_burst == BURST_TYPE_INCR ) {
            aw_len inside { [0:255] };
        } else if ( aw_burst == BURST_TYPE_WRAP ) {
            aw_len inside {1, 3, 7, 15};
        }

        if ( ar_burst == BURST_TYPE_FIXED ) {
            ar_len inside { [0:15] };
        } else if ( ar_burst == BURST_TYPE_INCR ) {
            ar_len inside { [0:255] };
        } else if ( ar_burst == BURST_TYPE_WRAP ) {
            ar_len inside {1, 3, 7, 15};
        }
    }

    constraint c_size {
        aw_size <= MAX_TXN_SIZE;
        ar_size <= MAX_TXN_SIZE;
    }

    constraint c_write_data_size {
        w_data.size() == aw_len+1;
        w_strb.size() == aw_len+1;
    }

    constraint c_mem_overflow {
        aw_addr inside { [0:`D_MEM_SIZE-1] };
        ar_addr inside { [0:`D_MEM_SIZE-1] };
    }

    function new(string name = "axi_seq_item");
        super.new(name);
    endfunction: new
    
endclass: axi_seq_item

`endif