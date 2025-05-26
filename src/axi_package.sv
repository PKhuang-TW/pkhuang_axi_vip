`ifndef AXI_PACKAGE_SV
`define AXI_PACKAGE_SV

package axi_package;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "axi_defines.svh"
    `include "axi_types.sv"

    `include "axi_config_base.sv"
    `include "axi_config_mst.sv"
    `include "axi_config_slv.sv"
    
    `include "axi_transfer.sv"

    int ADDR_WIDTH  = 32;
    int DATA_WIDTH  = 32;
    int ID_WIDTH    = 4;
    
    typedef enum { 
        BURST_TYPE_FIXED,
        BURST_TYPE_INCR,
        BURST_TYPE_WRAP,
        BURST_TYPE_RSV
    } burst_type_e;
    
    typedef struct packed {
        logic instruction; // Corresponds to AxPROT[2]
        logic non_secure;  // Corresponds to AxPROT[1]
        logic privileged;  // Corresponds to AxPROT[0]
    } prot_s;
    
    typedef enum {
        RSP_OKAY,
        RSP_EXOKAY,
        RSP_SLVERR,
        RSP_DECERR
    } rsp_e;
    
    typedef enum {
        AW_TXN,
        W_TXN,
        B_TXN,
        AR_TXN,
        R_TXN
    } txn_kind_e;
    
    typedef enum {
        ROLE_MST,
        ROLE_SLV
    } role_e;

endpackage

`endif