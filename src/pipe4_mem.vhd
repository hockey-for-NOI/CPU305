library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pipe4_mem is
	port(
		input_addr: in std_logic_vector(15 downto 0),
		input_val: in std_logic_vector(15 downto 0),
		input_mem_rd_flag: in std_logic,
		input_mem_wr_flag: in std_logic,
		mem1_rd_flag: out std_logic,
		mem1_rd_addr: out std_logic_vector(15 downto 0),
		mem1_rd_val: in std_logic_vector(15 downto 0),
		mem1_wr_flag: out std_logic,
		mem1_wr_addr: out std_logic_vector(15 downto 0),
		mem1_wr_val: out std_logic_vector(15 downto 0),
		mem2_rd_flag: out std_logic,
		mem2_rd_addr: out std_logic_vector(15 downto 0),
		mem2_rd_val: in std_logic_vector(15 downto 0),
		mem2_wr_flag: out std_logic,
		mem2_wr_addr: out std_logic_vector(15 downto 0),
		mem2_wr_val: out std_logic_vector(15 downto 0),
		output_val: out std_logic_vector(15 downto 0)
	);
end pipe4_mem_wb;

architecture bhv of pipe4_mem is
begin
	mem1_rd_flag <= input_mem_rd_flag and not input_addr(15);
	mem1_rd_addr <= input_addr;
	mem2_rd_flag <= input_mem_rd_flag and input_addr(15);
	mem2_rd_addr <= input_addr;
	mem1_wr_flag <= input_mem_wr_flag and not input_addr(15);
	mem1_wr_addr <= input_addr;
	mem1_wr_val <= input_val;
	mem2_wr_flag <= input_mem_wr_flag and input_addr(15);
	mem2_wr_addr <= input_addr;
	mem2_wr_val <= input_val;
	
	process (mem1_rd_val, mem2_rd_val, input_addr, input_mem_rd_flag)
	begin
		if (input_mem_rd_flag = '0')
			output_val <= input_addr;
		elsif (input_addr(15) = '0')
			output_val <= mem1_rd_val;
		else
			output_val <= mem2_rd_val;
	end process;
end bhv;
