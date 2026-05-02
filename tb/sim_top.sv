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
        // uvm_config_db #(virtual `D_MST_IF) :: set (null, "*", "vif.mst_cb", vif.mst_cb);
        // uvm_config_db #(virtual `D_SLV_IF) :: set (null, "*", "vif.slv_cb", vif.slv_cb);
        // uvm_config_db #(virtual `D_MON_IF) :: set (null, "*", "vif.mon_cb", vif.mon_cb);

        clk     = 0;
        rst_n   = 0;

        #10;
        rst_n   = 1;
    end

    // initial begin
    //     $fsdbDumpfile("wave.fsdb");
    //     $fsdbDumpvars;
    // end
    
endmodule