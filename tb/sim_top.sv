`timescale 1ps/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "axi_define.svh"
`include "axi_typedef.svh"
import axi_typedef::*;

`include "axi_if.sv"
`include "axi_vip_pkg.svh"
import axi_vip_pkg::*;

module sim_top;

    logic   clk, rst_n;
    axi_if  vif();

    always #5 clk = ~clk;

    assign vif.ACLK = clk;
    assign vif.ARESETn = rst_n;

    initial begin
        run_test();
    end

    initial begin

        uvm_config_db #(virtual axi_if) :: set (null, "*", "vif", vif);
        uvm_config_db #(virtual axi_if.mst_if) :: set (null, "*", "vif.mst_if", vif.mst_if);
        uvm_config_db #(virtual axi_if.slv_if) :: set (null, "*", "vif.slv_if", vif.slv_if);
        uvm_config_db #(virtual axi_if.mon_if) :: set (null, "*", "vif.mon_if", vif.mon_if);

        clk     = 0;
        rst_n   = 0;

        #10;
        rst_n   = 1;
    end

    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars;
    end
    
endmodule