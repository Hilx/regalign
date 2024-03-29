//
// Copyright (c) 2015 University of Cambridge
// All rights reserved.
//
//
//  File:
//        extmem_pcap_replay_engine_cpu_regs.v
//
//  Module:
//        extmem_pcap_replay_engine_cpu_regs
//
//  Description:
//        This file is automatically generated with the registers towards the CPU/Software
//
// This software was developed by Stanford University and the University of Cambridge Computer Laboratory
// under National Science Foundation under Grant No. CNS-0855268,
// the University of Cambridge Computer Laboratory under EPSRC INTERNET Project EP/H040536/1 and
// by the University of Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-11-C-0249 ("MRC2"),
// as part of the DARPA MRC research programme.
//
// @NETFPGA_LICENSE_HEADER_START@
//
// Licensed to NetFPGA C.I.C. (NetFPGA) under one or more contributor
// license agreements.  See the NOTICE file distributed with this work for
// additional information regarding copyright ownership.  NetFPGA licenses this
// file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
// "License"); you may not use this file except in compliance with the
// License.  You may obtain a copy of the License at:
//
//   http://www.netfpga-cic.org
//
// Unless required by applicable law or agreed to in writing, Work distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations under the License.
//
// @NETFPGA_LICENSE_HEADER_END@
//

