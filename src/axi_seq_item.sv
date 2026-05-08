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
    rand bit[`D_ADDR_WIDTH_BIT-1:0]         aw_addr;
    rand bit[7:0]                       aw_len;
    rand bit[2:0]                       aw_size;
    rand burst_type_e                   aw_burst;
    rand prot_s                         aw_prot;

    rand bit[`D_ID_WIDTH-1:0]           w_id;
    rand bit[`D_DATA_WIDTH_BIT-1:0]         w_data[$];
    rand bit[(`D_DATA_WIDTH_BIT>>3)-1:0]    w_strb[$];
    bit                                 w_last;

    bit[`D_ID_WIDTH-1:0]                b_id;
    rsp_e                               b_resp;
    rsp_e                               exp_b_resp;


    //-----------------------------------------------------------
    // Read 
    //-----------------------------------------------------------
    rand bit[`D_ID_WIDTH-1:0]           ar_id;
    rand bit[`D_ADDR_WIDTH_BIT-1:0]         ar_addr;
    rand bit[7:0]                       ar_len;
    rand bit[2:0]                       ar_size;
    rand burst_type_e                   ar_burst;
    rand prot_s                         ar_prot;

    bit[`D_ID_WIDTH-1:0]                r_id;
    bit[`D_DATA_WIDTH_BIT-1:0]              r_data[$];
    bit                                 r_last;
    rsp_e                               r_resp[$];
    rsp_e                               exp_r_resp[$];

    localparam int MAX_TXN_SIZE = (`D_DATA_WIDTH_BIT / 8) < `D_MEM_SIZE ? $clog2(`D_DATA_WIDTH_BIT / 8) : `D_MEM_SIZE;

    //-----------------------------------------------------------
    
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
        ( 1 << aw_size ) <= `D_DATA_WIDTH_BIT / 8;
        ( 1 << ar_size ) <= `D_DATA_WIDTH_BIT / 8;
    }

    constraint c_write_data_size {
        w_data.size() == aw_len+1;
        w_strb.size() == aw_len+1;
    }

    constraint c_mem_overflow {
        aw_addr inside { [0:`D_MEM_SIZE-1] };
        ar_addr inside { [0:`D_MEM_SIZE-1] };
    }

    constraint c_4k_boundary {
        ((aw_addr & 12'hFFF) + ((aw_len + 1) << aw_size)) <= 4096;
        ((ar_addr & 12'hFFF) + ((ar_len + 1) << ar_size)) <= 4096;
    }

    `uvm_object_utils_begin(axi_seq_item)
        `uvm_field_enum(txn_kind_e, kind, UVM_ALL_ON)
        `uvm_field_int(aw_id, UVM_ALL_ON)
        `uvm_field_int(aw_addr, UVM_ALL_ON)
        `uvm_field_int(aw_len, UVM_ALL_ON)
        `uvm_field_int(aw_size, UVM_ALL_ON)
        `uvm_field_enum(burst_type_e, aw_burst, UVM_ALL_ON)
        `uvm_field_int(aw_prot, UVM_ALL_ON)
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
        `uvm_field_int(ar_prot, UVM_ALL_ON)
        `uvm_field_int(r_id, UVM_ALL_ON)
        `uvm_field_queue_int(r_data, UVM_ALL_ON)
        `uvm_field_int(r_last, UVM_ALL_ON)
        `uvm_field_queue_enum(rsp_e, r_resp, UVM_ALL_ON | UVM_NOPACK)
        `uvm_field_queue_enum(rsp_e, exp_r_resp, UVM_ALL_ON | UVM_NOPACK)
    `uvm_object_utils_end

    function new(string name = "axi_seq_item");
        super.new(name);
    endfunction: new
    
    // Calculate WSTRB for each beat according to AWADDR, AWSIZE, AWLEN and AWBURST
    virtual function void post_randomize();
        
        bit[`D_ADDR_WIDTH_BIT-1:0]          align_addr, wrap_boundary_addr;
        bit[`D_ADDR_WIDTH_BYTE_2n-1:0]      tsfr_size_per_beat, wrap_size;

        bit[`D_DATA_WIDTH_BYTE-1:0]         strb_mask;
        bit[`D_DATA_WIDTH_BYTE_2n-1:0]      container_num, wrap_container_num;
        bit[`D_DATA_WIDTH_BYTE_2n-1:0]      awaddr_container_idx;
        bit[`D_DATA_WIDTH_BYTE_2n-1:0]      offset;

        bit[`D_DATA_WIDTH_BYTE_2n-1:0]      wrap_boundary_container_idx;
        bit[`D_DATA_WIDTH_BYTE_2n-1:0]      start_offset_containers;
        bit[`D_DATA_WIDTH_BYTE_2n-1:0]      current_container;
        
        tsfr_size_per_beat      = `D_DATA_WIDTH_BYTE'(1 << aw_size);

        awaddr_container_idx    = ( aw_addr % `D_DATA_WIDTH_BYTE) / tsfr_size_per_beat;
        align_addr              = (aw_addr / tsfr_size_per_beat) * tsfr_size_per_beat;
        offset                  = aw_addr % tsfr_size_per_beat;
        container_num           = `D_DATA_WIDTH_BYTE / tsfr_size_per_beat;

        for ( int i=0; i<(aw_len+1); i++ ) begin
            
            strb_mask = `1;

            case ( aw_burst )
                BURST_TYPE_FIXED: begin
                    strb_mask &= ( `D_DATA_WIDTH_BYTE'( 1 << tsfr_size_per_beat ) - 1 ) << ( awaddr_container_idx * tsfr_size_per_beat );
                    
                    if ( offset > 0 ) begin
                        strb_mask[ offset-1 : 0] = 0;
                    end
                end

                BURST_TYPE_INCR: begin
                    strb_mask &= ( `D_DATA_WIDTH_BYTE'( 1 << tsfr_size_per_beat ) - 1 ) << ( ( (awaddr_container_idx + i) % container_num ) * tsfr_size_per_beat );
                    
                    if ( (i == 0) && (offset > 0) ) begin
                        strb_mask[ offset-1 : 0] = 0;
                    end
                end

                BURST_TYPE_WRAP: begin
                    wrap_size                   = tsfr_size_per_beat * (aw_len + 1);
                    wrap_container_num          = aw_len + 1;

                    wrap_boundary_addr          = (aw_addr / wrap_size) * wrap_size;
                    wrap_boundary_container_idx = (wrap_boundary_addr % `D_DATA_WIDTH_BYTE) / tsfr_size_per_beat;
                    start_offset_containers     = (align_addr - wrap_boundary_addr) / tsfr_size_per_beat;
                    current_container           = wrap_boundary_container_idx + ((start_offset_containers + i) % wrap_container_num);

                    strb_mask &= ( `D_DATA_WIDTH_BYTE'( 1 << tsfr_size_per_beat ) - 1 ) << ( current_container * tsfr_size_per_beat );

                    if ( (i == 0) && (offset > 0) ) begin
                        strb_mask[ offset-1 : 0] = 0;
                    end
                end

                default: begin
                    `uvm_error("ERROR", $sformatf("Unexpected burst type! (%0d)", aw_burst) )
                end
            endcase

            w_strb[i] &= strb_mask;
        end

    endfunction: post_randomize
    
endclass: axi_seq_item

`endif