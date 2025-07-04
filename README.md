This is an AXI vip based on [AXI IHI0022E](https://developer.arm.com/documentation/ihi0022/e/?lang=en)

For notebook of AXI, please refer to my [AXI notebook](https://hackmd.io/@PKhuang-TW/AXI_Notebook)

```
pkhuang_axi_vip/
|
├── seq/
│   └── axi_aw_seq.sv
│
├── tb/
│   └── sim_top.sv
│
├── test/
│   └── axi_basic_test.sv
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
│   ├── slave/
│   │   ├── axi_slave_agent.sv
│   │   ├── axi_slave_bfm.sv
│   │   ├── axi_slave_driver.sv
│   │   ├── axi_slave_mem_model.sv
│   │   └── axi_slave_monitor.sv
│   │
│   ├── axi_env.sv
│   ├── axi_if.sv
│   ├── axi_seq_item.sv
│   └── axi_vip_pkg.sv
│
└── README.md

```