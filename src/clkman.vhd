library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clkman is
	port(
		clk_in : in STD_LOGIC;
		clk, clk_wr : out STD_LOGIC
	);
end clkman;

architecture Behavioral of clkman is

signal t : STD_LOGIC_VECTOR(1 downto 0);
begin
	process(clk_in)
	begin
		if rising_edge(clk_in) then 
			clk <= t(0);
			clk_wr <= t(0) or t(1);
			t <= t + 1;
		end if;		
	end process;
end Behavioral;
