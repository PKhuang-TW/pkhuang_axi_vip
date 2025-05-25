`ifndef AXI_CONFIG_SV
`define AXI_CONFIG_SV

class axi_config #(
    int ADDR_WIDTH  = axi_package::ADDR_WIDTH,
    int DATA_WIDTH  = axi_package::DATA_WIDTH,
    int ID_WIDTH    = axi_package::ID_WIDTH
) extends uvm_object;
    `uvm_object_param_utils(axi_config)

    typedef axi_config #(ADDR_WIDTH, DATA_WIDTH, ID_WIDTH)   cfg_t;

    // Then we can instance vif_mst & vif_slv in tb_top even if the WIDTH is different
    typedef virtual axi_interface #(
        .ADDR_WIDTH = ADDR_WIDTH,
        .DATA_WIDTH = DATA_WIDTH,
        .ID_WIDTH   = ID_WIDTH
    ) vif_t;

    role_e  role;
    vif_t   vif;

    function new (string name = "axi_config");
        super.new(name);
    endfunction

endclass : axi_config

`endif