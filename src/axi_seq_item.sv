`ifndef AXI_SEQ_ITEM_SV
`define AXI_SEQ_ITEM_SV

`include "axi_define.svh"
import axi_typedef::*;

class axi_seq_item extends uvm_sequence_item;

    //  Group: Variables
    rand txn_kind_e                         kind;
    rand bit                                narrow_tsfr;

    //-----------------------------------------------------------
    // Write 
    //-----------------------------------------------------------
    rand bit[`D_ID_WIDTH-1:0]               aw_id;
    rand bit[`D_ADDR_WIDTH_BIT-1:0]         aw_addr;
    rand bit[7:0]                           aw_len;
    rand bit[2:0]                           aw_size;
    rand burst_type_e                       aw_burst;
    rand prot_s                             aw_prot;

    rand bit[`D_ID_WIDTH-1:0]               w_id;
    rand bit[`D_DATA_WIDTH_BIT-1:0]         w_data[$];
    rand bit[(`D_DATA_WIDTH_BIT>>3)-1:0]    w_strb[$];
    bit                                     w_last;

    bit[`D_ID_WIDTH-1:0]                    b_id;
    rsp_e                                   b_resp;
    rsp_e                                   exp_b_resp;


    //-----------------------------------------------------------
    // Read 
    //-----------------------------------------------------------
    rand bit[`D_ID_WIDTH-1:0]               ar_id;
    rand bit[`D_ADDR_WIDTH_BIT-1:0]         ar_addr;
    rand bit[7:0]                           ar_len;
    rand bit[2:0]                           ar_size;
    rand burst_type_e                       ar_burst;
    rand prot_s                             ar_prot;

    bit[`D_ID_WIDTH-1:0]                    r_id;
    bit[`D_DATA_WIDTH_BIT-1:0]              r_data[$];
    bit                                     r_last;
    rsp_e                                   r_resp[$];
    rsp_e                                   exp_r_resp[$];

    localparam int MAX_TXN_SIZE = (`D_DATA_WIDTH_BIT / 8) < `D_MEM_SIZE ? $clog2(`D_DATA_WIDTH_BIT / 8) : `D_MEM_SIZE;

    //-----------------------------------------------------------

    constraint c_order              { solve narrow_tsfr before aw_size; }

    constraint c_kind               { soft kind dist { 0:=1, 3:=1 }; }  // AW: 50%, AR: 50%
    // constraint c_narrow_tsfr        { soft narrow_tsfr == 0; }
    constraint c_burst              { aw_burst <= BURST_TYPE_WRAP; ar_burst <= BURST_TYPE_WRAP; }
    constraint c_id                 { aw_id == w_id; }

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
        ( 1 << aw_size ) <= `D_DATA_WIDTH_BYTE;
        ( 1 << ar_size ) <= `D_DATA_WIDTH_BYTE;

        if ( narrow_tsfr ) {
            ( 1 << aw_size ) < `D_DATA_WIDTH_BYTE;
        } else {
            ( 1 << aw_size ) == `D_DATA_WIDTH_BYTE;
        }
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
    
    // Calculates WSTRB for each beat based on AXI protocol parameters
    virtual function void post_randomize();
        
        bit[`D_ADDR_WIDTH_BIT-1:0]          awaddr_container_base, wrap_boundary_base;
        bit[`D_ADDR_WIDTH_BYTE_2n:0]        tsfr_size_per_beat, wrap_size;  // Reserve extra bit

        bit[`D_DATA_WIDTH_BYTE-1:0]         strb_mask, tmp_mask;
        bit[`D_DATA_WIDTH_BYTE_2n-1:0]      container_cnt, wrap_container_cnt;
        bit[`D_DATA_WIDTH_BYTE_2n-1:0]      awaddr_container_idx;
        bit[`D_DATA_WIDTH_BYTE_2n-1:0]      offset;

        bit[`D_DATA_WIDTH_BYTE_2n-1:0]      wrap_boundary_container_idx;
        bit[`D_DATA_WIDTH_BYTE_2n-1:0]      awaddr_wrap_container_offset;
        bit[`D_DATA_WIDTH_BYTE_2n-1:0]      current_container;

        if ( kind != AW_TXN ) return;  // Only calculate WSTRB for write transactions
        
        tsfr_size_per_beat      = (1 << aw_size);

        // Data range that transfered in each beat is within a single "container" on data bus
        awaddr_container_idx    = ( aw_addr % `D_DATA_WIDTH_BYTE) / tsfr_size_per_beat;
        awaddr_container_base   = (aw_addr / tsfr_size_per_beat) * tsfr_size_per_beat;
        offset                  = aw_addr % tsfr_size_per_beat;
        container_cnt           = `D_DATA_WIDTH_BYTE / tsfr_size_per_beat;

        `uvm_info ( "DEBUG", $sformatf("AWADDR: 0x%0h, AWSIZE: %0d, tsfr_size_per_beat: %0d, Container Index: %0d, Container Base: 0x%0h, Offset: %0d, Containers Count: %0d", aw_addr, aw_size, tsfr_size_per_beat, awaddr_container_idx, awaddr_container_base, offset, container_cnt), UVM_MEDIUM )

        if ( narrow_tsfr ) begin
            for ( int i=0; i<(aw_len+1); i++ ) begin
                w_strb[i] = '1;
            end
        end

        for ( int i=0; i<(aw_len+1); i++ ) begin
            
            strb_mask = '1;

            case ( aw_burst )
                /* -------------------------------------------------------------------------
                 * [BURST_TYPE_FIXED Diagram]
                 * Assume: Bus=32B, Size=4B/beat, Unaligned AWADDR (Offset=1)
                 *
                 * Data Bus Bytes: 0...3 | 4...7 | 8..11 | ...
                 * Containers    : [ C0] | [ C1] | [ C2] | ...
                 * Beat 0 (i=0)  :  0000 | 0111  |  0000 | ... (Offset affects first beat)
                 * Beat 1 (i=1)  :  0000 | 0111  |  0000 | ... 
                 * Beat 2 (i=2)  :  0000 | 0111  |  0000 | ... 
                 * -------------------------------------------------------------------------*/
                BURST_TYPE_FIXED: begin
                    tmp_mask = ( `D_DATA_WIDTH_BYTE'( 1 << tsfr_size_per_beat ) - 1 );
                    tmp_mask >>= offset;  // Shift right first to create mask for unaligned access
                    tmp_mask <<= offset;  // Shift left back to align with the actual data position on the bus
                    strb_mask &= tmp_mask << ( awaddr_container_idx * tsfr_size_per_beat );
                end

                /* -------------------------------------------------------------------------
                 * [BURST_TYPE_INCR Diagram]
                 * Assume: Bus=16B, Size=4B/beat, Starts from C2
                 *
                 * Data Bus Bytes: 0...3 | 4...7 | 8..11 | 12..15 
                 * Containers    : [ C0] | [ C1] | [ C2] | [ C3] 
                 * Beat 0 (i=0)  :  0000 | 0000  |  1111 |  0000 
                 * Beat 1 (i=1)  :  0000 | 0000  |  0000 |  1111 
                 * Beat 2 (i=2)  :  1111 | 0000  |  0000 |  0000  <-- Exceeds bus, wraps to C0
                 * Beat 3 (i=3)  :  0000 | 1111  |  0000 |  0000 
                 * -------------------------------------------------------------------------*/
                BURST_TYPE_INCR: begin
                    `uvm_info("DEBUG", $sformatf("INCR Burst - Beat %0d: Container Index = ( %0d + %0d ) %% %0d = %0d", i, awaddr_container_idx, i, container_cnt, (awaddr_container_idx + i) % container_cnt), UVM_HIGH)

                    tmp_mask = ( `D_DATA_WIDTH_BYTE'( 1 << tsfr_size_per_beat ) - 1 );

                    if ( (i == 0) && (offset > 0) ) begin  // Only the first beat can be affected by unaligned offset
                        tmp_mask >>= offset;  // Shift right first to create mask for unaligned access
                        tmp_mask <<= offset;  // Shift left back to align with the actual data position on the bus
                    end

                    strb_mask &= tmp_mask << ( ( (awaddr_container_idx + i) % container_cnt ) * tsfr_size_per_beat );
                end

                /* -------------------------------------------------------------------------
                 * [BURST_TYPE_WRAP Diagram]
                 * Assume: Size=4B/beat, Len=3 (4 beats), Starts from C2
                 *
                 * Data Bus Bytes: 0...3 | 4...7 | 8..11 | 12.15 | 16...
                 * Wrap Boundary : |<----- Wrap Size (16B) ----->|
                 * Containers    : [ C0] | [ C1] | [ C2] | [ C3] | [ C4]
                 * Beat 0 (i=0)  :  0000 | 0000  |  1111 |  0000 |  0000 
                 * Beat 1 (i=1)  :  0000 | 0000  |  0000 |  1111 |  0000 
                 * Beat 2 (i=2)  :  1111 | 0000  |  0000 |  0000 |  0000  <-- AXI Protocol Wrap
                 * Beat 3 (i=3)  :  0000 | 1111  |  0000 |  0000 |  0000 
                 * -------------------------------------------------------------------------*/
                BURST_TYPE_WRAP: begin
                    wrap_size                       = tsfr_size_per_beat * (aw_len + 1);
                    wrap_container_cnt              = aw_len + 1;

                    wrap_boundary_base              = (aw_addr / wrap_size) * wrap_size;
                    wrap_boundary_container_idx     = (wrap_boundary_base % `D_DATA_WIDTH_BYTE) / tsfr_size_per_beat;
                    awaddr_wrap_container_offset    = (awaddr_container_base - wrap_boundary_base) / tsfr_size_per_beat;
                    current_container               = wrap_boundary_container_idx + ((awaddr_wrap_container_offset + i) % wrap_container_cnt);

                    tmp_mask = ( `D_DATA_WIDTH_BYTE'( 1 << tsfr_size_per_beat ) - 1 );
                    
                    if ( (i == 0) && (offset > 0) ) begin  // Only the first beat can be affected by unaligned offset
                        tmp_mask >>= offset;  // Shift right first to create mask for unaligned access
                        tmp_mask <<= offset;  // Shift left back to align with the actual data position on the bus
                    end

                    strb_mask &= tmp_mask << ( (current_container % container_cnt) * tsfr_size_per_beat );
                end

                default: begin
                    `uvm_error("ERROR", $sformatf("Unexpected burst type! (%0d)", aw_burst) )
                end
            endcase

            w_strb[i] &= strb_mask;
        end

        `uvm_info("SEQ_ITEM", $sformatf("%s", convert2string()), UVM_MEDIUM)

    endfunction: post_randomize

    virtual function string convert2string();
        string s = "";

        if ( kind == AW_TXN || kind == W_TXN ) begin
            s = { s, $sformatf("AWID: 0x%0h, AWADDR: 0x%0h, AWLEN: %0d, AWSIZE: %0d, AWBURST: %s", aw_id, aw_addr, aw_len, aw_size, aw_burst.name()) };

            s = { s, "\nW_DATA: "};
            for ( int i=0; i<aw_len+1; i++ ) begin
                s = { s, $sformatf("\n[%0d] Data: 0x%0h / Strb: 0x%b", i, w_data[i], w_strb[i]) };
            end
        end else if ( kind == AR_TXN ) begin
            s = { s, $sformatf("ARID: 0x%0h, ARADDR: 0x%0h, ARLEN: %0d, ARSIZE: %0d, ARBURST: %s", ar_id, ar_addr, ar_len, ar_size, ar_burst.name()) };
        end else begin
            s = "Unknown transaction type!";
        end

        return s;
    endfunction
    
endclass: axi_seq_item

`endif