`include "extmem_pcap_replay_engine_cpu_regs_defines.v"
module extmem_pcap_replay_engine_cpu_regs #
(
parameter C_BASE_ADDRESS        = 32'h00000000,
parameter C_S_AXI_DATA_WIDTH    = 32,
parameter C_S_AXI_ADDR_WIDTH    = 32
)
(
    // General ports
    input       clk,
    input       resetn,
    // Global Registers
    input       cpu_resetn_soft,
    output reg  resetn_soft,
    output reg  resetn_sync,

   // Register ports
    input      [`REG_CTRL0_BITS]    ip2cpu_ctrl0_reg,
    output reg [`REG_CTRL0_BITS]    cpu2ip_ctrl0_reg,
    input      [`REG_CTRL1_BITS]    ip2cpu_ctrl1_reg,
    output reg [`REG_CTRL1_BITS]    cpu2ip_ctrl1_reg,
    input      [`REG_CTRL2_BITS]    ip2cpu_ctrl2_reg,
    output reg [`REG_CTRL2_BITS]    cpu2ip_ctrl2_reg,
    input      [`REG_CTRL3_BITS]    ip2cpu_ctrl3_reg,
    output reg [`REG_CTRL3_BITS]    cpu2ip_ctrl3_reg,
    input      [`REG_CTRL4_BITS]    ip2cpu_ctrl4_reg,
    output reg [`REG_CTRL4_BITS]    cpu2ip_ctrl4_reg,
    input      [`REG_CTRL5_BITS]    ip2cpu_ctrl5_reg,
    output reg [`REG_CTRL5_BITS]    cpu2ip_ctrl5_reg,
    input      [`REG_CTRL6_BITS]    ip2cpu_ctrl6_reg,
    output reg [`REG_CTRL6_BITS]    cpu2ip_ctrl6_reg,
    input      [`REG_CTRL7_BITS]    ip2cpu_ctrl7_reg,
    output reg [`REG_CTRL7_BITS]    cpu2ip_ctrl7_reg,
    input      [`REG_CTRL8_BITS]    ip2cpu_ctrl8_reg,
    output reg [`REG_CTRL8_BITS]    cpu2ip_ctrl8_reg,
    input      [`REG_CTRL9_BITS]    ip2cpu_ctrl9_reg,
    output reg [`REG_CTRL9_BITS]    cpu2ip_ctrl9_reg,
    input      [`REG_CTRL10_BITS]    ip2cpu_ctrl10_reg,
    output reg [`REG_CTRL10_BITS]    cpu2ip_ctrl10_reg,
    input      [`REG_CTRL11_BITS]    ip2cpu_ctrl11_reg,
    output reg [`REG_CTRL11_BITS]    cpu2ip_ctrl11_reg,
    input      [`REG_CTRL12_BITS]    ip2cpu_ctrl12_reg,
    output reg [`REG_CTRL12_BITS]    cpu2ip_ctrl12_reg,
    input      [`REG_CTRL13_BITS]    ip2cpu_ctrl13_reg,
    output reg [`REG_CTRL13_BITS]    cpu2ip_ctrl13_reg,
    input      [`REG_CTRL14_BITS]    ip2cpu_ctrl14_reg,
    output reg [`REG_CTRL14_BITS]    cpu2ip_ctrl14_reg,
    input      [`REG_CTRL15_BITS]    ip2cpu_ctrl15_reg,
    output reg [`REG_CTRL15_BITS]    cpu2ip_ctrl15_reg,
    input      [`REG_CTRL16_BITS]    ip2cpu_ctrl16_reg,
    output reg [`REG_CTRL16_BITS]    cpu2ip_ctrl16_reg,
    input      [`REG_CTRL17_BITS]    ip2cpu_ctrl17_reg,
    output reg [`REG_CTRL17_BITS]    cpu2ip_ctrl17_reg,
    input      [`REG_CTRL18_BITS]    ip2cpu_ctrl18_reg,
    output reg [`REG_CTRL18_BITS]    cpu2ip_ctrl18_reg,
    input      [`REG_CTRL19_BITS]    ip2cpu_ctrl19_reg,
    output reg [`REG_CTRL19_BITS]    cpu2ip_ctrl19_reg,
    input      [`REG_CTRL20_BITS]    ip2cpu_ctrl20_reg,
    output reg [`REG_CTRL20_BITS]    cpu2ip_ctrl20_reg,
    input      [`REG_CTRL21_BITS]    ip2cpu_ctrl21_reg,
    output reg [`REG_CTRL21_BITS]    cpu2ip_ctrl21_reg,
    input      [`REG_CTRL22_BITS]    ip2cpu_ctrl22_reg,
    output reg [`REG_CTRL22_BITS]    cpu2ip_ctrl22_reg,
    input      [`REG_CTRL23_BITS]    ip2cpu_ctrl23_reg,
    output reg [`REG_CTRL23_BITS]    cpu2ip_ctrl23_reg,
    input      [`REG_CTRL24_BITS]    ip2cpu_ctrl24_reg,
    output reg [`REG_CTRL24_BITS]    cpu2ip_ctrl24_reg,
    input      [`REG_CTRL25_BITS]    ip2cpu_ctrl25_reg,
    output reg [`REG_CTRL25_BITS]    cpu2ip_ctrl25_reg,

    // AXI Lite ports
    input                                     S_AXI_ACLK,
    input                                     S_AXI_ARESETN,
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_AWADDR,
    input                                     S_AXI_AWVALID,
    input      [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_WDATA,
    input      [C_S_AXI_DATA_WIDTH/8-1 : 0]   S_AXI_WSTRB,
    input                                     S_AXI_WVALID,
    input                                     S_AXI_BREADY,
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_ARADDR,
    input                                     S_AXI_ARVALID,
    input                                     S_AXI_RREADY,
    output                                    S_AXI_ARREADY,
    output     [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_RDATA,
    output     [1 : 0]                        S_AXI_RRESP,
    output                                    S_AXI_RVALID,
    output                                    S_AXI_WREADY,
    output     [1 :0]                         S_AXI_BRESP,
    output                                    S_AXI_BVALID,
    output                                    S_AXI_AWREADY

);

    // AXI4LITE signals
    reg [C_S_AXI_ADDR_WIDTH-1 : 0]      axi_awaddr;
    reg                                 axi_awready;
    reg                                 axi_wready;
    reg [1 : 0]                         axi_bresp;
    reg                                 axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0]      axi_araddr;
    reg                                 axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0]      axi_rdata;
    reg [1 : 0]                         axi_rresp;
    reg                                 axi_rvalid;

    reg                                 resetn_sync_d;
    wire                                reg_rden;
    wire                                reg_wren;
    reg [C_S_AXI_DATA_WIDTH-1:0]        reg_data_out;
    integer                             byte_index;

    // I/O Connections assignments
    assign S_AXI_AWREADY    = axi_awready;
    assign S_AXI_WREADY     = axi_wready;
    assign S_AXI_BRESP      = axi_bresp;
    assign S_AXI_BVALID     = axi_bvalid;
    assign S_AXI_ARREADY    = axi_arready;
    assign S_AXI_RDATA      = axi_rdata;
    assign S_AXI_RRESP      = axi_rresp;
    assign S_AXI_RVALID     = axi_rvalid;


    //Sample reset (not mandatory, but good practice)
    always @ (posedge clk) begin
        if (~resetn) begin
            resetn_sync_d  <=  1'b0;
            resetn_sync    <=  1'b0;
        end
        else begin
            resetn_sync_d  <=  resetn;
            resetn_sync    <=  resetn_sync_d;
        end
    end


    //global registers, sampling
    always @(posedge clk) resetn_soft <= #1 cpu_resetn_soft;

    // Implement axi_awready generation

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_awready <= 1'b0;
        end
      else
        begin
          if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
            begin
              // slave is ready to accept write address when
              // there is a valid write address and write data
              // on the write address and data bus. This design
              // expects no outstanding transactions.
              axi_awready <= 1'b1;
            end
          else
            begin
              axi_awready <= 1'b0;
            end
        end
    end

    // Implement axi_awaddr latching

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_awaddr <= 0;
        end
      else
        begin
          if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
            begin
              // Write Address latching
              axi_awaddr <= S_AXI_AWADDR ^ C_BASE_ADDRESS;
            end
        end
    end

    // Implement axi_wready generation

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_wready <= 1'b0;
        end
      else
        begin
          if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)
            begin
              // slave is ready to accept write data when
              // there is a valid write address and write data
              // on the write address and data bus. This design
              // expects no outstanding transactions.
              axi_wready <= 1'b1;
            end
          else
            begin
              axi_wready <= 1'b0;
            end
        end
    end

    // Implement write response logic generation

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_bvalid  <= 0;
          axi_bresp   <= 2'b0;
        end
      else
        begin
          if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
            begin
              // indicates a valid write response is available
              axi_bvalid <= 1'b1;
              axi_bresp  <= 2'b0; // OKAY response
            end                   // work error responses in future
          else
            begin
              if (S_AXI_BREADY && axi_bvalid)
                //check if bready is asserted while bvalid is high)
                //(there is a possibility that bready is always asserted high)
                begin
                  axi_bvalid <= 1'b0;
                end
            end
        end
    end

    // Implement axi_arready generation

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_arready <= 1'b0;
          axi_araddr  <= 32'b0;
        end
      else
        begin
          if (~axi_arready && S_AXI_ARVALID)
            begin
              // indicates that the slave has acceped the valid read address
              // Read address latching
              axi_arready <= 1'b1;
              axi_araddr  <= S_AXI_ARADDR ^ C_BASE_ADDRESS;
            end
          else
            begin
              axi_arready <= 1'b0;
            end
        end
    end


    // Implement axi_rvalid generation

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_rvalid <= 0;
          axi_rresp  <= 0;
        end
      else
        begin
          if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
            begin
              // Valid read data is available at the read data bus
              axi_rvalid <= 1'b1;
              axi_rresp  <= 2'b0; // OKAY response
            end
          else if (axi_rvalid && S_AXI_RREADY)
            begin
              // Read data is accepted by the master
              axi_rvalid <= 1'b0;
            end
        end
    end


    // Implement memory mapped register select and write logic generation

    assign reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

//////////////////////////////////////////////////////////////
// write registers
//////////////////////////////////////////////////////////////


//R/W register, not cleared
    always @(posedge clk) begin
        if (!resetn_sync) begin

            cpu2ip_ctrl0_reg <= #1 `REG_CTRL0_DEFAULT;
            cpu2ip_ctrl1_reg <= #1 `REG_CTRL1_DEFAULT;
            cpu2ip_ctrl2_reg <= #1 `REG_CTRL2_DEFAULT;
            cpu2ip_ctrl3_reg <= #1 `REG_CTRL3_DEFAULT;
            cpu2ip_ctrl4_reg <= #1 `REG_CTRL4_DEFAULT;
            cpu2ip_ctrl5_reg <= #1 `REG_CTRL5_DEFAULT;
            cpu2ip_ctrl6_reg <= #1 `REG_CTRL6_DEFAULT;
            cpu2ip_ctrl7_reg <= #1 `REG_CTRL7_DEFAULT;
            cpu2ip_ctrl8_reg <= #1 `REG_CTRL8_DEFAULT;
            cpu2ip_ctrl9_reg <= #1 `REG_CTRL9_DEFAULT;
            cpu2ip_ctrl10_reg <= #1 `REG_CTRL10_DEFAULT;
            cpu2ip_ctrl11_reg <= #1 `REG_CTRL11_DEFAULT;
            cpu2ip_ctrl12_reg <= #1 `REG_CTRL12_DEFAULT;
            cpu2ip_ctrl13_reg <= #1 `REG_CTRL13_DEFAULT;
            cpu2ip_ctrl14_reg <= #1 `REG_CTRL14_DEFAULT;
            cpu2ip_ctrl15_reg <= #1 `REG_CTRL15_DEFAULT;
            cpu2ip_ctrl16_reg <= #1 `REG_CTRL16_DEFAULT;
            cpu2ip_ctrl17_reg <= #1 `REG_CTRL17_DEFAULT;
            cpu2ip_ctrl18_reg <= #1 `REG_CTRL18_DEFAULT;
            cpu2ip_ctrl19_reg <= #1 `REG_CTRL19_DEFAULT;
            cpu2ip_ctrl20_reg <= #1 `REG_CTRL20_DEFAULT;
            cpu2ip_ctrl21_reg <= #1 `REG_CTRL21_DEFAULT;
            cpu2ip_ctrl22_reg <= #1 `REG_CTRL22_DEFAULT;
            cpu2ip_ctrl23_reg <= #1 `REG_CTRL23_DEFAULT;
            cpu2ip_ctrl24_reg <= #1 `REG_CTRL24_DEFAULT;
            cpu2ip_ctrl25_reg <= #1 `REG_CTRL25_DEFAULT;
        end
        else begin
           if (reg_wren) //write event
            case (axi_awaddr)
            //Ctrl0 Register
                `REG_CTRL0_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL0_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl0_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl1 Register
                `REG_CTRL1_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL1_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl1_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl2 Register
                `REG_CTRL2_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL2_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl2_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl3 Register
                `REG_CTRL3_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL3_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl3_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl4 Register
                `REG_CTRL4_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL4_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl4_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl5 Register
                `REG_CTRL5_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL5_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl5_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl6 Register
                `REG_CTRL6_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL6_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl6_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl7 Register
                `REG_CTRL7_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL7_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl7_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl8 Register
                `REG_CTRL8_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL8_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl8_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl9 Register
                `REG_CTRL9_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL9_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl9_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl10 Register
                `REG_CTRL10_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL10_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl10_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl11 Register
                `REG_CTRL11_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL11_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl11_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl12 Register
                `REG_CTRL12_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL12_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl12_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl13 Register
                `REG_CTRL13_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL13_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl13_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl14 Register
                `REG_CTRL14_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL14_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl14_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl15 Register
                `REG_CTRL15_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL15_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl15_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl16 Register
                `REG_CTRL16_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL16_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl16_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl17 Register
                `REG_CTRL17_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL17_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl17_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl18 Register
                `REG_CTRL18_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL18_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl18_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl19 Register
                `REG_CTRL19_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL19_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl19_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl20 Register
                `REG_CTRL20_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL20_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl20_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl21 Register
                `REG_CTRL21_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL21_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl21_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl22 Register
                `REG_CTRL22_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL22_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl22_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl23 Register
                `REG_CTRL23_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL23_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl23_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl24 Register
                `REG_CTRL24_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL24_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl24_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
            //Ctrl25 Register
                `REG_CTRL25_ADDR : begin
                    for ( byte_index = 0; byte_index <= (`REG_CTRL25_WIDTH/8-1); byte_index = byte_index +1)
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            cpu2ip_ctrl25_reg[byte_index*8 +: 8] <=  S_AXI_WDATA[byte_index*8 +: 8]; //dynamic register;
                        end
                end
                default: begin
                end

            endcase
        end
  end



/////////////////////////
//// end of write
/////////////////////////

    // Implement memory mapped register select and read logic generation
    // Slave register read enable is asserted when valid address is available
    // and the slave is ready to accept the read address.

    // reg_rden control logic
    // temperary no extra logic here
    assign reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;

    always @(*)
    begin

        case ( axi_araddr /*S_AXI_ARADDR ^ C_BASE_ADDRESS*/)
            //Ctrl0 Register
            `REG_CTRL0_ADDR : begin
                reg_data_out [`REG_CTRL0_BITS] =  ip2cpu_ctrl0_reg;
            end
            //Ctrl1 Register
            `REG_CTRL1_ADDR : begin
                reg_data_out [`REG_CTRL1_BITS] =  ip2cpu_ctrl1_reg;
            end
            //Ctrl2 Register
            `REG_CTRL2_ADDR : begin
                reg_data_out [`REG_CTRL2_BITS] =  ip2cpu_ctrl2_reg;
            end
            //Ctrl3 Register
            `REG_CTRL3_ADDR : begin
                reg_data_out [`REG_CTRL3_BITS] =  ip2cpu_ctrl3_reg;
            end
            //Ctrl4 Register
            `REG_CTRL4_ADDR : begin
                reg_data_out [`REG_CTRL4_BITS] =  ip2cpu_ctrl4_reg;
            end
            //Ctrl5 Register
            `REG_CTRL5_ADDR : begin
                reg_data_out [`REG_CTRL5_BITS] =  ip2cpu_ctrl5_reg;
            end
            //Ctrl6 Register
            `REG_CTRL6_ADDR : begin
                reg_data_out [`REG_CTRL6_BITS] =  ip2cpu_ctrl6_reg;
            end
            //Ctrl7 Register
            `REG_CTRL7_ADDR : begin
                reg_data_out [`REG_CTRL7_BITS] =  ip2cpu_ctrl7_reg;
            end
            //Ctrl8 Register
            `REG_CTRL8_ADDR : begin
                reg_data_out [`REG_CTRL8_BITS] =  ip2cpu_ctrl8_reg;
            end
            //Ctrl9 Register
            `REG_CTRL9_ADDR : begin
                reg_data_out [`REG_CTRL9_BITS] =  ip2cpu_ctrl9_reg;
            end
            //Ctrl10 Register
            `REG_CTRL10_ADDR : begin
                reg_data_out [`REG_CTRL10_BITS] =  ip2cpu_ctrl10_reg;
            end
            //Ctrl11 Register
            `REG_CTRL11_ADDR : begin
                reg_data_out [`REG_CTRL11_BITS] =  ip2cpu_ctrl11_reg;
            end
            //Ctrl12 Register
            `REG_CTRL12_ADDR : begin
                reg_data_out [`REG_CTRL12_BITS] =  ip2cpu_ctrl12_reg;
            end
            //Ctrl13 Register
            `REG_CTRL13_ADDR : begin
                reg_data_out [`REG_CTRL13_BITS] =  ip2cpu_ctrl13_reg;
            end
            //Ctrl14 Register
            `REG_CTRL14_ADDR : begin
                reg_data_out [`REG_CTRL14_BITS] =  ip2cpu_ctrl14_reg;
            end
            //Ctrl15 Register
            `REG_CTRL15_ADDR : begin
                reg_data_out [`REG_CTRL15_BITS] =  ip2cpu_ctrl15_reg;
            end
            //Ctrl16 Register
            `REG_CTRL16_ADDR : begin
                reg_data_out [`REG_CTRL16_BITS] =  ip2cpu_ctrl16_reg;
            end
            //Ctrl17 Register
            `REG_CTRL17_ADDR : begin
                reg_data_out [`REG_CTRL17_BITS] =  ip2cpu_ctrl17_reg;
            end
            //Ctrl18 Register
            `REG_CTRL18_ADDR : begin
                reg_data_out [`REG_CTRL18_BITS] =  ip2cpu_ctrl18_reg;
            end
            //Ctrl19 Register
            `REG_CTRL19_ADDR : begin
                reg_data_out [`REG_CTRL19_BITS] =  ip2cpu_ctrl19_reg;
            end
            //Ctrl20 Register
            `REG_CTRL20_ADDR : begin
                reg_data_out [`REG_CTRL20_BITS] =  ip2cpu_ctrl20_reg;
            end
            //Ctrl21 Register
            `REG_CTRL21_ADDR : begin
                reg_data_out [`REG_CTRL21_BITS] =  ip2cpu_ctrl21_reg;
            end
            //Ctrl22 Register
            `REG_CTRL22_ADDR : begin
                reg_data_out [`REG_CTRL22_BITS] =  ip2cpu_ctrl22_reg;
            end
            //Ctrl23 Register
            `REG_CTRL23_ADDR : begin
                reg_data_out [`REG_CTRL23_BITS] =  ip2cpu_ctrl23_reg;
            end
            //Ctrl24 Register
            `REG_CTRL24_ADDR : begin
                reg_data_out [`REG_CTRL24_BITS] =  ip2cpu_ctrl24_reg;
            end
            //Ctrl25 Register
            `REG_CTRL25_ADDR : begin
                reg_data_out [`REG_CTRL25_BITS] =  ip2cpu_ctrl25_reg;
            end
            //Default return value
            default: begin
                reg_data_out [31:0] =  32'hDEADBEEF;
            end

        endcase

    end//end of assigning data to IP2Bus_Data bus

// Output register or memory read data
    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_rdata  <= 0;
        end
      else
        begin
          // When there is a valid read address (S_AXI_ARVALID) with
          // acceptance of read address by the slave (axi_arready),
          // output the read dada
          if (reg_rden)
            begin
              axi_rdata <= reg_data_out/*ip2bus_data*/;     // register read data /* some new changes here */
            end
        end
    end

endmodule
