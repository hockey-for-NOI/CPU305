library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package	cache_def is

	type	cache_array is array(integer range 0 to 15) of std_logic_vector(26 downto 0);
	-- cache range: C000-FFFF(14 bit address), 26 => enable, 25 downto 16 => addr (14 downto 4), 15 downto 0 => val

end package;
