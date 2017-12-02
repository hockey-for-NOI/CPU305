library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity gate1_if_id is
	port(
		clk, rst: in STD_LOGIC;
		stall, bubble: in STD_LOGIC;
		input_instruction, input_pc_addr: in STD_LOGIC_VECTOR(15 downto 0);
		output_instruction, output_pc_addr: out STD_LOGIC_VECTOR(15 downto 0)
	);
end gate1_if_id;

architecture bhv of gate1_if_id is
begin
	process(clk, rst)
	begin
		if rst = '0' then
			output_instruction <= "0000100000000000"; --NOP
			output_pc_addr <= (others => '0');
		elsif rising_edge(clk) then
			if stall = '0' then
				if bubble = '1' then
					output_instruction <= "0000100000000000"; --NOP
					output_pc_addr <= (others => '0');
				else
					output_instruction <= input_instruction;
					output_pc_addr <= input_pc_addr;
				end if;
			end if;
		end if;
	end process;
end bhv;
