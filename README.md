# 📘 AXI UVM VIP Description

## 🧩 Module Overview

This project implements a complete, configurable, and reusable UVM Verification IP (VIP) for the AMBA® AXI4 protocol (based on [AXI IHI0022E](https://developer.arm.com/documentation/ihi0022/e/?lang=en)).  
It is capable of operating in **master**, **slave**, or **loopback** mode, with support for configurable address/data widths, burst types, and transaction interleaving.

The VIP is structured with layered UVM components, including agent, driver, monitor, sequencer, and protocol assertions.  
Both passive and active agents are supported, and optional Bus Functional Models (BFMs) allow direct task-level control. The loopback mode connects the master and slave VIPs internally to validate protocol correctness and timing.

### ✅ Supported Features

- [x] Full AXI4 protocol support (AW, W, B, AR, R channels)
- [x] Burst types: FIXED, INCR, WRAP
- [x] AXI memory model for slave responses
- [x] Configurable data/addr widths via `axi_define.svh`
- [x] Support for outstanding transactions by ID
- [ ] Interleaved read transactions on R channel (multiple IDs, out-of-order)
- [ ] UVM scoreboard and functional coverage
- [ ] Built-in SystemVerilog Assertions (SVA) for protocol timing
- [ ] Loopback test support
- [ ] Supports both Master and Slave VIP modes

---

## 🔧 AXI Bus Interface Signals

| Channel | Signal     | Dir   | Width             | Description                        |
|---------|------------|-------|-------------------|------------------------------------|
| Global  | ACLK       | In    | 1                 | Clock                              |
|         | ARESETn    | In    | 1                 | Active-low reset                   |
| AW      | AWID       | In    | `D_ID_WIDTH`      | Write address ID                   |
|         | AWADDR     | In    | `D_ADDR_WIDTH`    | Write address                      |
|         | AWLEN      | In    | 8                 | Burst length                       |
|         | AWSIZE     | In    | 3                 | Burst size                         |
|         | AWBURST    | In    | 2 / enum          | Burst type                         |
|         | AWVALID    | In    | 1                 | Address valid                      |
|         | AWREADY    | Out   | 1                 | Address ready                      |
| W       | WID        | In    | `D_ID_WIDTH`      | Write data ID                      |
|         | WDATA      | In    | `D_DATA_WIDTH`    | Write data                         |
|         | WSTRB      | In    | `D_DATA_WIDTH/8`  | Write strobes                      |
|         | WLAST      | In    | 1                 | Last write data                    |
|         | WVALID     | In    | 1                 | Write valid                        |
|         | WREADY     | Out   | 1                 | Write ready                        |
| B       | BID        | Out   | `D_ID_WIDTH`      | Response ID                        |
|         | BRESP      | Out   | 2 / enum          | Response code                      |
|         | BVALID     | Out   | 1                 | Response valid                     |
|         | BREADY     | In    | 1                 | Response ready                     |
| AR      | ARID       | In    | `D_ID_WIDTH`      | Read address ID                    |
|         | ARADDR     | In    | `D_ADDR_WIDTH`    | Read address                       |
|         | ARLEN      | In    | 8                 | Burst length                       |
|         | ARSIZE     | In    | 3                 | Burst size                         |
|         | ARBURST    | In    | 2 / enum          | Burst type                         |
|         | ARVALID    | In    | 1                 | Read valid                         |
|         | ARREADY    | Out   | 1                 | Read ready                         |
| R       | RID        | Out   | `D_ID_WIDTH`      | Read data ID                       |
|         | RDATA      | Out   | `D_DATA_WIDTH`    | Read data                          |
|         | RRESP      | Out   | 2 / enum          | Read response                      |
|         | RLAST      | Out   | 1                 | Last read                          |
|         | RVALID     | Out   | 1                 | Read valid                         |
|         | RREADY     | In    | 1                 | Read ready                         |

---

## 🧪 AXI Testbench Modes

### Loopback Test
The VIP instantiates both master and slave agents. The master sends transactions that are looped back via slave BFM memory model.

### Master-Only Test
Use master VIP to drive a DUT slave, verify responses using monitor + scoreboard.

### Slave-Only Test
Use slave VIP to respond to a DUT master, with stimulus monitored via passive agent.

---

```
pkhuang_axi_vip/
|
├── seq/
│   ├── axi_aw_seq.sv
│   └── axi_rand_rw_seq.sv
│
├── tb/
│   └── sim_top.sv
│
├── test/
│   ├── axi_basic_test.sv
│   └── axi_rand_rw_test.sv
│
├── vip/
│   ├── base/
│   │   ├── axi_agent_base.sv
│   │   ├── axi_driver_base.sv
│   │   └── axi_monitor_base.sv
│   │
│   ├── define/
│   │   ├── axi_define.svh
│   │   └── axi_typedef.svh
│   │
│   ├── master/
│   │   ├── axi_master_agent.sv
│   │   ├── axi_master_bfm.sv
│   │   ├── axi_master_driver.sv
│   │   └── axi_master_monitor.sv
│   │
│   ├── mem_model/
│   │   ├── axi_id_info_map.sv
│   │   └── axi_mem_model.sv
│   │
│   ├── package/
│   │   └── axi_vip_pkg.svh
│   │
│   ├── slave/
│   │   ├── axi_slave_agent.sv
│   │   ├── axi_slave_bfm.sv
│   │   ├── axi_slave_driver.sv
│   │   └── axi_slave_monitor.sv
│   │
│   ├── axi_env.sv
│   ├── axi_if.sv
│   ├── axi_scoreboard.sv
│   └── axi_seq_item.sv
│
└── README.md

```