`ifndef AXI_DEFINE_SVH
`define AXI_DEFINE_SVH

`define D_MEM_SIZE          65536  // Byte
`define D_MEM_ADDR_WIDTH    $clog2(`D_MEM_SIZE)

`define D_ADDR_WIDTH        $clog2(`D_MEM_SIZE)
`define D_DATA_WIDTH        32
`define D_ID_WIDTH          8

`define D_SLV_CNT           1

`endif