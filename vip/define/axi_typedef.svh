`ifndef AXI_TYPEDEF_SVH
`define AXI_TYPEDEF_SVH

package axi_typedef;
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
        WRITE,
        READ
    } operation_e;

    typedef enum {
        ROLE_MST,
        ROLE_SLV
    } role_e;
endpackage

`endif