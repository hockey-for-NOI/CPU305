library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity gate2_id_exe is
	port(
		clk, rst: in STD_LOGIC;
		stall, bubble: in STD_LOGIC;
		input_mem_rd_flag, input_mem_wr_flag, input_reg_wr_flag: in STD_LOGIC;
		input_res_reg_addr, input_alu_op: in STD_LOGIC_VECTOR(3 downto 0);
		input_val1, input_val2, input_val3: in STD_LOGIC_VECTOR(15 downto 0);
		output_mem_rd_flag, output_mem_wr_flag, output_reg_wr_flag: out STD_LOGIC;
		output_val1, output_val2, output_val3: out STD_LOGIC_VECTOR(15 downto 0);
		output_res_reg_addr, output_alu_op: out STD_LOGIC_VECTOR(3 downto 0)
	);
end gate2_id_exe;

architecture bhv of gate2_id_exe is
begin
	process(clk, rst)
	begin
		if rst = '0' then
			output_val1 <= (others => '0');
			output_val2 <= (others => '0');
			output_val3 <= (others => '0');
			output_mem_rd_flag <= '0';
			output_mem_wr_flag <= '0';
			output_reg_wr_flag <= '0';
			output_res_reg_addr <= (others => '1');
			output_alu_op <= (others => '1');
		elsif rising_edge(clk) then
			if stall = '0' then
				if bubble = '1' then
					output_val1 <= (others => '0');
					output_val2 <= (others => '0');
					output_val3 <= (others => '0');
					output_mem_rd_flag <= '0';
					output_mem_wr_flag <= '0';
					output_reg_wr_flag <= '0';
					output_res_reg_addr <= (others => '1');
					output_alu_op <= (others => '1');
				else
					output_val1 <= input_val1;
					output_val2 <= input_val2;
					output_val3 <= input_val3;
					output_mem_rd_flag <= input_mem_rd_flag;
					output_mem_wr_flag <= input_mem_wr_flag;
					output_reg_wr_flag <= input_reg_wr_flag;
					output_res_reg_addr <= input_res_reg_addr;
					output_alu_op <= input_alu_op;
				end if;
			end if;
		end if;
	end process;
end bhv;
			
