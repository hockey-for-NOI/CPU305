library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PC is
	port(
		clk, rst: in std_logic;
		jump_flag: in std_logic;
		jump_addr: in std_logic_vector(15 downto 0);
		stall: in std_logic;
		pc_addr: out std_logic_vector(15 downto 0)
	);
end PC;

architecture bhv of PC is

signal	pc: std_logic_vector(15 downto 0);

begin
	pc_addr <= pc;

	process(clk, rst)
	begin
		if (rst = '0') then
			pc <= (others => '0');
		elsif rising_edge(clk) then
			if (stall = '0') then
				if (jump_flag = '1') then
					pc <= jump_addr;
				else
					pc <= pc + 1;
				end if;
			end if;
		end if;
	end process;

end bhv;
