`ifndef AXI_IF_SV
`define AXI_IF_SV

interface axi_if;
    logic                           ACLK;
    logic                           ARESETn;

    // ----------- Write Address -----------
    logic [`D_ID_WIDTH-1:0]         AWID;
    logic [`D_ADDR_WIDTH-1:0]       AWADDR;
    logic [7:0]                     AWLEN;
    logic [2:0]                     AWSIZE;
    logic [1:0]                     AWBURST;
    logic [2:0]                     AWPROT;
    logic                           AWVALID;
    logic                           AWREADY;

    // ----------- Write Data -----------
    logic [`D_ID_WIDTH-1:0]         WID;
    logic [`D_DATA_WIDTH-1:0]       WDATA;
    logic [(`D_DATA_WIDTH>>3)-1:0]  WSTRB;
    logic                           WLAST;
    logic                           WVALID;
    logic                           WREADY;

    // ----------- Write Response -----------
    logic [`D_ID_WIDTH-1:0]         BID;
    logic [1:0]                     BRESP;
    logic                           BVALID;
    logic                           BREADY;

    // ----------- Read Address -----------
    logic [`D_ID_WIDTH-1:0]         ARID;
    logic [`D_ADDR_WIDTH-1:0]       ARADDR;
    logic [7:0]                     ARLEN;
    logic [2:0]                     ARSIZE;
    logic [1:0]                     ARBURST;
    logic [2:0]                     ARPROT;
    logic                           ARVALID;
    logic                           ARREADY;

    // ----------- Read Data -----------
    logic [`D_ID_WIDTH-1:0]         RID;
    logic [`D_DATA_WIDTH-1:0]       RDATA;
    logic [1:0]                     RRESP;
    logic                           RLAST;
    logic                           RVALID;
    logic                           RREADY;


    clocking mon_cb @( posedge ACLK );
        default input #1step;

        //////// Global Signals ////////
        input #0    ACLK;
        input #0    ARESETn;

        //////// Write Address ////////
        input       AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWPROT, AWVALID, AWREADY;

        //////// Write Data ////////
        input       WID, WDATA, WSTRB, WLAST, WVALID, WREADY;

        //////// Write Response ////////
        input       BID, BRESP, BVALID, BREADY;
        
        //////// Read Address ////////
        input       ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARPROT, ARVALID, ARREADY;
        
        //////// Read Data ////////
        input       RID, RDATA, RRESP, RLAST, RVALID, RREADY;
    endclocking

    clocking mst_cb @( posedge ACLK );
        default input #1step output #0;

        //////// Global Signals ////////
        input #0    ACLK;
        input #0    ARESETn;

        //////// Write Address ////////
        output      AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWPROT, AWVALID;
        input       AWREADY;

        //////// Write Data ////////
        output      WID, WDATA, WSTRB, WLAST, WVALID;
        input       WREADY;

        //////// Write Response ////////
        input       BID, BRESP, BVALID;
        output      BREADY;
        
        //////// Read Address ////////
        output      ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARPROT, ARVALID;
        input       ARREADY;
        
        //////// Read Data ////////
        input       RID, RDATA, RRESP, RLAST, RVALID;
        output      RREADY;
    endclocking

    clocking slv_cb @( posedge ACLK );
        default input #1step;

        //////// Global Signals ////////
        input #0    ACLK;
        input #0    ARESETn;

        //////// Write Address ////////
        input       AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWPROT, AWVALID;
        output      AWREADY;

        //////// Write Data ////////
        input       WID, WDATA, WSTRB, WLAST, WVALID;
        output      WREADY;

        //////// Write Response ////////
        output      BID, BRESP, BVALID;
        input       BREADY;
        
        //////// Read Address ////////
        input       ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARPROT, ARVALID;
        output      ARREADY;
        
        //////// Read Data ////////
        output      RID, RDATA, RRESP, RLAST, RVALID;
        input       RREADY;
    endclocking

    modport mst_if ( clocking mst_cb );
    modport slv_if ( clocking slv_cb );
    modport mon_if ( clocking mon_cb );

endinterface

`endif