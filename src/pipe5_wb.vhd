library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pipe5_wb is
	port(
		clk_wr: in STD_LOGIC;
		input_reg_wr_flag: in STD_LOGIC;
		input_val : in STD_LOGIC_VECTOR(15 DOWNTO 0);
		input_res_reg_addr : in STD_LOGIC_VECTOR(3 downto 0);
		reg_we : out STD_LOGIC;
		reg_wr : out STD_LOGIC_VECTOR(3 downto 0);
		reg_wval : out STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
end pipe5_wb;

architecture bhv of pipe5_wb is
begin
	reg_wr <= input_res_reg_addr;
	reg_we <= clk_wr or not input_reg_wr_flag;
	reg_wval <= input_val;
end bhv;
