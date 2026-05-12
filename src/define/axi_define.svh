`ifndef AXI_DEFINE_SVH
`define AXI_DEFINE_SVH

`define D_MEM_SIZE              65536  // Bit
`define D_MEM_ADDR_WIDTH        $clog2(`D_MEM_SIZE)

`define D_ADDR_WIDTH_BIT        $clog2(`D_MEM_SIZE)
`define D_ADDR_WIDTH_BYTE       (`D_MEM_SIZE>>3)
`define D_ADDR_WIDTH_BYTE_2n    $clog2(`D_ADDR_WIDTH_BYTE)

`define D_DATA_WIDTH_BIT        256
`define D_DATA_WIDTH_BYTE       (`D_DATA_WIDTH_BIT>>3)
`define D_DATA_WIDTH_BYTE_2n    $clog2(`D_DATA_WIDTH_BYTE)

`define D_ID_WIDTH              8

`define D_SLV_CNT               1

`endif