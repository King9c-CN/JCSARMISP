/************************************************************\
 **     Copyright (c) 2012-2023 Anlogic Inc.
 **  All Right Reserved.\
\************************************************************/
/************************************************************\
 ** Log	:	This file is generated by Anlogic IP Generator.
 ** File	:	C:/Users/W1030/Desktop/m0/rtl/al_ip/SDRAM.v
 ** Date	:	2024 04 28
 ** TD version	:	5.6.71036
\************************************************************/

`timescale 1ns / 1ps

module SDRAM ( clk, ras_n, cas_n, we_n, addr, ba, dq, cs_n, dm0, dm1, dm2, dm3, cke );
	input  		clk;
	input  		ras_n;
	input  		cas_n;
	input  		we_n;
	input  		[10:0] addr;
	input  		[1:0] ba;
	inout  		[31:0] dq;
	input  		cs_n;
	input  		dm0;
	input  		dm1;
	input  		dm2;
	input  		dm3;
	input  		cke;

	EG_PHY_SDRAM_2M_32 sdram(
		.clk(clk),
		.ras_n(ras_n),
		.cas_n(cas_n),
		.we_n(we_n),
		.addr(addr),
		.ba(ba),
		.dq(dq),
		.cs_n(cs_n),
		.dm0(dm0),
		.dm1(dm1),
		.dm2(dm2),
		.dm3(dm3),
		.cke(cke));

endmodule