library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clkman is
	port(
		clk_in : in STD_LOGIC;
		clk, clk_wr : out STD_LOGIC;
		clk_25m : out std_logic
	);
end clkman;

architecture Behavioral of clkman is

signal cnt : std_logic_vector(1 downto 0);

begin

--	clk <= clk_in;
--	clk_wr <= not clk_in;
	--clk <= t;
	clk <= cnt(0);
	clk_wr <= clk_in xor cnt(0);
	clk_25m <= cnt(1);

	process(clk_in)
	begin
		if rising_edge(clk_in) then
			cnt <= cnt + 1;
		end if;
	end process;

end Behavioral;
