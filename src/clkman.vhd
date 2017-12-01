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

begin

	clk <= clk_in;
	clk_wr <= not clk_in;

end Behavioral;
