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

signal t: std_logic;

begin

--	clk <= clk_in;
--	clk_wr <= not clk_in;
	clk <= t;
	clk_wr <= t xor clk_in;

	process(clk_in)
	begin
		if rising_edge(clk_in) then
			t <= not t;
		end if;
	end process;

end Behavioral;
