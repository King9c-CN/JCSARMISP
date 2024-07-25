--------------------------------------------------------------
 --     Copyright (c) 2012-2023 Anlogic Inc.
 --  All Right Reserved.
--------------------------------------------------------------
 -- Log	:	This file is generated by Anlogic IP Generator.
 -- File	:	C:/Users/W1030/Desktop/m0/rtl/al_ip/SDRAM.vhd
 -- Date	:	2024 04 28
 -- TD version	:	5.6.71036
--------------------------------------------------------------

LIBRARY ieee;
USE work.ALL;
	USE ieee.std_logic_1164.all;
LIBRARY eagle_macro;
	USE eagle_macro.EAGLE_COMPONENTS.all;

ENTITY SDRAM IS
PORT (
	clk		: IN STD_LOGIC ;
	ras_n		: IN STD_LOGIC ;
	cas_n		: IN STD_LOGIC ;
	we_n		: IN STD_LOGIC ;
	cs_n		: IN STD_LOGIC ;
	addr		: IN STD_LOGIC_VECTOR(10 DOWNTO 0) ;
	ba		: IN STD_LOGIC_VECTOR(1 DOWNTO 0) ;
	dq		: INOUT STD_LOGIC_VECTOR(31 DOWNTO 0) ;
	dm0		: IN STD_LOGIC ;
	dm1		: IN STD_LOGIC ;
	dm2		: IN STD_LOGIC ;
	dm3		: IN STD_LOGIC ;
	cke		: IN STD_LOGIC
	);
END SDRAM;

ARCHITECTURE struct OF SDRAM IS

	BEGIN
	sdram : EG_PHY_SDRAM_2M_32
		PORT MAP (
			clk	=> clk,
			ras_n	=> ras_n,
			cas_n	=> cas_n,
			we_n	=> we_n,
			cs_n	=> cs_n,
			addr	=> addr,
			ba	=> ba,
			dq	=> dq,
			dm0	=> dm0,
			dm1	=> dm1,
			dm2	=> dm2,
			dm3	=> dm3,
			cke	=> cke
		);

END struct;
