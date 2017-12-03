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

signal t: std_logic_vector(1 downto 0);

begin

--	clk <= clk_in;
--	clk_wr <= not clk_in;
	clk <= not t(1);
	clk_wr <= not(t(0) xor t(1));

	process(clk_in)
	begin
		if rising_edge(clk_in) then
			t <= t + 1;
		end if;
	end process;

end Behavioral;
