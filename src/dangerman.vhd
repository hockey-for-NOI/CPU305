library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dangerman is
	port(
		clk, rst: in std_logic;
		input_danger_addr: in std_logic_vector(15 downto 0);
		output_danger_addr1: out std_logic_vector(15 downto 0);
		output_danger_addr2: out std_logic_vector(15 downto 0)
	);
end dangerman;

architecture bhv of dangerman is

signal	danger_addr1, danger_addr2: std_logic_vector(15 downto 0);

begin

	output_danger_addr1 <= danger_addr1;
	output_danger_addr2 <= danger_addr2;

	process(clk, rst)
	begin
		if (rst = '0') then
			danger_addr1 <= (others => '1');
			danger_addr2 <= (others => '1');
		elsif rising_edge(clk) then
			danger_addr2 <= danger_addr1;
			danger_addr1 <= input_danger_addr;
		end if;
	end process;

end bhv;
