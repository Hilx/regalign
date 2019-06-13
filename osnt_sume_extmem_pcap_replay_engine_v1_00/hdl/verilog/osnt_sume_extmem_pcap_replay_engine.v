//
// Copyright (c) 2017 University of Cambridge
// Copyright (c) 2017 Jong Hun Han
// All rights reserved.
//
// This software was developed by University of Cambridge Computer Laboratory
// under the ENDEAVOUR project (grant agreement 644960) as part of
// the European Union's Horizon 2020 research and innovation programme.
//
// @NETFPGA_LICENSE_HEADER_START@
//
// Licensed to NetFPGA Open Systems C.I.C. (NetFPGA) under one or more
// contributor license agreements. See the NOTICE file distributed with this
// work for additional information regarding copyright ownership. NetFPGA
// licenses this file to you under the NetFPGA Hardware-Software License,
// Version 1.0 (the License); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at:
//
// http://www.netfpga-cic.org
//
// Unless required by applicable law or agreed to in writing, Work distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// @NETFPGA_LICENSE_HEADER_END@


`timescale 1ns/1ps

module osnt_sume_extmem_pcap_replay_engine
#(
   parameter   C_S_AXI_DATA_WIDTH   = 32,
   parameter   C_S_AXI_ADDR_WIDTH   = 32,
   parameter   C_BASEADDR           = 32'hFFFFFFFF,
   parameter   C_HIGHADDR           = 32'h00000000,
   parameter   C_USE_WSTRB          = 0,
   parameter   C_DPHASE_TIMEOUT     = 0,
   parameter   C_S_AXI_ACLK_FREQ_HZ = 100,
   parameter   C_M_AXIS_DATA_WIDTH  = 256,
   parameter   C_S_AXIS_DATA_WIDTH  = 256,
   parameter   C_M_AXIS_TUSER_WIDTH = 128,
   parameter   C_S_AXIS_TUSER_WIDTH = 128,
   parameter   SRC_PORT_POS         = 16,
   parameter   NUM_QUEUES           = 4,
   parameter   MEM_DEPTH            = 20 
)
(
   // Slave AXI Ports
   input                                                 s_axi_aclk,
   input                                                 s_axi_aresetn,
   input          [C_S_AXI_ADDR_WIDTH-1:0]               s_axi_awaddr,
   input                                                 s_axi_awvalid,
   input          [C_S_AXI_DATA_WIDTH-1:0]               s_axi_wdata,
   input          [C_S_AXI_DATA_WIDTH/8-1:0]             s_axi_wstrb,
   input                                                 s_axi_wvalid,
   input                                                 s_axi_bready,
   input          [C_S_AXI_ADDR_WIDTH-1:0]               s_axi_araddr,
   input                                                 s_axi_arvalid,
   input                                                 s_axi_rready,
   output                                                s_axi_arready,
   output         [C_S_AXI_DATA_WIDTH-1:0]               s_axi_rdata,
   output         [1:0]                                  s_axi_rresp,
   output                                                s_axi_rvalid,
   output                                                s_axi_wready,
   output         [1:0]                                  s_axi_bresp,
   output                                                s_axi_bvalid,
   output                                                s_axi_awready,

   // Master Stream Ports (interface to data path)
   input                                                 axis_aclk,
   input                                                 axis_aresetn,

   output         [C_M_AXIS_DATA_WIDTH-1:0]              m0_axis_tdata,
   output         [((C_M_AXIS_DATA_WIDTH/8))-1:0]        m0_axis_tkeep,
   output         [C_M_AXIS_TUSER_WIDTH-1:0]             m0_axis_tuser,
   output                                                m0_axis_tvalid,
   input                                                 m0_axis_tready,
   output                                                m0_axis_tlast,

   output         [C_M_AXIS_DATA_WIDTH-1:0]              m1_axis_tdata,
   output         [((C_M_AXIS_DATA_WIDTH/8))-1:0]        m1_axis_tkeep,
   output         [C_M_AXIS_TUSER_WIDTH-1:0]             m1_axis_tuser,
   output                                                m1_axis_tvalid,
   input                                                 m1_axis_tready,
   output                                                m1_axis_tlast,

   output         [C_M_AXIS_DATA_WIDTH-1:0]              m2_axis_tdata,
   output         [((C_M_AXIS_DATA_WIDTH/8))-1:0]        m2_axis_tkeep,
   output         [C_M_AXIS_TUSER_WIDTH-1:0]             m2_axis_tuser,
   output                                                m2_axis_tvalid,
   input                                                 m2_axis_tready,
   output                                                m2_axis_tlast,

   output         [C_M_AXIS_DATA_WIDTH-1:0]              m3_axis_tdata,
   output         [((C_M_AXIS_DATA_WIDTH/8))-1:0]        m3_axis_tkeep,
   output         [C_M_AXIS_TUSER_WIDTH-1:0]             m3_axis_tuser,
   output                                                m3_axis_tvalid,
   input                                                 m3_axis_tready,
   output                                                m3_axis_tlast,

   // Slave Stream Ports (interface to RX queues)
   input          [C_S_AXIS_DATA_WIDTH-1:0]              s_axis_tdata,
   input          [((C_S_AXIS_DATA_WIDTH/8))-1:0]        s_axis_tkeep,
   input          [C_S_AXIS_TUSER_WIDTH-1:0]             s_axis_tuser,
   input                                                 s_axis_tvalid,
   output                                                s_axis_tready,
   input                                                 s_axis_tlast,

   // External Memory Stream Ports (interface to RX queues)
   output         [C_M_AXIS_DATA_WIDTH-1:0]              m00_axis_tdata,
   output         [((C_M_AXIS_DATA_WIDTH/8))-1:0]        m00_axis_tkeep,
   output         [C_M_AXIS_TUSER_WIDTH-1:0]             m00_axis_tuser,
   output                                                m00_axis_tvalid,
   input                                                 m00_axis_tready,
   output                                                m00_axis_tlast,

   input          [C_S_AXIS_DATA_WIDTH-1:0]              s00_axis_tdata,
   input          [((C_S_AXIS_DATA_WIDTH/8))-1:0]        s00_axis_tkeep,
   input          [C_S_AXIS_TUSER_WIDTH-1:0]             s00_axis_tuser,
   input                                                 s00_axis_tvalid,
   output                                                s00_axis_tready,
   input                                                 s00_axis_tlast,

   output         [C_M_AXIS_DATA_WIDTH-1:0]              m01_axis_tdata,
   output         [((C_M_AXIS_DATA_WIDTH/8))-1:0]        m01_axis_tkeep,
   output         [C_M_AXIS_TUSER_WIDTH-1:0]             m01_axis_tuser,
   output                                                m01_axis_tvalid,
   input                                                 m01_axis_tready,
   output                                                m01_axis_tlast,

   input          [C_S_AXIS_DATA_WIDTH-1:0]              s01_axis_tdata,
   input          [((C_S_AXIS_DATA_WIDTH/8))-1:0]        s01_axis_tkeep,
   input          [C_S_AXIS_TUSER_WIDTH-1:0]             s01_axis_tuser,
   input                                                 s01_axis_tvalid,
   output                                                s01_axis_tready,
   input                                                 s01_axis_tlast,

   output         [C_M_AXIS_DATA_WIDTH-1:0]              m02_axis_tdata,
   output         [((C_M_AXIS_DATA_WIDTH/8))-1:0]        m02_axis_tkeep,
   output         [C_M_AXIS_TUSER_WIDTH-1:0]             m02_axis_tuser,
   output                                                m02_axis_tvalid,
   input                                                 m02_axis_tready,
   output                                                m02_axis_tlast,

   input          [C_S_AXIS_DATA_WIDTH-1:0]              s02_axis_tdata,
   input          [((C_S_AXIS_DATA_WIDTH/8))-1:0]        s02_axis_tkeep,
   input          [C_S_AXIS_TUSER_WIDTH-1:0]             s02_axis_tuser,
   input                                                 s02_axis_tvalid,
   output                                                s02_axis_tready,
   input                                                 s02_axis_tlast,

   output         [C_M_AXIS_DATA_WIDTH-1:0]              m03_axis_tdata,
   output         [((C_M_AXIS_DATA_WIDTH/8))-1:0]        m03_axis_tkeep,
   output         [C_M_AXIS_TUSER_WIDTH-1:0]             m03_axis_tuser,
   output                                                m03_axis_tvalid,
   input                                                 m03_axis_tready,
   output                                                m03_axis_tlast,

   input          [C_S_AXIS_DATA_WIDTH-1:0]              s03_axis_tdata,
   input          [((C_S_AXIS_DATA_WIDTH/8))-1:0]        s03_axis_tkeep,
   input          [C_S_AXIS_TUSER_WIDTH-1:0]             s03_axis_tuser,
   input                                                 s03_axis_tvalid,
   output                                                s03_axis_tready,
   input                                                 s03_axis_tlast,

   output                                                sw_rst,
   
   output                                                q0_start_replay,
   output                                                q1_start_replay,
   output                                                q2_start_replay,
   output                                                q3_start_replay,
   
   output         [C_S_AXI_DATA_WIDTH-1:0]               q0_replay_count,
   output         [C_S_AXI_DATA_WIDTH-1:0]               q1_replay_count,
   output         [C_S_AXI_DATA_WIDTH-1:0]               q2_replay_count,
   output         [C_S_AXI_DATA_WIDTH-1:0]               q3_replay_count,

   output                                                q0_wr_done,
   output                                                q1_wr_done,
   output                                                q2_wr_done,
   output                                                q3_wr_done
);

// -- Internal Parameters
localparam NUM_RW_REGS = 26;
localparam NUM_WO_REGS = 0;
localparam NUM_RO_REGS = 0;

// -- Signals
wire  [NUM_RW_REGS*C_S_AXI_DATA_WIDTH:0]           rw_regs;
 
wire  [C_S_AXI_DATA_WIDTH-1:0]                     q0_addr_low;
wire  [C_S_AXI_DATA_WIDTH-1:0]                     q0_addr_high;
wire  [C_S_AXI_DATA_WIDTH-1:0]                     q1_addr_low;
wire  [C_S_AXI_DATA_WIDTH-1:0]                     q1_addr_high;
wire  [C_S_AXI_DATA_WIDTH-1:0]                     q2_addr_low;
wire  [C_S_AXI_DATA_WIDTH-1:0]                     q2_addr_high;
wire  [C_S_AXI_DATA_WIDTH-1:0]                     q3_addr_low;
wire  [C_S_AXI_DATA_WIDTH-1:0]                     q3_addr_high;
                                                  
wire                                               q0_enable;
wire                                               q1_enable;
wire                                               q2_enable;
wire                                               q3_enable;
                                                  
wire  [C_S_AXI_DATA_WIDTH-1:0]                     conf_path;

wire  [C_S_AXIS_DATA_WIDTH-1:0]                    m_pre_axis_tdata;
wire  [((C_S_AXIS_DATA_WIDTH/8))-1:0]              m_pre_axis_tkeep;
wire  [C_S_AXIS_TUSER_WIDTH-1:0]                   m_pre_axis_tuser;
wire                                               m_pre_axis_tvalid;
wire                                               m_pre_axis_tready;
wire                                               m_pre_axis_tlast;

// -------------------------
    wire  [`REG_CTRL0_BITS]    ip2cpu_ctrl0_reg;
    wire  [`REG_CTRL0_BITS]    cpu2ip_ctrl0_reg;
    wire  [`REG_CTRL1_BITS]    ip2cpu_ctrl1_reg;
    wire  [`REG_CTRL1_BITS]    cpu2ip_ctrl1_reg;
    wire  [`REG_CTRL2_BITS]    ip2cpu_ctrl2_reg;
    wire  [`REG_CTRL2_BITS]    cpu2ip_ctrl2_reg;
    wire  [`REG_CTRL3_BITS]    ip2cpu_ctrl3_reg;
    wire  [`REG_CTRL3_BITS]    cpu2ip_ctrl3_reg;
    wire  [`REG_CTRL4_BITS]    ip2cpu_ctrl4_reg;
    wire  [`REG_CTRL4_BITS]    cpu2ip_ctrl4_reg;
    wire  [`REG_CTRL5_BITS]    ip2cpu_ctrl5_reg;
    wire  [`REG_CTRL5_BITS]    cpu2ip_ctrl5_reg;
    wire  [`REG_CTRL6_BITS]    ip2cpu_ctrl6_reg;
    wire  [`REG_CTRL6_BITS]    cpu2ip_ctrl6_reg;
    wire  [`REG_CTRL7_BITS]    ip2cpu_ctrl7_reg;
    wire  [`REG_CTRL7_BITS]    cpu2ip_ctrl7_reg;
    wire  [`REG_CTRL8_BITS]    ip2cpu_ctrl8_reg;
    wire  [`REG_CTRL8_BITS]    cpu2ip_ctrl8_reg;
    wire  [`REG_CTRL9_BITS]    ip2cpu_ctrl9_reg;
    wire  [`REG_CTRL9_BITS]    cpu2ip_ctrl9_reg;
    wire [`REG_CTRL10_BITS]    ip2cpu_ctrl10_reg;
    wire [`REG_CTRL10_BITS]    cpu2ip_ctrl10_reg;
    wire [`REG_CTRL11_BITS]    ip2cpu_ctrl11_reg;
    wire [`REG_CTRL11_BITS]    cpu2ip_ctrl11_reg;
    wire [`REG_CTRL12_BITS]    ip2cpu_ctrl12_reg;
    wire [`REG_CTRL12_BITS]    cpu2ip_ctrl12_reg;
    wire [`REG_CTRL13_BITS]    ip2cpu_ctrl13_reg;
    wire [`REG_CTRL13_BITS]    cpu2ip_ctrl13_reg;
    wire [`REG_CTRL14_BITS]    ip2cpu_ctrl14_reg;
    wire [`REG_CTRL14_BITS]    cpu2ip_ctrl14_reg;
    wire [`REG_CTRL15_BITS]    ip2cpu_ctrl15_reg;
    wire [`REG_CTRL15_BITS]    cpu2ip_ctrl15_reg;
    wire [`REG_CTRL16_BITS]    ip2cpu_ctrl16_reg;
    wire [`REG_CTRL16_BITS]    cpu2ip_ctrl16_reg;
    wire [`REG_CTRL17_BITS]    ip2cpu_ctrl17_reg;
    wire [`REG_CTRL17_BITS]    cpu2ip_ctrl17_reg;
    wire [`REG_CTRL18_BITS]    ip2cpu_ctrl18_reg;
    wire [`REG_CTRL18_BITS]    cpu2ip_ctrl18_reg;
    wire [`REG_CTRL19_BITS]    ip2cpu_ctrl19_reg;
    wire [`REG_CTRL19_BITS]    cpu2ip_ctrl19_reg;
    wire [`REG_CTRL20_BITS]    ip2cpu_ctrl20_reg;
    wire [`REG_CTRL20_BITS]    cpu2ip_ctrl20_reg;
    wire [`REG_CTRL21_BITS]    ip2cpu_ctrl21_reg;
    wire [`REG_CTRL21_BITS]    cpu2ip_ctrl21_reg;
    wire [`REG_CTRL22_BITS]    ip2cpu_ctrl22_reg;
    wire [`REG_CTRL22_BITS]    cpu2ip_ctrl22_reg;
    wire [`REG_CTRL23_BITS]    ip2cpu_ctrl23_reg;
    wire [`REG_CTRL23_BITS]    cpu2ip_ctrl23_reg;
    wire [`REG_CTRL24_BITS]    ip2cpu_ctrl24_reg;
    wire [`REG_CTRL24_BITS]    cpu2ip_ctrl24_reg;
    wire [`REG_CTRL25_BITS]    ip2cpu_ctrl25_reg;
    wire [`REG_CTRL25_BITS]    cpu2ip_ctrl25_reg;

// -------------------------    
    assign cpu2ip_ctrl0_reg  = ip2cpu_ctrl0_reg;
    assign cpu2ip_ctrl1_reg  = ip2cpu_ctrl1_reg;
    assign cpu2ip_ctrl2_reg  = ip2cpu_ctrl2_reg;
    assign cpu2ip_ctrl3_reg  = ip2cpu_ctrl3_reg;
    assign cpu2ip_ctrl4_reg  = ip2cpu_ctrl4_reg;
    assign cpu2ip_ctrl5_reg  = ip2cpu_ctrl5_reg;
    assign cpu2ip_ctrl6_reg  = ip2cpu_ctrl6_reg;
    assign cpu2ip_ctrl7_reg  = ip2cpu_ctrl7_reg;
    assign cpu2ip_ctrl8_reg  = ip2cpu_ctrl8_reg;
    assign cpu2ip_ctrl9_reg  = ip2cpu_ctrl9_reg;
    assign cpu2ip_ctrl10_reg = ip2cpu_ctrl10_reg;
    assign cpu2ip_ctrl11_reg = ip2cpu_ctrl11_reg;
    assign cpu2ip_ctrl12_reg = ip2cpu_ctrl12_reg;
    assign cpu2ip_ctrl13_reg = ip2cpu_ctrl13_reg;
    assign cpu2ip_ctrl14_reg = ip2cpu_ctrl14_reg;
    assign cpu2ip_ctrl15_reg = ip2cpu_ctrl15_reg;
    assign cpu2ip_ctrl16_reg = ip2cpu_ctrl16_reg;
    assign cpu2ip_ctrl17_reg = ip2cpu_ctrl17_reg;
    assign cpu2ip_ctrl18_reg = ip2cpu_ctrl18_reg;
    assign cpu2ip_ctrl19_reg = ip2cpu_ctrl19_reg;
    assign cpu2ip_ctrl20_reg = ip2cpu_ctrl20_reg;
    assign cpu2ip_ctrl21_reg = ip2cpu_ctrl21_reg;
    assign cpu2ip_ctrl22_reg = ip2cpu_ctrl22_reg;
    assign cpu2ip_ctrl23_reg = ip2cpu_ctrl23_reg;
    assign cpu2ip_ctrl24_reg = ip2cpu_ctrl24_reg;
    assign cpu2ip_ctrl25_reg = ip2cpu_ctrl25_reg;

    assign rw_regs[C_S_AXI_DATA_WIDTH * 1 - 1: C_S_AXI_DATA_WIDTH * 0]   = ip2cpu_ctrl0_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 2 - 1: C_S_AXI_DATA_WIDTH * 1]   = ip2cpu_ctrl1_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 3 - 1: C_S_AXI_DATA_WIDTH * 2]   = ip2cpu_ctrl2_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 4 - 1: C_S_AXI_DATA_WIDTH * 3]   = ip2cpu_ctrl3_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 5 - 1: C_S_AXI_DATA_WIDTH * 4]   = ip2cpu_ctrl4_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 6 - 1: C_S_AXI_DATA_WIDTH * 5]   = ip2cpu_ctrl5_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 7 - 1: C_S_AXI_DATA_WIDTH * 6]   = ip2cpu_ctrl6_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 8 - 1: C_S_AXI_DATA_WIDTH * 7]   = ip2cpu_ctrl7_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 9 - 1: C_S_AXI_DATA_WIDTH * 8]   = ip2cpu_ctrl8_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 10 - 1: C_S_AXI_DATA_WIDTH * 9]  = ip2cpu_ctrl9_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 11 - 1: C_S_AXI_DATA_WIDTH * 10] = ip2cpu_ctrl10_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 12 - 1: C_S_AXI_DATA_WIDTH * 11] = ip2cpu_ctrl11_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 13 - 1: C_S_AXI_DATA_WIDTH * 12] = ip2cpu_ctrl12_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 14 - 1: C_S_AXI_DATA_WIDTH * 13] = ip2cpu_ctrl13_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 15 - 1: C_S_AXI_DATA_WIDTH * 14] = ip2cpu_ctrl14_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 16 - 1: C_S_AXI_DATA_WIDTH * 15] = ip2cpu_ctrl15_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 17 - 1: C_S_AXI_DATA_WIDTH * 16] = ip2cpu_ctrl16_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 18 - 1: C_S_AXI_DATA_WIDTH * 17] = ip2cpu_ctrl17_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 19 - 1: C_S_AXI_DATA_WIDTH * 18] = ip2cpu_ctrl18_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 20 - 1: C_S_AXI_DATA_WIDTH * 19] = ip2cpu_ctrl19_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 21 - 1: C_S_AXI_DATA_WIDTH * 20] = ip2cpu_ctrl20_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 22 - 1: C_S_AXI_DATA_WIDTH * 21] = ip2cpu_ctrl21_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 23 - 1: C_S_AXI_DATA_WIDTH * 22] = ip2cpu_ctrl22_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 24 - 1: C_S_AXI_DATA_WIDTH * 23] = ip2cpu_ctrl23_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 25 - 1: C_S_AXI_DATA_WIDTH * 24] = ip2cpu_ctrl24_reg;
    assign rw_regs[C_S_AXI_DATA_WIDTH * 26 - 1: C_S_AXI_DATA_WIDTH * 25] = ip2cpu_ctrl25_reg;
// -------------------------
extmem_pcap_replay_engine_cpu_regs #
(
    .C_BASE_ADDRESS(32'h00000000),
    .C_S_AXI_DATA_WIDTH(32),
    .C_S_AXI_ADDR_WIDTH(32)
)
(
    // General ports
    .clk(),
    .resetn(),
    // Global Registers
    .cpu_resetn_soft(),
    .resetn_soft(),
    .resetn_sync(),

   // Register ports
    .ip2cpu_ctrl0_reg(ip2cpu_ctrl0_reg),
    .cpu2ip_ctrl0_reg(cpu2ip_ctrl0_reg),
    .ip2cpu_ctrl1_reg(ip2cpu_ctrl1_reg),
    .cpu2ip_ctrl1_reg(cpu2ip_ctrl1_reg),
    .ip2cpu_ctrl2_reg(ip2cpu_ctrl2_reg),
    .cpu2ip_ctrl2_reg(cpu2ip_ctrl2_reg),
    .ip2cpu_ctrl3_reg(ip2cpu_ctrl3_reg),
    .cpu2ip_ctrl3_reg(cpu2ip_ctrl3_reg),
    .ip2cpu_ctrl4_reg(ip2cpu_ctrl4_reg),
    .cpu2ip_ctrl4_reg(cpu2ip_ctrl4_reg),
    .ip2cpu_ctrl5_reg(ip2cpu_ctrl5_reg),
    .cpu2ip_ctrl5_reg(cpu2ip_ctrl5_reg),
    .ip2cpu_ctrl6_reg(ip2cpu_ctrl6_reg),
    .cpu2ip_ctrl6_reg(cpu2ip_ctrl6_reg),
    .ip2cpu_ctrl7_reg(ip2cpu_ctrl7_reg),
    .cpu2ip_ctrl7_reg(cpu2ip_ctrl7_reg),
    .ip2cpu_ctrl8_reg(ip2cpu_ctrl8_reg),
    .cpu2ip_ctrl8_reg(cpu2ip_ctrl8_reg),
    .ip2cpu_ctrl9_reg(ip2cpu_ctrl9_reg),
    .cpu2ip_ctrl9_reg(cpu2ip_ctrl9_reg),
    .ip2cpu_ctrl10_reg(ip2cpu_ctrl10_reg),
    .cpu2ip_ctrl10_reg(cpu2ip_ctrl10_reg),
    .ip2cpu_ctrl11_reg(ip2cpu_ctrl11_reg),
    .cpu2ip_ctrl11_reg(cpu2ip_ctrl11_reg),
    .ip2cpu_ctrl12_reg(ip2cpu_ctrl12_reg),
    .cpu2ip_ctrl12_reg(cpu2ip_ctrl12_reg),
    .ip2cpu_ctrl13_reg(ip2cpu_ctrl13_reg),
    .cpu2ip_ctrl13_reg(cpu2ip_ctrl13_reg),
    .ip2cpu_ctrl14_reg(ip2cpu_ctrl14_reg),
    .cpu2ip_ctrl14_reg(cpu2ip_ctrl14_reg),
    .ip2cpu_ctrl15_reg(ip2cpu_ctrl15_reg),
    .cpu2ip_ctrl15_reg(cpu2ip_ctrl15_reg),
    .ip2cpu_ctrl16_reg(ip2cpu_ctrl16_reg),
    .cpu2ip_ctrl16_reg(cpu2ip_ctrl16_reg),
    .ip2cpu_ctrl17_reg(ip2cpu_ctrl17_reg),
    .cpu2ip_ctrl17_reg(cpu2ip_ctrl17_reg),
    .ip2cpu_ctrl18_reg(ip2cpu_ctrl18_reg),
    .cpu2ip_ctrl18_reg(cpu2ip_ctrl18_reg),
    .ip2cpu_ctrl19_reg(ip2cpu_ctrl19_reg),
    .cpu2ip_ctrl19_reg(cpu2ip_ctrl19_reg),
    .ip2cpu_ctrl20_reg(ip2cpu_ctrl20_reg),
    .cpu2ip_ctrl20_reg(cpu2ip_ctrl20_reg),
    .ip2cpu_ctrl21_reg(ip2cpu_ctrl21_reg),
    .cpu2ip_ctrl21_reg(cpu2ip_ctrl21_reg),
    .ip2cpu_ctrl22_reg(ip2cpu_ctrl22_reg),
    .cpu2ip_ctrl22_reg(cpu2ip_ctrl22_reg),
    .ip2cpu_ctrl23_reg(ip2cpu_ctrl23_reg),
    .cpu2ip_ctrl23_reg(cpu2ip_ctrl23_reg),
    .ip2cpu_ctrl24_reg(ip2cpu_ctrl24_reg),
    .cpu2ip_ctrl24_reg(cpu2ip_ctrl24_reg),
    .ip2cpu_ctrl25_reg(ip2cpu_ctrl25_reg),
    .cpu2ip_ctrl25_reg(cpu2ip_ctrl25_reg),

    // AXI Lite ports
    .S_AXI_ACLK(s_axi_aclk),
    .S_AXI_ARESETN(s_axi_aresetn),
    .S_AXI_AWADDR(s_axi_awaddr),
    .S_AXI_AWVALID(s_axi_awvalid),
    .S_AXI_WDATA(s_axi_wdata),
    .S_AXI_WSTRB(s_axi_wstrb),
    .S_AXI_WVALID(s_axi_wvalid),
    .S_AXI_BREADY(s_axi_bready),
    .S_AXI_ARADDR(s_axi_araddr),
    .S_AXI_ARVALID(s_axi_arvalid),
    .S_AXI_RREADY(s_axi_rready),
    .S_AXI_ARREADY(s_axi_arready),
    .S_AXI_RDATA(s_axi_rdata),
    .S_AXI_RRESP(s_axi_rresp),
    .S_AXI_RVALID(s_axi_rvalid),
    .S_AXI_WREADY(s_axi_wready),
    .S_AXI_BRESP(s_axi_bresp),
    .S_AXI_BVALID(s_axi_bvalid),
    .S_AXI_AWREADY(s_axi_awready)
);









// -------------------------

pre_pcap_mem_store
#(
   .C_M_AXIS_DATA_WIDTH       (  C_M_AXIS_DATA_WIDTH     ),
   .C_S_AXIS_DATA_WIDTH       (  C_S_AXIS_DATA_WIDTH     ),
   .C_M_AXIS_TUSER_WIDTH      (  C_M_AXIS_TUSER_WIDTH    ),
   .C_S_AXIS_TUSER_WIDTH      (  C_S_AXIS_TUSER_WIDTH    )
)
pre_pcap_mem_store
(
   .axis_aclk                 (  axis_aclk               ),
   .axis_aresetn              (  axis_aresetn            ),

   //Master Stream Ports to external memory for pcap storing
   .m_axis_tdata              (  m_pre_axis_tdata        ),
   .m_axis_tkeep              (  m_pre_axis_tkeep        ),
   .m_axis_tuser              (  m_pre_axis_tuser        ),
   .m_axis_tvalid             (  m_pre_axis_tvalid       ),
   .m_axis_tready             (  m_pre_axis_tready       ),
   .m_axis_tlast              (  m_pre_axis_tlast        ),
             
   //Slave Stream Ports from host over DMA 
   .s_axis_tdata              (  s_axis_tdata            ),
   .s_axis_tkeep              (  s_axis_tkeep            ),
   .s_axis_tuser              (  s_axis_tuser            ),
   .s_axis_tvalid             (  s_axis_tvalid           ),
   .s_axis_tready             (  s_axis_tready           ),
   .s_axis_tlast              (  s_axis_tlast            )
);

pcap_mem_store
#(
   .C_M_AXIS_DATA_WIDTH       (  C_M_AXIS_DATA_WIDTH     ),
   .C_S_AXIS_DATA_WIDTH       (  C_S_AXIS_DATA_WIDTH     ),
   .C_M_AXIS_TUSER_WIDTH      (  C_M_AXIS_TUSER_WIDTH    ),
   .C_S_AXIS_TUSER_WIDTH      (  C_S_AXIS_TUSER_WIDTH    ),
   .SRC_PORT_POS              (  SRC_PORT_POS            ),
   .NUM_QUEUES                (  NUM_QUEUES              )
)
pcap_mem_store
(
   .axis_aclk                 (  axis_aclk               ),
   .axis_aresetn              (  axis_aresetn            ),

   //Master Stream Ports to external memory for pcap storing
   .m0_axis_tdata             (  m00_axis_tdata          ),
   .m0_axis_tkeep             (  m00_axis_tkeep          ),
   .m0_axis_tuser             (  m00_axis_tuser          ),
   .m0_axis_tvalid            (  m00_axis_tvalid         ),
   .m0_axis_tready            (  m00_axis_tready         ),
   .m0_axis_tlast             (  m00_axis_tlast          ),
             
   .m1_axis_tdata             (  m01_axis_tdata          ),
   .m1_axis_tkeep             (  m01_axis_tkeep          ),
   .m1_axis_tuser             (  m01_axis_tuser          ),
   .m1_axis_tvalid            (  m01_axis_tvalid         ),
   .m1_axis_tready            (  m01_axis_tready         ),
   .m1_axis_tlast             (  m01_axis_tlast          ),

   .m2_axis_tdata             (  m02_axis_tdata          ),
   .m2_axis_tkeep             (  m02_axis_tkeep          ),
   .m2_axis_tuser             (  m02_axis_tuser          ),
   .m2_axis_tvalid            (  m02_axis_tvalid         ),
   .m2_axis_tready            (  m02_axis_tready         ),
   .m2_axis_tlast             (  m02_axis_tlast          ),

   .m3_axis_tdata             (  m03_axis_tdata          ),
   .m3_axis_tkeep             (  m03_axis_tkeep          ),
   .m3_axis_tuser             (  m03_axis_tuser          ),
   .m3_axis_tvalid            (  m03_axis_tvalid         ),
   .m3_axis_tready            (  m03_axis_tready         ),
   .m3_axis_tlast             (  m03_axis_tlast          ),

   //Slave Stream Ports from host over DMA 
   .s_axis_tdata              (  m_pre_axis_tdata        ),
   .s_axis_tkeep              (  m_pre_axis_tkeep        ),
   .s_axis_tuser              (  m_pre_axis_tuser        ),
   .s_axis_tvalid             (  m_pre_axis_tvalid       ),
   .s_axis_tready             (  m_pre_axis_tready       ),
   .s_axis_tlast              (  m_pre_axis_tlast        )
);

pcap_mem_replay
#(
   .C_M_AXIS_DATA_WIDTH       (  C_M_AXIS_DATA_WIDTH     ),
   .C_S_AXIS_DATA_WIDTH       (  C_S_AXIS_DATA_WIDTH     ),
   .C_M_AXIS_TUSER_WIDTH      (  C_M_AXIS_TUSER_WIDTH    ),
   .C_S_AXIS_TUSER_WIDTH      (  C_S_AXIS_TUSER_WIDTH    ),
   .NUM_QUEUES                (  NUM_QUEUES              )
)
pcap_mem_replay
(
   // Master Stream Ports (interface to data path)
   .axis_aclk                 (  axis_aclk               ),
   .axis_aresetn              (  axis_aresetn            ),
                                             
   .sw_rst                    (  sw_rst                  ),

   //Master to pipeline
   .m0_axis_tdata             (  m0_axis_tdata           ),
   .m0_axis_tkeep             (  m0_axis_tkeep           ),
   .m0_axis_tuser             (  m0_axis_tuser           ),
   .m0_axis_tvalid            (  m0_axis_tvalid          ),
   .m0_axis_tready            (  m0_axis_tready          ),
   .m0_axis_tlast             (  m0_axis_tlast           ),
                                                
   .m1_axis_tdata             (  m1_axis_tdata           ),
   .m1_axis_tkeep             (  m1_axis_tkeep           ),
   .m1_axis_tuser             (  m1_axis_tuser           ),
   .m1_axis_tvalid            (  m1_axis_tvalid          ),
   .m1_axis_tready            (  m1_axis_tready          ),
   .m1_axis_tlast             (  m1_axis_tlast           ),
                                                
   .m2_axis_tdata             (  m2_axis_tdata           ),
   .m2_axis_tkeep             (  m2_axis_tkeep           ),
   .m2_axis_tuser             (  m2_axis_tuser           ),
   .m2_axis_tvalid            (  m2_axis_tvalid          ),
   .m2_axis_tready            (  m2_axis_tready          ),
   .m2_axis_tlast             (  m2_axis_tlast           ),
                                                
   .m3_axis_tdata             (  m3_axis_tdata           ),
   .m3_axis_tkeep             (  m3_axis_tkeep           ),
   .m3_axis_tuser             (  m3_axis_tuser           ),
   .m3_axis_tvalid            (  m3_axis_tvalid          ),
   .m3_axis_tready            (  m3_axis_tready          ),
   .m3_axis_tlast             (  m3_axis_tlast           ),

   //Slave from external Memory Stream Ports
   .s0_axis_tdata             (  s00_axis_tdata          ),
   .s0_axis_tkeep             (  s00_axis_tkeep          ),
   .s0_axis_tuser             (  s00_axis_tuser          ),
   .s0_axis_tvalid            (  s00_axis_tvalid         ),
   .s0_axis_tready            (  s00_axis_tready         ),
   .s0_axis_tlast             (  s00_axis_tlast          ),
              
   .s1_axis_tdata             (  s01_axis_tdata          ),
   .s1_axis_tkeep             (  s01_axis_tkeep          ),
   .s1_axis_tuser             (  s01_axis_tuser          ),
   .s1_axis_tvalid            (  s01_axis_tvalid         ),
   .s1_axis_tready            (  s01_axis_tready         ),
   .s1_axis_tlast             (  s01_axis_tlast          ),
              
   .s2_axis_tdata             (  s02_axis_tdata          ),
   .s2_axis_tkeep             (  s02_axis_tkeep          ),
   .s2_axis_tuser             (  s02_axis_tuser          ),
   .s2_axis_tvalid            (  s02_axis_tvalid         ),
   .s2_axis_tready            (  s02_axis_tready         ),
   .s2_axis_tlast             (  s02_axis_tlast          ),
              
   .s3_axis_tdata             (  s03_axis_tdata          ),
   .s3_axis_tkeep             (  s03_axis_tkeep          ),
   .s3_axis_tuser             (  s03_axis_tuser          ),
   .s3_axis_tvalid            (  s03_axis_tvalid         ),
   .s3_axis_tready            (  s03_axis_tready         ),
   .s3_axis_tlast             (  s03_axis_tlast          )
);



wire  start_replay_0, start_replay_1, start_replay_2, start_replay_3;

assign q0_start_replay = (q0_replay_count != 0) ? start_replay_0 : 0;
assign q1_start_replay = (q1_replay_count != 0) ? start_replay_1 : 0;
assign q2_start_replay = (q2_replay_count != 0) ? start_replay_2 : 0;
assign q3_start_replay = (q3_replay_count != 0) ? start_replay_3 : 0;

// -- Register assignments
assign sw_rst           = rw_regs[(C_S_AXI_DATA_WIDTH*0)+1-1:(C_S_AXI_DATA_WIDTH*0)]; //0x0000

assign start_replay_0  = rw_regs[(C_S_AXI_DATA_WIDTH*1)+1-1:(C_S_AXI_DATA_WIDTH*1)]; //0x0004
assign start_replay_1  = rw_regs[(C_S_AXI_DATA_WIDTH*2)+1-1:(C_S_AXI_DATA_WIDTH*2)]; //0x0008
assign start_replay_2  = rw_regs[(C_S_AXI_DATA_WIDTH*3)+1-1:(C_S_AXI_DATA_WIDTH*3)]; //0x000c
assign start_replay_3  = rw_regs[(C_S_AXI_DATA_WIDTH*4)+1-1:(C_S_AXI_DATA_WIDTH*4)]; //0x0010

assign q0_replay_count  = rw_regs[(C_S_AXI_DATA_WIDTH*5)+C_S_AXI_DATA_WIDTH-1:(C_S_AXI_DATA_WIDTH*5)]; //0x0014
assign q1_replay_count  = rw_regs[(C_S_AXI_DATA_WIDTH*6)+C_S_AXI_DATA_WIDTH-1:(C_S_AXI_DATA_WIDTH*6)]; //0x0018
assign q2_replay_count  = rw_regs[(C_S_AXI_DATA_WIDTH*7)+C_S_AXI_DATA_WIDTH-1:(C_S_AXI_DATA_WIDTH*7)]; //0x001c
assign q3_replay_count  = rw_regs[(C_S_AXI_DATA_WIDTH*8)+C_S_AXI_DATA_WIDTH-1:(C_S_AXI_DATA_WIDTH*8)]; //0x0020 

assign q0_addr_low      = rw_regs[(C_S_AXI_DATA_WIDTH*9)+C_S_AXI_DATA_WIDTH-1:(C_S_AXI_DATA_WIDTH*9)]; //0x0024 
assign q0_addr_high     = rw_regs[(C_S_AXI_DATA_WIDTH*10)+C_S_AXI_DATA_WIDTH-1:(C_S_AXI_DATA_WIDTH*10)]; //0x0028 
assign q1_addr_low      = rw_regs[(C_S_AXI_DATA_WIDTH*11)+C_S_AXI_DATA_WIDTH-1:(C_S_AXI_DATA_WIDTH*11)]; //0x002c 
assign q1_addr_high     = rw_regs[(C_S_AXI_DATA_WIDTH*12)+C_S_AXI_DATA_WIDTH-1:(C_S_AXI_DATA_WIDTH*12)]; //0x0030 
assign q2_addr_low      = rw_regs[(C_S_AXI_DATA_WIDTH*13)+C_S_AXI_DATA_WIDTH-1:(C_S_AXI_DATA_WIDTH*13)]; //0x0034 
assign q2_addr_high     = rw_regs[(C_S_AXI_DATA_WIDTH*14)+C_S_AXI_DATA_WIDTH-1:(C_S_AXI_DATA_WIDTH*14)]; //0x0038 
assign q3_addr_low      = rw_regs[(C_S_AXI_DATA_WIDTH*15)+C_S_AXI_DATA_WIDTH-1:(C_S_AXI_DATA_WIDTH*15)]; //0x003c 
assign q3_addr_high     = rw_regs[(C_S_AXI_DATA_WIDTH*16)+C_S_AXI_DATA_WIDTH-1:(C_S_AXI_DATA_WIDTH*16)]; //0x0040 

assign q0_enable        = rw_regs[(C_S_AXI_DATA_WIDTH*17)+1-1:(C_S_AXI_DATA_WIDTH*17)]; //0x0044
assign q1_enable        = rw_regs[(C_S_AXI_DATA_WIDTH*18)+1-1:(C_S_AXI_DATA_WIDTH*18)]; //0x0048
assign q2_enable        = rw_regs[(C_S_AXI_DATA_WIDTH*19)+1-1:(C_S_AXI_DATA_WIDTH*19)]; //0x004c
assign q3_enable        = rw_regs[(C_S_AXI_DATA_WIDTH*20)+1-1:(C_S_AXI_DATA_WIDTH*20)]; //0x0050

assign q0_wr_done       = rw_regs[(C_S_AXI_DATA_WIDTH*21)+1-1:(C_S_AXI_DATA_WIDTH*21)]; //0x0054
assign q1_wr_done       = rw_regs[(C_S_AXI_DATA_WIDTH*22)+1-1:(C_S_AXI_DATA_WIDTH*22)]; //0x0058
assign q2_wr_done       = rw_regs[(C_S_AXI_DATA_WIDTH*23)+1-1:(C_S_AXI_DATA_WIDTH*23)]; //0x005c
assign q3_wr_done       = rw_regs[(C_S_AXI_DATA_WIDTH*24)+1-1:(C_S_AXI_DATA_WIDTH*24)]; //0x0060

// 0x0 : default, 0x1: path 0, 0x2: path 1, 0x4: path 2, 0x8: path 3.
assign conf_path        = rw_regs[(C_S_AXI_DATA_WIDTH*25)+32-1:(C_S_AXI_DATA_WIDTH*25)]; //0x0064

endmodule
