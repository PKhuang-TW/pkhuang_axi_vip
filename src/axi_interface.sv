`ifndef AXI_IF_SV
`define AXI_IF_SV

interface axi_if # (
    int ADDR_WIDTH  = axi_package::ADDR_WIDTH,
    int DATA_WIDTH  = axi_package::DATA_WIDTH,
    int ID_WIDTH    = axi_package::ID_WIDTH
)(
    input logic ACLK,
    input logic ARESETn
);

    // ----------- Write Address -----------
    logic [ID_WIDTH-1:0]            AWID;
    logic [ADDR_WIDTH-1:0]          AWADDR;
    logic [7:0]                     AWLEN;
    logic [2:0]                     AWSIZE;
    logic [1:0]                     AWBURST;
    logic [2:0]                     AWPROT;
    logic                           AWVALID;
    logic                           AWREADY;

    // ----------- Write Data -----------
    logic [ID_WIDTH-1:0]            WID;
    logic [DATA_WIDTH-1:0]          WDATA;
    logic [(DATA_WIDTH>>3)-1:0]     WSTRB;
    logic                           WLAST;
    logic                           WVALID;
    logic                           WREADY;

    // ----------- Write Response -----------
    logic [ID_WIDTH-1:0]            BID;
    logic [1:0]                     BRESP;
    logic                           BVALID;
    logic                           BREADY;

    // ----------- Read Address -----------
    logic [ID_WIDTH-1:0]            ARID;
    logic [ADDR_WIDTH-1:0]          ARADDR;
    logic [7:0]                     ARLEN;
    logic [2:0]                     ARSIZE;
    logic [1:0]                     ARBURST;
    logic [2:0]                     ARPROT;
    logic                           ARVALID;
    logic                           ARREADY;

    // ----------- Read Data -----------
    logic [ID_WIDTH-1:0]            RID;
    logic [DATA_WIDTH-1:0]          RDATA;
    logic [1:0]                     RRESP;
    logic                           RLAST;
    logic                           RVALID;
    logic                           RREADY;

modport mst_if (
    //////// Write Address ////////
    output  AWID,
    output  AWADDR,
    output  AWLEN,
    output  AWSIZE,
    output  AWBURST,
    output  AWPROT,
    output  AWVALID,
    input   AWREADY,

    //////// Write Data ////////
    output  WID,
    output  WDATA,
    output  WSTRB,
    output  WLAST,
    output  WVALID,
    input   WREADY,

    //////// Write Response ////////
    input   BID,
    input   BRESP,
    input   BVALID,
    output  BREADY,
    
    //////// Read Address ////////
    output  ARID,
    output  ARADDR,
    output  ARLEN,
    output  ARSIZE,
    output  ARBURST,
    output  ARPROT,
    output  ARVALID,
    input   ARREADY
    
    //////// Read Data ////////
    input   RID,
    input   RDATA,
    input   RRESP,
    input   RLAST,
    input   RVALID,
    output  RREADY
);

modport slv_if (
    //////// Write Address ////////
    input   AWID,
    input   AWADDR,
    input   AWLEN,
    input   AWSIZE,
    input   AWBURST,
    input   AWPROT,
    input   AWVALID,
    output  AWREADY,

    //////// Write Data ////////
    input   WID,
    input   WDATA,
    input   WSTRB,
    input   WLAST,
    input   WVALID,
    output  WREADY,

    //////// Write Response ////////
    output  BID,
    output  BRESP,
    output  BVALID,
    input   BREADY,
    
    //////// Read Address ////////
    input   ARID,
    input   ARADDR,
    input   ARLEN,
    input   ARSIZE,
    input   ARBURST,
    input   ARPROT,
    input   ARVALID,
    output  ARREADY
    
    //////// Read Data ////////
    output  RID,
    output  RDATA,
    output  RRESP,
    output  RLAST,
    output  RVALID,
    input   RREADY
);

// To accidentally modifying interface signals within a monitor
modport mon_if (
    //////// Write Address ////////
    input   AWADDR,
    input   AWLEN,
    input   AWSIZE,
    input   AWBURST,
    input   AWPROT,
    input   AWVALID,
    input   AWREADY,

    //////// Write Data ////////
    input   WDATA,
    input   WSTRB,
    input   WLAST,
    input   WVALID,
    input   WREADY,

    //////// Write Response ////////
    input   BID,
    input   BRESP,
    input   BVALID,
    input   BREADY
    
    //////// Read Address ////////
    input   ARADDR,
    input   ARLEN,
    input   ARSIZE,
    input   ARBURST,
    input   ARPROT,
    input   ARVALID,
    input   ARREADY
    
    //////// Read Data ////////
    input   RID,
    input   RDATA,
    input   RRESP,
    input   RLAST,
    input   RVALID,
    input   RREADY
);

`endif