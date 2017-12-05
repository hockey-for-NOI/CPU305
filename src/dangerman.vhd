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

signal	pad_danger_addr: std_logic_vector(15 downto 0);

begin

	output_danger_addr1 <= input_danger_addr;
	output_danger_addr2 <= pad_danger_addr;

	process(clk, rst)
	begin
		if (rst = '0') then
			pad_danger_addr <= (others => '1');
		elsif rising_edge(clk) then
			pad_danger_addr <= input_danger_addr;
		end if;
	end process;

end bhv;
