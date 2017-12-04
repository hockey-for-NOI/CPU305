library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity reg is
	port(
		clk: in std_logic;
		rd1, rd2, wr : in STD_LOGIC_VECTOR(3 DOWNTO 0);
		we : in STD_LOGIC;
		wval : in STD_LOGIC_VECTOR(15 downto 0);
		rval1, rval2: out STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
end reg;

architecture bhv of reg is
type reg_array is array (integer range 0 to 15) of std_logic_vector(15 downto 0);
signal regs : reg_array;
begin
	rval1 <= regs(CONV_INTEGER(rd1));
	rval2 <= regs(CONV_INTEGER(rd2));
	
	process(we) --set we as clk
	begin
		if falling_edge(clk) then
			if we = '1' then
				regs(CONV_INTEGER(wr)) <= wval;
			end if;
		end if;
	end process;
end bhv;
