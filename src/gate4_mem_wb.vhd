library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity gate4_mem_wb is
	port(
		clk, rst: in STD_LOGIC;
		stall, bubble: in STD_LOGIC;
		input_reg_wr_flag: in STD_LOGIC;
		input_res_reg_addr: in STD_LOGIC_VECTOR(3 downto 0);
		input_mem_val: in STD_LOGIC_VECTOR(15 downto 0);
		output_reg_wr_flag: out STD_LOGIC;
		output_val: out STD_LOGIC_VECTOR(15 downto 0);
		output_res_reg_addr: out STD_LOGIC_VECTOR(3 downto 0)
	);
end gate4_mem_wb;

architecture bhv of gate4_mem_wb is
begin
	process(clk, rst)
	begin
		if rst = '0' then
			output_reg_wr_flag <= '0';
			output_val <= (others => '0');
			output_res_reg_addr <= (others => '1');
		elsif rising_edge(clk) then
			if stall = '0' then
				if bubble = '1' then
					output_reg_wr_flag <= '0';
					output_val <= (others => '0');
					output_res_reg_addr <= (others => '1');
				else
					output_reg_wr_flag <= input_reg_wr_flag;
					output_val <= input_mem_val;
					output_res_reg_addr <= input_res_reg_addr;
				end if;
			end if;
		end if;
	end process;
end bhv;
