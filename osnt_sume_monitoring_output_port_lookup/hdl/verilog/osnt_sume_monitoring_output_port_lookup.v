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
 * File:
 *    osnt_monitoring_output_port_lookup.v
 *
 * Author:
 *    Gianni Antichi
 *
 * Modified by Hilda on 2019-07-07
 *
 * Description:
 */

`include "packet_analyzer/defines.vh"

module osnt_sume_monitoring_output_port_lookup
	#(
  		parameter C_FAMILY 						= "virtex7",
  		parameter C_S_AXI_DATA_WIDTH			= 32,
  		parameter C_S_AXI_ADDR_WIDTH			= 32,
  		parameter C_USE_WSTRB					= 0,
  		parameter C_DPHASE_TIMEOUT				= 0,
  		parameter C_BASEADDR					= 32'h76800000,
  		parameter C_HIGHADDR					= 32'h7680FFFF,
		parameter C_S_AXI_ACLK_FREQ_HZ			= 100,
  		parameter C_M_AXIS_DATA_WIDTH			= 256,
  		parameter C_S_AXIS_DATA_WIDTH			= 256,
  		parameter C_M_AXIS_TUSER_WIDTH			= 128,
  		parameter C_S_AXIS_TUSER_WIDTH			= 128,
		parameter TIMESTAMP_WIDTH				= 64,
        parameter TUPLE_WIDTH					= 104,
        parameter NETWORK_PROTOCOL_COMBINATIONS	= 4,
        parameter MAX_HDR_WORDS					= 6,
        parameter DIVISION_FACTOR				= 2,
        parameter BYTES_COUNT_WIDTH				= 16
  	)
	(
  		// Slave AXI Ports
  		input								S_AXI_ACLK,
  		input								S_AXI_ARESETN,
  		input	[C_S_AXI_ADDR_WIDTH-1:0]	S_AXI_AWADDR,
  		input								S_AXI_AWVALID,
  		input	[C_S_AXI_DATA_WIDTH-1:0]	S_AXI_WDATA,
 	 	input	[C_S_AXI_DATA_WIDTH/8-1:0]	S_AXI_WSTRB,
  		input								S_AXI_WVALID,
  		input								S_AXI_BREADY,
  		input	[C_S_AXI_ADDR_WIDTH-1:0]	S_AXI_ARADDR,
  		input								S_AXI_ARVALID,
  		input								S_AXI_RREADY,
  		output								S_AXI_ARREADY,
  		output	[C_S_AXI_DATA_WIDTH-1:0]	S_AXI_RDATA,
  		output	[1:0]						S_AXI_RRESP,
  		output								S_AXI_RVALID,
  		output								S_AXI_WREADY,
  		output	[1:0]						S_AXI_BRESP,
  		output								S_AXI_BVALID,
  		output								S_AXI_AWREADY,
  
  		// Master Stream Ports (interface to data path)
  		output	[C_M_AXIS_DATA_WIDTH-1:0]		M_AXIS_TDATA,
  		output	[((C_M_AXIS_DATA_WIDTH/8))-1:0]	M_AXIS_TKEEP,
  		output	[C_M_AXIS_TUSER_WIDTH-1:0]		M_AXIS_TUSER,
  		output									M_AXIS_TVALID,
  		input									M_AXIS_TREADY,
  		output									M_AXIS_TLAST,

  		// Slave Stream Ports (interface to RX queues)
  		input	[C_S_AXIS_DATA_WIDTH-1:0] 		S_AXIS_TDATA,
  		input	[((C_S_AXIS_DATA_WIDTH/8))-1:0] S_AXIS_TKEEP,
  		input	[C_S_AXIS_TUSER_WIDTH-1:0] 		S_AXIS_TUSER,
  		input									S_AXIS_TVALID,
  		output									S_AXIS_TREADY,
  		input									S_AXIS_TLAST,

		// Stamp Counter
		input	[TIMESTAMP_WIDTH-1:0]	STAMP_COUNTER
	);
  
	function integer log2;
      	input integer number;
      	begin
        	log2=0;
         	while(2**log2<number) begin
            		log2=log2+1;
         	end
      	end
   	endfunction // log2
 
	// -- Internal Parameters
  	localparam NUM_RO_REGS			= 26; 
  	localparam NUM_RW_REGS			= 2;

  	localparam NUM_QUEUES			= 8;
  	localparam NUM_QUEUES_WIDTH		= log2(NUM_QUEUES);
  	localparam MON_LUT_DEPTH		= 32;
  	localparam MON_LUT_DEPTH_BITS	= log2(MON_LUT_DEPTH);
	localparam IP_WIDTH				= 32;
	localparam PROTO_WIDTH			= 8;
	localparam PORT_WIDTH			= 16;
	localparam NUM_INPUT_QUEUES 	= 8;	
	localparam PRCTL_ID_WIDTH 		= log2(NETWORK_PROTOCOL_COMBINATIONS);
    localparam ATTRIBUTE_DATA_WIDTH = NUM_INPUT_QUEUES+PRCTL_ID_WIDTH+`PKT_FLAGS+BYTES_COUNT_WIDTH+TUPLE_WIDTH;
    localparam TBL_NUM_COLS 		= 8;
    localparam TBL_NUM_ROWS			= 32;

	// -- FSM Control     
	localparam WAIT = 1'b0;
    localparam PROC = 1'b1;
	reg STATE;

	// -- Signals
  	wire	[(NUM_RW_REGS*C_S_AXI_DATA_WIDTH)-1:0] rw_regs;
  	wire	[(NUM_RO_REGS*C_S_AXI_DATA_WIDTH)-1:0] ro_regs;

  	wire			rst_stats;
  	wire			stats_freeze;
	wire	[3:0]	debug_mode;
	wire			force_drop;
	wire			tuple_pkt_en;

  	wire [C_S_AXI_DATA_WIDTH-1:0] bytes_cnt_0;
  	wire [C_S_AXI_DATA_WIDTH-1:0] bytes_cnt_1;
  	wire [C_S_AXI_DATA_WIDTH-1:0] bytes_cnt_2;
  	wire [C_S_AXI_DATA_WIDTH-1:0] bytes_cnt_3;

  	wire [C_S_AXI_DATA_WIDTH-1:0] pkt_cnt_0;
  	wire [C_S_AXI_DATA_WIDTH-1:0] pkt_cnt_1;
  	wire [C_S_AXI_DATA_WIDTH-1:0] pkt_cnt_2;
  	wire [C_S_AXI_DATA_WIDTH-1:0] pkt_cnt_3;

	wire [C_S_AXI_DATA_WIDTH-1:0] vlan_cnt_0;
    wire [C_S_AXI_DATA_WIDTH-1:0] vlan_cnt_1;
    wire [C_S_AXI_DATA_WIDTH-1:0] vlan_cnt_2;
    wire [C_S_AXI_DATA_WIDTH-1:0] vlan_cnt_3;

    wire [C_S_AXI_DATA_WIDTH-1:0] ip_cnt_0;
    wire [C_S_AXI_DATA_WIDTH-1:0] ip_cnt_1;
    wire [C_S_AXI_DATA_WIDTH-1:0] ip_cnt_2;
    wire [C_S_AXI_DATA_WIDTH-1:0] ip_cnt_3;

    wire [C_S_AXI_DATA_WIDTH-1:0] udp_cnt_0;
    wire [C_S_AXI_DATA_WIDTH-1:0] udp_cnt_1;
    wire [C_S_AXI_DATA_WIDTH-1:0] udp_cnt_2;
    wire [C_S_AXI_DATA_WIDTH-1:0] udp_cnt_3;

    wire [C_S_AXI_DATA_WIDTH-1:0] tcp_cnt_0;
    wire [C_S_AXI_DATA_WIDTH-1:0] tcp_cnt_1;
    wire [C_S_AXI_DATA_WIDTH-1:0] tcp_cnt_2;
    wire [C_S_AXI_DATA_WIDTH-1:0] tcp_cnt_3;

    wire [C_S_AXI_DATA_WIDTH-1:0] stats_time_high;
    wire [C_S_AXI_DATA_WIDTH-1:0] stats_time_low;

  	wire [MON_LUT_DEPTH_BITS-1:0] 	mon_rd_addr;
  	wire 							mon_rd_req;
  	wire [IP_WIDTH-1:0] 			mon_rd_sip;
  	wire [IP_WIDTH-1:0] 			mon_rd_sip_mask;
  	wire [IP_WIDTH-1:0] 			mon_rd_dip;
  	wire [IP_WIDTH-1:0] 			mon_rd_dip_mask;
  	wire [PROTO_WIDTH-1:0] 			mon_rd_proto;
  	wire [PROTO_WIDTH-1:0] 			mon_rd_proto_mask;
  	wire [(2*PORT_WIDTH)-1:0] 		mon_rd_l4ports;
  	wire [(2*PORT_WIDTH)-1:0] 		mon_rd_l4ports_mask;
  	wire 							mon_rd_ack;
  	wire [MON_LUT_DEPTH_BITS-1:0] 	mon_wr_addr;
  	wire 							mon_wr_req;
  	wire [IP_WIDTH-1:0] 			mon_wr_sip;
  	wire [IP_WIDTH-1:0] 			mon_wr_sip_mask;
  	wire [IP_WIDTH-1:0] 			mon_wr_dip;
  	wire [IP_WIDTH-1:0] 			mon_wr_dip_mask;
  	wire [PROTO_WIDTH-1:0] 			mon_wr_proto;
  	wire [PROTO_WIDTH-1:0] 			mon_wr_proto_mask;
  	wire [(2*PORT_WIDTH)-1:0] 		mon_wr_l4ports;
  	wire [(2*PORT_WIDTH)-1:0] 		mon_wr_l4ports_mask;
  	wire 							mon_wr_ack;

  	wire [31:0] tbl_wr_proto;
  	wire [31:0] tbl_wr_proto_mask;
  	wire [31:0] tbl_rd_proto;
  	wire [31:0] tbl_rd_proto_mask;

	// -- Signals: Reg Port-Mapping
	wire	resetn_sync;
	// RW regs
    wire	[`REG_RW0_BITS]		ip2cpu_rw0_wire;
    wire	[`REG_RW0_BITS]		cpu2ip_rw0_wire;	
    wire	[`REG_RW1_BITS]		ip2cpu_rw1_wire;
    wire	[`REG_RW1_BITS]		cpu2ip_rw1_wire;	
	// RO regs
    wire	[`REG_RO2_BITS]		ro2_wire;
    wire	[`REG_RO3_BITS]		ro3_wire;
    wire	[`REG_RO4_BITS]		ro4_wire;
    wire	[`REG_RO5_BITS]		ro5_wire;
    wire	[`REG_RO6_BITS]		ro6_wire;
    wire	[`REG_RO7_BITS]		ro7_wire;
    wire	[`REG_RO8_BITS]		ro8_wire;
    wire	[`REG_RO9_BITS]		ro9_wire;
    wire	[`REG_RO10_BITS]	ro10_wire;
    wire	[`REG_RO11_BITS]	ro11_wire;
    wire	[`REG_RO12_BITS]	ro12_wire;
    wire	[`REG_RO13_BITS]	ro13_wire;
    wire	[`REG_RO14_BITS]	ro14_wire;
    wire	[`REG_RO15_BITS]	ro15_wire;
    wire	[`REG_RO16_BITS] 	ro16_wire;
    wire	[`REG_RO17_BITS]	ro17_wire;
    wire	[`REG_RO18_BITS]	ro18_wire;
    wire	[`REG_RO19_BITS]	ro19_wire;
    wire	[`REG_RO20_BITS]	ro20_wire;
    wire	[`REG_RO21_BITS]	ro21_wire;
    wire	[`REG_RO22_BITS]	ro22_wire;
    wire	[`REG_RO23_BITS]	ro23_wire;
    wire	[`REG_RO24_BITS]	ro24_wire;
    wire	[`REG_RO25_BITS]	ro25_wire;
    wire	[`REG_RO24_BITS]	ro26_wire;
    wire	[`REG_RO25_BITS]	ro27_wire;
	// bar 1 port signals
   	wire	[`MEM_BARTABLE_ADDR_BITS]	bartable_addr;
    wire	[`MEM_BARTABLE_DATA_BITS]	bartable_data;
    wire								bartable_rd_wrn;
    wire								bartable_cmd_valid;
    reg		[`MEM_BARTABLE_DATA_BITS]	bartable_reply;
    reg									bartable_reply_valid;	
	// Signals -- bus2table
    reg													tbl_rd_req;
    wire												tbl_rd_ack;
    reg		[log2(TBL_NUM_ROWS)-1 : 0]               	tbl_rd_addr;
    wire	[(C_S_AXI_DATA_WIDTH*TBL_NUM_COLS)-1 : 0]	tbl_rd_data;
    reg													tbl_wr_req;
    wire												tbl_wr_ack;
    reg		[log2(TBL_NUM_ROWS)-1 : 0]					tbl_wr_addr;
    wire	[(C_S_AXI_DATA_WIDTH*TBL_NUM_COLS)-1 : 0]	tbl_wr_data;

	reg		[C_S_AXI_DATA_WIDTH-1 : 0] tbl_cells_rd_port [0 : TBL_NUM_COLS-1];
	reg		[C_S_AXI_DATA_WIDTH-1 : 0] tbl_cells_wr_port [0 : TBL_NUM_COLS-1];
   
	// Signals -- bus2table control
	wire [3:0] index;


monitoring_output_port_lookup_cpu_regs #(
	.C_BASE_ADDRESS(32'h00000000),
	.C_S_AXI_DATA_WIDTH(32),
	.C_S_AXI_ADDR_WIDTH(32)
)(
    // General ports
    .clk(S_AXI_ACLK),
    .resetn(S_AXI_RESETN),
    // Global Registers
    .cpu_resetn_soft(),
    .resetn_soft(),
    .resetn_sync(resetn_sync),

   	// Register ports
	.ip2cpu_rw0_reg(ip2cpu_rw0_wire),
	.cpu2ip_rw0_reg(cpu2ip_rw0_wire),
	.ip2cpu_rw1_reg(ip2cpu_rw1_wire),
	.cpu2ip_rw1_reg(cpu2ip_rw1_wire),

	.ro2_reg(ro2_wire),
	.ro3_reg(ro3_wire),
	.ro4_reg(ro4_wire),
	.ro5_reg(ro5_wire),
	.ro6_reg(ro6_wire),
	.ro7_reg(ro7_wire),
	.ro8_reg(ro8_wire),
	.ro9_reg(ro9_wire),
	.ro10_reg(ro10_wire),
	.ro11_reg(ro11_wire),
	.ro12_reg(ro12_wire),
	.ro13_reg(ro13_wire),
	.ro14_reg(ro14_wire),
	.ro15_reg(ro15_wire),
	.ro16_reg(ro16_wire),
	.ro17_reg(ro17_wire),
	.ro18_reg(ro18_wire),
	.ro19_reg(ro19_wire),
	.ro20_reg(ro20_wire),
	.ro21_reg(ro21_wire),
	.ro22_reg(ro22_wire),
	.ro23_reg(ro23_wire),
	.ro24_reg(ro24_wire),
	.ro25_reg(ro25_wire),
	.ro26_reg(ro26_wire),
	.ro27_reg(ro27_wire),

    .bartable_addr(bartable_addr),
    .bartable_data(bartable_data),
    .bartable_rd_wrn(bartable_rd_wrn),
    .bartable_cmd_valid(bartable_cmd_valid),
    .bartable_reply(bartable_reply),
    .bartable_reply_valid(bartable_reply_valid),

    // AXI Lite ports
	.S_AXI_ACLK(S_AXI_ACLK),
	.S_AXI_ARESETN(S_AXI_ARESETN),
	.S_AXI_AWADDR(S_AXI_AWADDR),
	.S_AXI_AWVALID(S_AXI_AWVALID),
	.S_AXI_WDATA(S_AXI_WDATA),
	.S_AXI_WSTRB(S_AXI_WSTRB),
	.S_AXI_WVALID(S_AXI_WVALID),
	.S_AXI_BREADY(S_AXI_BREADY),
	.S_AXI_ARADDR(S_AXI_ARADDR),
	.S_AXI_ARVALID(S_AXI_ARVALID),
	.S_AXI_RREADY(S_AXI_RREADY),
	.S_AXI_ARREADY(S_AXI_ARREADY),
	.S_AXI_RDATA(S_AXI_RDATA),
	.S_AXI_RRESP(S_AXI_RREADY),
	.S_AXI_RVALID(S_AXI_RVALID),
	.S_AXI_WREADY(S_AXI_WREADY)
);
  	// -- Register Assignments
	// bar 0 mapping
	// reg value feedback
	assign ip2cpu_rw0_wire = cpu2ip_rw0_wire;
	assign ip2cpu_rw1_wire = cpu2ip_rw1_wire;
	// map to old osnt regs
	assign rw_regs[C_S_AXI_DATA_WIDTH * 1 - 1 : C_S_AXIS_DATA_WIDTH * 0] 	= cpu2ip_rw0_wire;
	assign rw_regs[C_S_AXI_DATA_WIDTH * 2 - 1 : C_S_AXIS_DATA_WIDTH * 1] 	= cpu2ip_rw1_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 3 - 1 : C_S_AXIS_DATA_WIDTH * 2] 	= ro2_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 4 - 1 : C_S_AXIS_DATA_WIDTH * 3] 	= ro3_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 5 - 1 : C_S_AXIS_DATA_WIDTH * 4] 	= ro4_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 6 - 1 : C_S_AXIS_DATA_WIDTH * 5] 	= ro5_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 7 - 1 : C_S_AXIS_DATA_WIDTH * 6] 	= ro6_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 8 - 1 : C_S_AXIS_DATA_WIDTH * 7] 	= ro7_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 9 - 1 : C_S_AXIS_DATA_WIDTH * 8] 	= ro8_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 10 - 1 : C_S_AXIS_DATA_WIDTH * 9] 	= ro9_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 11 - 1 : C_S_AXIS_DATA_WIDTH * 10] 	= ro10_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 12 - 1 : C_S_AXIS_DATA_WIDTH * 11] 	= ro11_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 13 - 1 : C_S_AXIS_DATA_WIDTH * 12] 	= ro12_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 14 - 1 : C_S_AXIS_DATA_WIDTH * 13] 	= ro13_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 15 - 1 : C_S_AXIS_DATA_WIDTH * 14] 	= ro14_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 16 - 1 : C_S_AXIS_DATA_WIDTH * 15] 	= ro15_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 17 - 1 : C_S_AXIS_DATA_WIDTH * 16] 	= ro16_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 18 - 1 : C_S_AXIS_DATA_WIDTH * 17] 	= ro17_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 19 - 1 : C_S_AXIS_DATA_WIDTH * 18] 	= ro18_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 20 - 1 : C_S_AXIS_DATA_WIDTH * 19] 	= ro19_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 21 - 1 : C_S_AXIS_DATA_WIDTH * 20] 	= ro20_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 22 - 1 : C_S_AXIS_DATA_WIDTH * 21] 	= ro21_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 23 - 1 : C_S_AXIS_DATA_WIDTH * 22] 	= ro22_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 24 - 1 : C_S_AXIS_DATA_WIDTH * 23] 	= ro23_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 25 - 1 : C_S_AXIS_DATA_WIDTH * 24] 	= ro24_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 26 - 1 : C_S_AXIS_DATA_WIDTH * 25] 	= ro25_wire;
	assign ro_regs[C_S_AXI_DATA_WIDTH * 27 - 1 : C_S_AXIS_DATA_WIDTH * 26] 	= ro26_wire;
	// osnt control - rw regs mapping
	assign rst_stats    = rw_regs[0];
	assign debug_mode   = rw_regs[7:4]; //0x1: nf0, 0x2: nf1, 0x4: nf2, 0x8: nf3
	assign force_drop   = rw_regs[8];	//0x100
	assign tuple_pkt_en = rw_regs[16];	//0x1_0000
	assign stats_freeze = rw_regs[32+0];
	// osnt ro regs - control mapping
  	assign ro_regs = {stats_time_high, stats_time_low,
			        tcp_cnt_3, tcp_cnt_2, tcp_cnt_1, tcp_cnt_0,
                    udp_cnt_3, udp_cnt_2, udp_cnt_1, udp_cnt_0,
                    ip_cnt_3, ip_cnt_2, ip_cnt_1, ip_cnt_0,
                    vlan_cnt_3, vlan_cnt_2, vlan_cnt_1, vlan_cnt_0,
			        bytes_cnt_3, bytes_cnt_2, bytes_cnt_1, bytes_cnt_0,
                    pkt_cnt_3, pkt_cnt_2, pkt_cnt_1, pkt_cnt_0};

  	assign mon_wr_proto = tbl_wr_proto[7:0];
  	assign mon_wr_proto_mask = tbl_wr_proto_mask[7:0];
  	assign tbl_rd_proto = mon_rd_proto;
  	assign tbl_rd_proto_mask = mon_rd_proto_mask;
	// new mapping for table control
	assign mon_rd_req 			= tb_rd_req;
	assign tbl_rd_ack 			= mon_rd_ack;
	assign mon_rd_addr 			= rbl_rd_addr;
	assign tbl_rd_data 			= {tbl_rd_proto_mask, tbl_rd_proto,
								mon_rd_l4ports_mask, mon_rd_l4ports,
								mon_rd_dip_mask, mon_rd_dip,
								mon_rd_sip_mask, mon_rd_sip};
	assign mon_wr_req 			= tbl_wr_req;
	assign tbl_wr_ack 			= mon_wr_ack;
	assign mon_wr_addr 			= tbl_wr_addr;
	assign tbl_wr_proto_mask 	= tbl_wr_data[C_S_AXI_DATA_WIDTH * 8 - 1 : C_S_AXI_DATA_WIDTH * 7];
	assign mon_wr_sip 			= tbl_wr_data[C_S_AXI_DATA_WIDTH * 7 - 1 : C_S_AXI_DATA_WIDTH * 6];
	assign mon_wr_l4ports_mask 	= tbl_wr_data[C_S_AXI_DATA_WIDTH * 6 - 1 : C_S_AXI_DATA_WIDTH * 5];
	assign mon_wr_l4ports 		= tbl_wr_data[C_S_AXI_DATA_WIDTH * 5 - 1 : C_S_AXI_DATA_WIDTH * 4];
	assign mon_wr_dip_mask 		= tbl_wr_data[C_S_AXI_DATA_WIDTH * 4 - 1 : C_S_AXI_DATA_WIDTH * 3];
	assign mon_wr_dip 			= tbl_wr_data[C_S_AXI_DATA_WIDTH * 3 - 1 : C_S_AXI_DATA_WIDTH * 2];
	assign mon_wr_sip_mask 		= tbl_wr_data[C_S_AXI_DATA_WIDTH * 2 - 1 : C_S_AXI_DATA_WIDTH * 1];
	assign mon_wr_sip 			= tbl_wr_data[C_S_AXI_DATA_WIDTH * 1 - 1 : C_S_AXI_DATA_WIDTH * 0];

	/* ---------- BAR 1 TABLE LOGIC ---------- */
	// Unpacking Read/Write port
	generate
		for (i=0; i<TBL_NUM_COLS; i=i+1) begin : CELL
	   		assign tbl_wr_data[C_S_AXI_DATA_WIDTH*(i+1)-1 : C_S_AXI_DATA_WIDTH*i] = tbl_cells_wr_port[i];          
	   		always @ (posedge Bus2IP_Clk) begin
            	if (tbl_rd_ack) tbl_cells_rd_port[i] <= tbl_rd_data[C_S_AXI_DATA_WIDTH*(i+1)-1 : C_S_AXI_DATA_WIDTH*i];
        	end
	 	end
   	endgenerate	

	assign index = bartable_addr[5:2];

	always@(S_AXI_ACLK)begin
		if(~resetn_sync)begin
			for (j=0; j<TBL_NUM_COLS; j=j+1)       
				tbl_cells_wr_port[j] <= C_S_AXI_DATA_WIDTH'd0;

			tbl_wr_addr <= tbl_num_rows_in_bits'd0;
			tbl_wr_req 	<= 1'b0;
			tbl_rd_addr <= tbl_num_rows_in_bits'd0;
			tbl_rd_req 	<= 1'b0;

			bartable_reply_valid	<= 1'b1;
			bartable_reply 			<= `MEM_BARTABLE_DATA_BITS'd0;

			STATE <= WAIT;
		end else begin
			case(STATE)
			WAIT: begin
				bartable_reply_valid <= 1'b0; // ack to bus
				STATE <= WAIT;
				if(bartable_cmd_valid)begin
					if(bartable_rd_wrn)begin // bus read
						bartable_reply_valid <= 1'b1; // ack to bus
						STATE <= WAIT;
						if(index < 8)begin
							bartable_reply <= tbl_cells_rd_port[index_rd]; // read table content cell
						end 
						else if(index = 8) begin
							bartable_reply <= tbl_wr_addr; // read table write address
						end 
						else if(index = 9) begin
							bartable_reply <= tbl_rd_addr; // read table read address
						end 
					end else begin // bus write 
						if(index < 8)begin // write table content cell
							bartable_reply_valid 		<= 1'b1; // ack to bus
							tbl_cells_wr_port[index] 	<= bartable_data;
							STATE <= DONE;
						end
						else if(index = 8)begin // write table
							bartable_reply_valid <= 1'b0; // ack to bus
							tbl_wr_addr <= bartable_data[tbl_num_rows_in_bits-1:0]
							tbl_wr_req 	<= 1'b1;
							STATE <= PROC;
						end                
						else if(index = 9)begin // read table
							bartable_reply_valid <= 1'b0; // ack to bus
							tbl_rd_addr <= bartable_data[tbl_num_rows_in_bits-1:0]
							tbl_rd_req 	<= 1'b1';
							STATE <= PROC;
						end						
					end 
				end // cmd valid
			end // state wait
			PROC: begin
                if(tbl_wr_ack)begin
					bartable_reply_valid <= 1'b1; // ack to bus
                    tbl_wr_req <= 1'b0;
                    STATE <= WAIT;
                  end
                  if(tbl_rd_ack)begin
				  	bartable_reply_valid <= 1'b1; // ack to bus
                    tbl_rd_req <= 1'b0;
                    STATE <= WAIT;
                  end 
			end // state proc
			default: begin
				bartable_reply_valid <= 1'b0;
				STATE <= WAIT;
			end // state default
			endcase

		end // rst
	end //process

	// -- Monitoring
  	core_monitoring #
	(
    	.C_M_AXIS_DATA_WIDTH (C_M_AXIS_DATA_WIDTH),
    	.C_S_AXIS_DATA_WIDTH (C_S_AXIS_DATA_WIDTH),
    	.C_M_AXIS_TUSER_WIDTH (C_M_AXIS_TUSER_WIDTH),
    	.C_S_AXIS_TUSER_WIDTH (C_S_AXIS_TUSER_WIDTH),
		.C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH),
    	.NUM_QUEUES (NUM_QUEUES),
    	.MON_LUT_DEPTH_BITS (MON_LUT_DEPTH_BITS),
		.TUPLE_WIDTH (TUPLE_WIDTH),
		.TIMESTAMP_WIDTH (TIMESTAMP_WIDTH),
        .NETWORK_PROTOCOL_COMBINATIONS (NETWORK_PROTOCOL_COMBINATIONS),
        .MAX_HDR_WORDS (MAX_HDR_WORDS),
        .DIVISION_FACTOR (DIVISION_FACTOR),
        .BYTES_COUNT_WIDTH (BYTES_COUNT_WIDTH),
        .ATTRIBUTE_DATA_WIDTH (ATTRIBUTE_DATA_WIDTH)
   	) core_monitoring
  	(
    	// Global Ports
    	.axi_aclk (S_AXI_ACLK),
    	.axi_resetn (~resetn_sync),

    	// Master Stream Ports (interface to data path)
    	.m_axis_tdata (M_AXIS_TDATA),
    	.m_axis_tstrb (M_AXIS_TKEEP),
    	.m_axis_tuser (M_AXIS_TUSER),
    	.m_axis_tvalid (M_AXIS_TVALID),
    	.m_axis_tready (M_AXIS_TREADY),
    	.m_axis_tlast (M_AXIS_TLAST),

    	// Slave Stream Ports (interface to RX queues)
    	.s_axis_tdata (S_AXIS_TDATA),
    	.s_axis_tstrb (S_AXIS_TKEEP),
    	.s_axis_tuser (S_AXIS_TUSER),
    	.s_axis_tvalid (S_AXIS_TVALID),
    	.s_axis_tready (S_AXIS_TREADY),
    	.s_axis_tlast (S_AXIS_TLAST),

    	// --- interface to monitoring TCAM
    	.mon_rd_addr (mon_rd_addr),
    	.mon_rd_req (mon_rd_req),
    	.mon_rd_rule ({mon_rd_l4ports,
                    mon_rd_dip,
                    mon_rd_sip,
                    mon_rd_proto}),
    	.mon_rd_rulemask ({mon_rd_l4ports_mask,
                      	mon_rd_dip_mask,
                        mon_rd_sip_mask,
                        mon_rd_proto_mask}),
    	.mon_rd_ack (mon_rd_ack),
    	.mon_wr_addr (mon_wr_addr),
    	.mon_wr_req (mon_wr_req),
    	.mon_wr_rule ({mon_wr_l4ports,
                    mon_wr_dip,
                    mon_wr_sip,
                    mon_wr_proto}),
    	.mon_wr_rulemask ({mon_wr_l4ports_mask,
                    mon_wr_dip_mask,
                    mon_wr_sip_mask,
                     mon_wr_proto_mask} ),
    	.mon_wr_ack (mon_wr_ack),

    	// --- stats
        .pkt_cnt_0 (pkt_cnt_0),
        .pkt_cnt_1 (pkt_cnt_1),
        .pkt_cnt_2 (pkt_cnt_2),
        .pkt_cnt_3 (pkt_cnt_3),

        .bytes_cnt_0 (bytes_cnt_0eg 
        .bytes_cnt_1 (bytes_cnt_1eg 
        .bytes_cnt_2 (bytes_cnt_2eg 
        .bytes_cnt_3 (bytes_cnt_3eg 

        .vlan_cnt_0 (vlan_cnt_0),eg 
        .vlan_cnt_1 (vlan_cnt_1),eg 
        .vlan_cnt_2 (vlan_cnt_2),
        .vlan_cnt_3 (vlan_cnt_3),

        .ip_cnt_0 (ip_cnt_0),
        .ip_cnt_1 (ip_cnt_1),
        .ip_cnt_2 (ip_cnt_2),
        .ip_cnt_3 (ip_cnt_3),

        .udp_cnt_0 (udp_cnt_0),
        .udp_cnt_1 (udp_cnt_1),
        .udp_cnt_2 (udp_cnt_2),
        .udp_cnt_3 (udp_cnt_3),

        .tcp_cnt_0 (tcp_cnt_0),
        .tcp_cnt_1 (tcp_cnt_1),
        .tcp_cnt_2 (tcp_cnt_2),
        .tcp_cnt_3 (tcp_cnt_3),

        .stats_time_high (stats_time_high),
        .stats_time_low (stats_time_low),

        // --- stats misc
        .stats_freeze (stats_freeze),
        .rst_stats (rst_stats),
        .debug_mode (debug_mode),
        .force_drop (force_drop),
        .tuple_pkt_en (tuple_pkt_en),

		// --- ref time
		.stamp_counter (STAMP_COUNTER)
	);
  	endmodule
