//
// Copyright (C) 2010, 2011 The Board of Trustees of The Leland Stanford
// Junior University
// Copyright (c) 2016 University of Cambridge
// Copyright (c) 2016 Jong Hun Han
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
/*******************************************************************************
 *  File:
 *        osnt_timestamp.v
 *
 *  Author:
 *        Gianni Antichi
 *
 * Modified by Hilda on 2019-07-07
 *
 *  Description:
 */

module osnt_sume_timestamp
#(
   parameter C_FAMILY              = "virtex7",
   parameter C_S_AXI_DATA_WIDTH    = 32,          
   parameter C_S_AXI_ADDR_WIDTH    = 32,          
   parameter C_USE_WSTRB           = 0,
   parameter C_DPHASE_TIMEOUT      = 0,
   parameter C_BASEADDR            = 32'hFFFFFFFF,
   parameter C_HIGHADDR            = 32'h00000000,
   parameter C_S_AXI_ACLK_FREQ_HZ  = 100,
   parameter TIMESTAMP_WIDTH	   = 64
)
(
   // Slave AXI Ports
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
   output                                    S_AXI_AWREADY,
 
   // PPS input
   input					                        PPS_RX,

   // Programmable TS pulse
   output                                    ts_pulse_out,
   input                                     ts_pulse_in,

   output   [C_S_AXI_DATA_WIDTH-1:0]         rx_ts_pos,
   output   [C_S_AXI_DATA_WIDTH-1:0]         tx_ts_pos,
 
   // Timestamp
   output     [TIMESTAMP_WIDTH-1 : 0]        STAMP_COUNTER,
   output reg   [TIMESTAMP_WIDTH-1 : 0]      STAMP_COUNTER_156
);

  wire     [NUM_RW_REGS*C_S_AXI_DATA_WIDTH-1 : 0] rw_regs;
  wire     [NUM_RO_REGS*C_S_AXI_DATA_WIDTH-1 : 0] ro_regs;

  wire						                          gps_connected;
  wire	  [1:0]				                       restart_time;
  wire     [TIMESTAMP_WIDTH-1:0]                  ntp_timestamp;

  wire     [C_S_AXI_DATA_WIDTH-1:0]               conf_trig;

  wire  w_ts_pulse_in;

  reg   ts_trigger;

   //34359738368 x 6.26ns = 214748364800ns = 214.7483648sec = 3.579139413min
   assign ts_pulse = STAMP_COUNTER[35];

   reg   r_gps_0, r_gps_1;
   reg   [C_S_AXI_DATA_WIDTH-1:0]   gps_counter;

   wire      [`REG_CTRL_REGS0_BITS]     ip2cpu_ctrl_regs0_wire;
   wire 	    [`REG_CTRL_REGS1_BITS]	    ip2cpu_ctrl_regs1_wire;
   wire      [`REG_CTRL_REGS2_BITS]     ip2cpu_ctrl_regs2_wire;
   wire 	    [`REG_CTRL_REGS3_BITS]	    ip2cpu_ctrl_regs3_wire;
   wire      [`REG_CTRL_REGS4_BITS]     ip2cpu_ctrl_regs4_wire;
   wire 	    [`REG_CTRL_REGS5_BITS]	    ip2cpu_ctrl_regs5_wire;  
   wire 	    [`REG_CTRL_REGS6_BITS]	    ip2cpu_ctrl_regs6_wire;  
   wire      [`REG_CTRL_REGS0_BITS]     ip2cpu_ctrl_regs0_wire;

   wire      [`REG_CTRL_REGS0_BITS]     cpu2ip_ctrl_regs0_wire;   
   wire 	    [`REG_CTRL_REGS1_BITS]	    cpu2ip_ctrl_regs1_wire;
   wire      [`REG_CTRL_REGS2_BITS]     cpu2ip_ctrl_regs2_wire;
   wire 	    [`REG_CTRL_REGS3_BITS]	    cpu2ip_ctrl_regs3_wire;
   wire      [`REG_CTRL_REGS4_BITS]     cpu2ip_ctrl_regs4_wire;
   wire 	    [`REG_CTRL_REGS5_BITS]	    cpu2ip_ctrl_regs5_wire;  
   wire 	    [`REG_CTRL_REGS6_BITS]	    cpu2ip_ctrl_regs6_wire;  	

	reg 	    [`REG_RETURN_REGS0_BITS]	 return_regs0;
	reg		 [`REG_RETURN_REGS1_BITS]   return_regs1;
	reg       [`REG_RETURN_REGS2_BITS]   return_regs2;
	reg       [`REG_RETURN_REGS3_BITS]   return_regs3;

   assign cpu2ip_ctrl_regs0_wire = ip2cpu_ctrl_regs0_wire;
   assign cpu2ip_ctrl_regs1_wire = ip2cpu_ctrl_regs1_wire;
   assign cpu2ip_ctrl_regs2_wire = ip2cpu_ctrl_regs2_wire;
   assign cpu2ip_ctrl_regs3_wire = ip2cpu_ctrl_regs3_wire;
   assign cpu2ip_ctrl_regs4_wire = ip2cpu_ctrl_regs4_wire;
   assign cpu2ip_ctrl_regs5_wire = ip2cpu_ctrl_regs5_wire;
   assign cpu2ip_ctrl_regs6_wire = ip2cpu_ctrl_regs6_wire;

   // sume reg system
   timestamp_cpu_regs#(
      .C_BASE_ADDRESS			(C_BASE_ADDRESS),
      .C_S_AXI_DATA_WIDTH		(C_S_AXI_DATA_WIDTH),
      .C_S_AXI_ADDR_WIDTH		(C_S_AXI_ADDR_WIDTH)
   )timestamp_cpu_regs(
      // General ports
      .clk					   (S_AXI_ACLK),
      .resetn					(S_AXI_ARESETN),
      // Global Registers
      .cpu_resetn_soft		(),
      .resetn_soft			(), 
      .resetn_sync			(), 

      // Register ports
      .ip2cpu_ctrl_regs0_reg	(ip2cpu_ctrl_regs0_wire), 
      .cpu2ip_ctrl_regs0_reg	(cpu2ip_ctrl_regs0_wire), 
      .ip2cpu_ctrl_regs1_reg	(ip2cpu_ctrl_regs1_wire), 
      .cpu2ip_ctrl_regs1_reg	(cpu2ip_ctrl_regs1_wire), 
      .ip2cpu_ctrl_regs2_reg	(ip2cpu_ctrl_regs2_wire), 
      .cpu2ip_ctrl_regs2_reg	(cpu2ip_ctrl_regs2_wire), 
      .ip2cpu_ctrl_regs3_reg	(ip2cpu_ctrl_regs3_wire), 
      .cpu2ip_ctrl_regs3_reg	(cpu2ip_ctrl_regs3_wire), 
      .ip2cpu_ctrl_regs4_reg	(ip2cpu_ctrl_regs4_wire), 
      .cpu2ip_ctrl_regs4_reg	(cpu2ip_ctrl_regs4_wire), 
      .ip2cpu_ctrl_regs5_reg	(ip2cpu_ctrl_regs5_wire), 
      .cpu2ip_ctrl_regs5_reg	(cpu2ip_ctrl_regs5_wire), 
      .ip2cpu_ctrl_regs6_reg	(ip2cpu_ctrl_regs6_wire),
      .cpu2ip_ctrl_regs6_reg	(cpu2ip_ctrl_regs6_wire),
      .return_regs0_reg		   (return_regs0),			
      .return_regs1_reg		   (return_regs1),			
      .return_regs2_reg		   (return_regs2),		
      .return_regs3_reg		   (return_regs3),	

      // AXI Lite ports
      .S_AXI_ACLK			(S_AXI_ACLK),
      .S_AXI_ARESETN		(S_AXI_ARESETN),
      .S_AXI_AWADDR		(S_AXI_AWADDR),
      .S_AXI_AWVALID		(S_AXI_AWVALID),
      .S_AXI_WDATA		(S_AXI_WDATA),
      .S_AXI_WSTRB		(S_AXI_WSTRB),
      .S_AXI_WVALID		(S_AXI_WVALID),
      .S_AXI_BREADY		(S_AXI_BREADY),
      .S_AXI_ARADDR		(S_AXI_ARADDR),
      .S_AXI_ARVALID		(S_AXI_ARVALID),
      .S_AXI_RREADY		(S_AXI_RREADY),
      .S_AXI_ARREADY		(S_AXI_ARREADY),
      .S_AXI_RDATA		(S_AXI_RDATA),
      .S_AXI_RRESP		(S_AXI_RDATA),
      .S_AXI_RVALID		(S_AXI_RVALID),
      .S_AXI_WREADY		(S_AXI_WREADY),
      .S_AXI_BRESP		(S_AXI_BRESP),
      .S_AXI_BVALID		(S_AXI_BVALID),
      .S_AXI_AWREADY		(S_AXI_AWREADY)

   );

  
// -- Register assignments

assign restart_time      = rw_regs[1+C_S_AXI_DATA_WIDTH*0:C_S_AXI_DATA_WIDTH*0]; //0x00
assign correction_mode   = rw_regs[C_S_AXI_DATA_WIDTH]; //0x04
assign ntp_timestamp     = rw_regs[(TIMESTAMP_WIDTH+C_S_AXI_DATA_WIDTH*2)-1:C_S_AXI_DATA_WIDTH*2]; //0x08-0x0c

assign rx_ts_pos         = rw_regs[(C_S_AXI_DATA_WIDTH*5)-1:C_S_AXI_DATA_WIDTH*4]; //0x10
assign tx_ts_pos         = rw_regs[(C_S_AXI_DATA_WIDTH*6)-1:C_S_AXI_DATA_WIDTH*5]; //0x14

assign conf_trig         = rw_regs[(C_S_AXI_DATA_WIDTH*7)-1:C_S_AXI_DATA_WIDTH*6]; //0x18

//28,24,20,1c 
assign ro_regs           = {STAMP_COUNTER, gps_counter[31:0], 30'b0, r_gps_1, gps_connected};

// bridging from 10g style regs to sume

assign rw_regs[(C_S_AXI_DATA_WIDTH * 1)-1 : C_S_AXI_DATA_WIDTH * 0] = ip2cpu_ctrl_regs0_wire;
assign rw_regs[(C_S_AXI_DATA_WIDTH * 2)-1 : C_S_AXI_DATA_WIDTH * 1] = ip2cpu_ctrl_regs1_wire;
assign rw_regs[(C_S_AXI_DATA_WIDTH * 3)-1 : C_S_AXI_DATA_WIDTH * 2] = ip2cpu_ctrl_regs2_wire;
assign rw_regs[(C_S_AXI_DATA_WIDTH * 4)-1 : C_S_AXI_DATA_WIDTH * 3] = ip2cpu_ctrl_regs3_wire;
assign rw_regs[(C_S_AXI_DATA_WIDTH * 5)-1 : C_S_AXI_DATA_WIDTH * 4] = ip2cpu_ctrl_regs4_wire;
assign rw_regs[(C_S_AXI_DATA_WIDTH * 6)-1 : C_S_AXI_DATA_WIDTH * 5] = ip2cpu_ctrl_regs5_wire;
assign rw_regs[(C_S_AXI_DATA_WIDTH * 7)-1 : C_S_AXI_DATA_WIDTH * 6] = ip2cpu_ctrl_regs6_wire;

assign return_regs0 = ro_regs[(C_S_AXI_DATA_WIDTH * 1)-1 : C_S_AXI_DATA_WIDTH * 0];
assign return_regs1 = ro_regs[(C_S_AXI_DATA_WIDTH * 2)-1 : C_S_AXI_DATA_WIDTH * 1];
assign return_regs2 = ro_regs[(C_S_AXI_DATA_WIDTH * 3)-1 : C_S_AXI_DATA_WIDTH * 2];
assign return_regs3 = ro_regs[(C_S_AXI_DATA_WIDTH * 4)-1 : C_S_AXI_DATA_WIDTH * 3];

assign ts_pulse_out = (conf_trig == 1) ? 1 :
                      (conf_trig == 2) ? ts_trigger :
                      (conf_trig == 3) ? PPS_RX : 0;


always @(posedge S_AXI_ACLK)
   if (~S_AXI_ARESETN) begin
      r_gps_0  <= 0;
      r_gps_1RO_REGS
   end
   else beginRO_REGS
      r_gps_0  <= PPS_RX;
      r_gps_1  <= r_gps_0;
   end

wire  w_gps_signal = r_gps_0 & ~r_gps_1;


reg   r_ts_pulse_in_0, r_ts_pulse_in_1;
always @(posedge S_AXI_ACLK)
   if (~S_AXI_ARESETN) begin
      r_ts_pulse_in_0  <= 0;
      r_ts_pulse_in_1  <= 0;
   end
   else begin
      r_ts_pulse_in_0  <= ts_pulse_in;
      r_ts_pulse_in_1  <= r_ts_pulse_in_0;
   end

assign w_ts_pulse_in = r_ts_pulse_in_0 & ~r_ts_pulse_in_1;

always @(posedge S_AXI_ACLK)
   if (~S_AXI_ARESETN) begin
      gps_counter    <= 0;
   end
   else if (restart_time[1]) begin
      gps_counter    <= 0;
   end
   else if (w_gps_signal) begin
      gps_counter    <= gps_counter + 1;
   end

always @(posedge S_AXI_ACLK)
   if (~S_AXI_ARESETN) begin
      ts_trigger  <= 0;
   end
   else begin
      ts_trigger  <= STAMP_COUNTER[32];
   end

  
always @(posedge S_AXI_ACLK)
   if (~S_AXI_ARESETN) begin
      STAMP_COUNTER_156 <= 0;
   end
   else begin
      STAMP_COUNTER_156 <= STAMP_COUNTER_156 + 1;
   end

  // -- Stamp Counter Module
  stamp_counter #
  (
    .TIMESTAMP_WIDTH  (TIMESTAMP_WIDTH)
   ) stamp_counter
  (
    // Global Ports
    .axi_aclk      (S_AXI_ACLK),
    .axi_resetn    (S_AXI_ARESETN),
    .pps_rx	   (PPS_RX),
    .correction_mode(correction_mode),

    .restart_time(restart_time),
    .ntp_timestamp(ntp_timestamp),
    .stamp_counter(STAMP_COUNTER),

    .gps_connected(gps_connected)
  );
  
endmodule
