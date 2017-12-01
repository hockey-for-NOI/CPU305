library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


--res is from ALU res, means memory address
--val is from id, means the value to write in memory
entity gate3_exe_mem is
	port(
		clk, rst: in STD_LOGIC;
		stall, bubble: in STD_LOGIC;
		input_mem_rd_flag, input_mem_wr_flag, input_reg_wr_flag: in STD_LOGIC;
		input_res_reg_addr: in STD_LOGIC_VECTOR(3 downto 0);
		input_res, input_val: in STD_LOGIC_VECTOR(15 downto 0);
		output_mem_rd_flag, output_mem_wr_flag, output_reg_wr_flag: out STD_LOGIC;
		output_res, output_val: out STD_LOGIC_VECTOR(15 downto 0);
		output_res_reg_addr: out STD_LOGIC_VECTOR(3 downto 0)
	);
end gate3_exe_mem;

architecture bhv of gate3_exe_mem is
begin
	process(clk, rst)
	begin
		if rst = '1' then
			output_mem_rd_flag <= '0';
			output_mem_wr_flag <= '0';
			output_reg_wr_flag <= '0';
			output_res <= (others => '0');
			output_val <= (others => '0');
			output_res_reg_addr <= (others => '1');
		elsif rising_edge(clk) then
			if stall = '0' then
				if bubble = '1' then
					output_mem_rd_flag <= '0';
					output_mem_wr_flag <= '0';
					output_reg_wr_flag <= '0';
					output_res <= (others => '0');
					output_val <= (others => '0');
					output_res_reg_addr <= (others => '1');
				else
					output_mem_rd_flag <= input_mem_rd_flag;
					output_mem_wr_flag <= input_mem_wr_flag;
					output_reg_wr_flag <= input_reg_wr_flag;
					output_res <= input_res;
					output_val <= input_val;
					output_res_reg_addr <= input_res_reg_addr;
				end if;
			end if;
		end if;
	end process;
end bhv;
