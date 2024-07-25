/************************************************************\
 **     Copyright (c) 2012-2023 Anlogic Inc.
 **  All Right Reserved.\
\************************************************************/
/************************************************************\
 ** Log	:	This file is generated by Anlogic IP Generator.
 ** File	:	C:/Users/W1030/Desktop/m0/td/al_ip/PLL_VGA.v
 ** Date	:	2024 05 06
 ** TD version	:	5.6.71036
\************************************************************/

///////////////////////////////////////////////////////////////////////////////
//	Input frequency:             24.000MHz
//	Clock multiplication factor: 75
//	Clock division factor:       2
//	Clock information:
//		Clock name	| Frequency 	| Phase shift
//		C0        	| 150.000000MHZ	| 0  DEG     
///////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 100 fs

module PLL_VGA (
  refclk,
  reset,
  extlock,
  clk0_out 
);

  input refclk;
  input reset;
  output extlock;
  output clk0_out;


  EG_PHY_PLL #(
    .DPHASE_SOURCE("DISABLE"),
    .DYNCFG("DISABLE"),
    .FIN("24.000"),
    .FEEDBK_MODE("NOCOMP"),
    .FEEDBK_PATH("VCO_PHASE_0"),
    .STDBY_ENABLE("DISABLE"),
    .PLLRST_ENA("ENABLE"),
    .SYNC_ENABLE("DISABLE"),
    .GMC_GAIN(0),
    .ICP_CURRENT(9),
    .KVCO(2),
    .LPF_CAPACITOR(2),
    .LPF_RESISTOR(8),
    .REFCLK_DIV(2),
    .FBCLK_DIV(75),
    .CLKC0_ENABLE("ENABLE"),
    .CLKC0_DIV(6),
    .CLKC0_CPHASE(5),
    .CLKC0_FPHASE(0) 
  ) pll_inst (
    .refclk(refclk),
    .reset(reset),
    .stdby(1'b0),
    .extlock(extlock),
    .load_reg(1'b0),
    .psclk(1'b0),
    .psdown(1'b0),
    .psstep(1'b0),
    .psclksel(3'b000),
    .psdone(open),
    .dclk(1'b0),
    .dcs(1'b0),
    .dwe(1'b0),
    .di(8'b00000000),
    .daddr(6'b000000),
    .do({open, open, open, open, open, open, open, open}),
    .fbclk(1'b0),
    .clkc({open, open, open, open, clk0_out}) 
  );

endmodule

