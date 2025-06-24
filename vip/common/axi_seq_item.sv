`ifndef AXI_SEQ_ITEM_SV
`define AXI_SEQ_ITEM_SV

class axi_seq_item #(
    int ADDR_WIDTH  = axi_package::ADDR_WIDTH,
    int DATA_WIDTH  = axi_package::DATA_WIDTH,
    int ID_WIDTH    = axi_package::ID_WIDTH
) extends uvm_sequence_item;

    typedef axi_seq_item #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .ID_WIDTH   (ID_WIDTH)
    ) TXN;

    //  Group: Variables
    rand txn_kind_e                 kind;

    //-----------------------------------------------------------
    // Common signals for all channels
    //-----------------------------------------------------------
    rand bit[ID_WIDTH-1:0]          id;

    //-----------------------------------------------------------
    // Common signals for Write Address (AW) & Read Address (AR)
    //-----------------------------------------------------------
    rand bit[ADDR_WIDTH-1:0]        addr;
    rand bit[7:0]                   len;
    rand bit[2:0]                   size;
    rand burst_type_e               burst;
    rand prot_s                     prot;

    //-----------------------------------------------------------
    // Write Data (W)
    //-----------------------------------------------------------
    rand bit[DATA_WIDTH-1:0]        w_data[$];
    rand bit[(DATA_WIDTH>>3)-1:0]   w_strb[$];

    //-----------------------------------------------------------
    // Write Response (B)
    //-----------------------------------------------------------
    rsp_e                           w_rsp;

    //-----------------------------------------------------------
    // Read Data (R)
    //-----------------------------------------------------------
    bit[DATA_WIDTH-1:0]             r_data[$];
    rsp_e                           r_rsp[$];

    `uvm_object_param_utils_begin(TXN)
        `uvm_field_enum(txn_kind_e, kind)
        `uvm_field_int(id)
        `uvm_field_int(addr)
        `uvm_field_int(len)
        `uvm_field_int(size)
        `uvm_field_enum(burst_type_e, burst)
        `uvm_field_int(prot.instruction)
        `uvm_field_int(prot.non_secure)
        `uvm_field_int(prot.privileged)
        `uvm_field_queue_int(w_data)
        `uvm_field_queue_int(w_strb)
        `uvm_field_enum(rsp_e, w_rsp)
        `uvm_field_queue_int(r_data)
        `uvm_field_queue_enum(rsp_e, r_rsp)
    `uvm_object_param_utils_end

    //  Group: Constraints
    constraint c_rw_type {
        if ( kind == TXN_WRITE ) {
            w_data.size() == len+1;
            w_strb.size() == len+1;
            r_data.size() == 0;
            r_rsp.size()  == 0;
        } else {
            r_data.size() == len+1;
            r_rsp.size()  == len+1;
            w_data.size() == 0;
            w_strb.size() == 0;
        }
    }

    // constraint c_len_rule {
    //     len > 1;
    // }

    //  Group: Functions

    //  Constructor: new
    function new(string name = "axi_seq_item");
        super.new(name);
    endfunction: new

    //  Function: do_copy
    // extern function void do_copy(uvm_object rhs);
    //  Function: do_compare
    // extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    //  Function: convert2string
    // extern function string convert2string();
    //  Function: do_print
    // extern function void do_print(uvm_printer printer);
    //  Function: do_record
    // extern function void do_record(uvm_recorder recorder);
    //  Function: do_pack
    // extern function void do_pack();
    //  Function: do_unpack
    // extern function void do_unpack();
    
endclass: axi_seq_item


/*----------------------------------------------------------------------------*/
/*  Constraints                                                               */
/*----------------------------------------------------------------------------*/




/*----------------------------------------------------------------------------*/
/*  Functions                                                                 */
/*----------------------------------------------------------------------------*/



`endif