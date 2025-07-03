This is an AXI vip based on [AXI IHI0022E](https://developer.arm.com/documentation/ihi0022/e/?lang=en)

For notebook of AXI, please refer to my [AXI notebook](https://hackmd.io/@PKhuang-TW/AXI_Notebook)

```
pkhuang_axi_vip/
|
├── seq/
│   ├── axi_base_seq.sv
│   ├── axi_write_seq.sv
│   ├── axi_read_seq.sv
│   └── axi_loopback_seq.sv
│
├── test/
│   ├── axi_base_test.sv
│   ├── axi_master_test.sv
│   ├── axi_slave_test.sv
│   └── axi_loopback_test.sv
│
├── top/
│   └── sim_top.sv
│
├── vip/
|   ├── base/
|   │   ├── axi_agent_base.sv
|   │   ├── axi_driver_base.sv
|   │   └── axi_monitor_base.sv
|   │
|   ├── common/
|   │   ├── axi_config.sv
|   │   ├── axi_coverage.sv
|   │   ├── axi_define.svh
|   │   ├── axi_scoreboard.sv
|   │   └── axi_seq_item.sv
|   │
|   ├── env/
|   │   └── axi_env.sv
|   │
|   ├── interface/
|   │   └── axi_if.sv
|   │
|   ├── master/
|   │   ├── axi_master_agent.sv
|   │   ├── axi_master_bfm.sv
|   │   ├── axi_master_bfm.svh
|   │   ├── axi_master_driver.sv
|   │   └── axi_master_monitor.sv
|   │
|   ├── pkg/
|   │   └── axi_vip_pkg.svh
|   │
|   └── slave/
|       ├── axi_slave_agent.sv
|       ├── axi_slave_bfm.sv
|       ├── axi_slave_bfm.svh
|       ├── axi_slave_driver.sv
|       ├── axi_slave_mem_model.sv
|       └── axi_slave_monitor.sv
|
└── README.txt
```